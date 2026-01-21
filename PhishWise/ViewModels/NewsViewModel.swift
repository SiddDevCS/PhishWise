//
//  NewsViewModel.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation
import SwiftUI

// MARK: - News View Model
/// Manages news state and loads from the Fly API. Holds @Published so the view updates when loading completes or fails.
class NewsViewModel: ObservableObject {
    @Published var digest: DailyDigest?
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedArticle: Article?
    @Published var showingArticleDetail = false
    @Published var searchText = ""
    @Published var selectedCategory = "All"

    private let service = PhishingNewsService.shared

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

    /// Tries /today first; on 404 falls back to /latest so we show something instead of an error.
    func loadArticles() {
        isLoading = true
        error = nil

        Task { @MainActor in
            do {
                do {
                    digest = try await service.fetchTodayDigest()
                } catch PhishingNewsError.notFound {
                    digest = try await service.fetchLatestDigest()
                }
            } catch {
                digest = nil
                self.error = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
