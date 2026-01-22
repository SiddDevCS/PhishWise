//
//  NewsViewModel.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation
import SwiftUI

// MARK: - News View Model
/// Manages news state, caching, and loads from the Fly API per API_README (list, today/latest, date-specific, error handling).
class NewsViewModel: ObservableObject {
    @Published var digest: DailyDigest?
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedArticle: Article?
    @Published var showingArticleDetail = false
    @Published var searchText = ""
    @Published var selectedCategory = "All"

    /// When /today returns 404: show "digest being prepared" and/or "viewing latest from [date]" (README § Error handling, § Best practices).
    @Published var todayNotFound = false

    /// Available digest dates from GET /api/phishing-news for the date picker (README § List All Available Digests).
    @Published var availableDigests: [DigestSummary] = []

    /// User-selected date (YYYY-MM-DD). `nil` = "Today" (or latest when today 404).
    @Published var selectedDigestDate: String?

    /// True when refresh failed but we still show a cached digest (README: "indicator that it may be outdated").
    @Published var isShowingStaleCache = false

    private let service = PhishingNewsService.shared
    private var digestCache: [String: DailyDigest] = [:]
    private static let dateFormat: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    init() {
        loadArticles()
    }

    // MARK: - Computed

    var articles: [Article] {
        digest?.articles ?? []
    }

    var digestSummary: String? {
        digest?.summary
    }

    var digestDate: String? {
        digest?.date
    }

    var digestGeneratedAt: String? {
        digest?.generatedAt
    }

    /// "Today's News" if digest date is today (UTC), else "News from [formatted date]" (README § Date Information).
    var digestSectionTitle: String {
        guard let d = digest?.date else { return "phishing_news".localized }
        if d == Self.todayDateString { return "todays_news".localized }
        return String(format: "news_from_date".localized, formatMediumDate(d))
    }

    /// Formatted date for cards; only when it's today (README § Date Information).
    var digestCardDateCaption: String? {
        guard digest?.date == Self.todayDateString else { return nil }
        return digestDate.flatMap { formatMediumDate($0) }
    }

    var categories: [String] {
        let sources = articles.map { $0.source }
        return ["All"] + Array(Set(sources)).sorted()
    }

    var filteredArticles: [Article] {
        var filtered = articles
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.source == selectedCategory }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.description.localizedCaseInsensitiveContains(searchText) ||
                article.source.localizedCaseInsensitiveContains(searchText)
            }
        }
        return filtered.sorted { a, b in
            (a.publishedDateObject ?? .distantPast) > (b.publishedDateObject ?? .distantPast)
        }
    }

    /// Dates for the picker: "Today" plus available from API, with "Today" first when it’s a known digest or we’re in "today" mode.
    var pickerDateStrings: [String] {
        availableDigests.map(\.date)
    }

    /// Label for the date picker button. Uses the digest date when none selected; never "Nieuws van vandaag".
    var pickerSelectionLabel: String {
        if let d = selectedDigestDate { return pickerLabel(for: d) }
        if let d = digest?.date { return pickerLabel(for: d) }
        return availableDigests.first.map { pickerLabel(for: $0.date) } ?? "select_date".localized
    }

    /// Human-readable label for a date string (e.g. "21 Jan 2026").
    func pickerLabel(for dateString: String?) -> String {
        guard let s = dateString else { return "select_date".localized }
        return formatMediumDate(s)
    }

    private static var todayDateString: String {
        dateFormat.string(from: Date())
    }

    // MARK: - Actions

    func selectArticle(_ article: Article) {
        selectedArticle = article
        showingArticleDetail = true
    }

    func refreshArticles() {
        loadArticles()
    }

    func clearSearch() {
        searchText = ""
    }

    func selectCategory(_ category: String) {
        selectedCategory = category
    }

    /// Select date for the digest. `nil` = Today. Triggers load for that date (cache or API).
    func selectDate(_ dateString: String?) {
        selectedDigestDate = dateString
        loadForSelectedDate()
    }

    /// "Show latest news" when today returns 404 (README: offer latest as fallback).
    func loadLatestDigest() {
        todayNotFound = false
        selectedDigestDate = nil
        isLoading = true
        error = nil
        Task { @MainActor in
            do {
                let d = try await service.fetchLatestDigest()
                digest = d
                cache(d)
                fetchListInBackground()
            } catch {
                digest = nil
                self.error = error.localizedDescription
            }
            self.isLoading = false
        }
    }

    /// Load list of available digests (README § List All Available Digests). Does not clear digest.
    func loadAvailableDigestsIfNeeded() {
        guard availableDigests.isEmpty else { return }
        Task { @MainActor in
            do {
                let list = try await service.listDigests(limit: 20)
                availableDigests = list.digests
            } catch {
                // Non-fatal; picker can still show "Today"
            }
        }
    }

    // MARK: - Private loading

    /// Main entry: today (or selected date), with cache-first when we have it (README § Caching, § Primary Data Fetching).
    func loadArticles() {
        isShowingStaleCache = false
        let key = selectedDigestDate ?? Self.todayDateString
        if let cached = digestCache[key] {
            digest = cached
            todayNotFound = false
            error = nil
        }
        loadForSelectedDate()
    }

    private func loadForSelectedDate() {
        isLoading = true
        error = nil
        let isRequestingToday = (selectedDigestDate == nil)

        Task { @MainActor in
            do {
                if isRequestingToday {
                    do {
                        let d = try await service.fetchTodayDigest()
                        digest = d
                        cache(d)
                        todayNotFound = false
                        fetchListInBackground()
                    } catch PhishingNewsError.notFound {
                        todayNotFound = true
                        fetchListInBackground()
                        // If we already have a digest (e.g. from "Show latest"), keep it
                    }
                } else if let date = selectedDigestDate {
                    if let cached = digestCache[date] {
                        digest = cached
                        todayNotFound = false
                    } else {
                        let d = try await service.fetchDigest(for: parseDate(date))
                        digest = d
                        cache(d)
                        todayNotFound = false
                    }
                }
            } catch {
                if digest != nil {
                    isShowingStaleCache = true
                    self.error = nil
                } else if let c = cachedDigestForCurrentSelection() {
                    digest = c
                    isShowingStaleCache = true
                    self.error = nil
                } else {
                    digest = nil
                    self.error = error.localizedDescription
                }
            }
            self.isLoading = false
        }
    }

    private func fetchListInBackground() {
        Task { @MainActor in
            do {
                let list = try await service.listDigests(limit: 20)
                availableDigests = list.digests
            } catch { /* non-fatal */ }
        }
    }

    private func cache(_ d: DailyDigest) {
        digestCache[d.date] = d
    }

    private func cachedDigestForCurrentSelection() -> DailyDigest? {
        let key = selectedDigestDate ?? Self.todayDateString
        return digestCache[key]
    }

    private func parseDate(_ yyyyMMdd: String) -> Date {
        Self.dateFormat.date(from: yyyyMMdd) ?? Date()
    }

    private func formatMediumDate(_ yyyyMMdd: String) -> String {
        guard let d = Self.dateFormat.date(from: yyyyMMdd) else { return yyyyMMdd }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeZone = TimeZone(identifier: "UTC")
        return f.string(from: d)
    }
}
