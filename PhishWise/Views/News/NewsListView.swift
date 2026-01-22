//
//  NewsListView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - News List View
/// Displays phishing news from the Fly API per API_README: list/today/date-specific, digest summary, search, source filter, date picker, caching, 404 UX.
struct NewsListView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var newsViewModel = NewsViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date picker (README § List All Available Digests, § Date Handling)
                HStack {
                    Menu {
                        ForEach(newsViewModel.pickerDateStrings, id: \.self) { dateString in
                            Button(newsViewModel.pickerLabel(for: dateString)) {
                                newsViewModel.selectDate(dateString)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text(newsViewModel.pickerSelectionLabel)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .accessibilityLabel("select_date".localized)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // Search and Filter Bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("search_news".localized, text: $newsViewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .accessibilityLabel("search_news".localized)
                        if !newsViewModel.searchText.isEmpty {
                            Button(action: { newsViewModel.clearSearch() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityLabel("clear_search".localized)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Source / Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(newsViewModel.categories, id: \.self) { category in
                                Button(action: { newsViewModel.selectCategory(category) }) {
                                    Text(category)
                                        .font(.headline)
                                        .foregroundColor(newsViewModel.selectedCategory == category ? .white : .blue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(newsViewModel.selectedCategory == category ? Color.blue : Color.blue.opacity(0.1))
                                        .cornerRadius(20)
                                }
                                .accessibilityLabel("Filter by \(category)")
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))

                // Content
                if newsViewModel.isLoading && newsViewModel.digest == nil {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("loading_news".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = newsViewModel.error {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("error_loading_news".localized)
                            .font(.headline)
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("try_again".localized) { newsViewModel.refreshArticles() }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if newsViewModel.todayNotFound && newsViewModel.digest == nil {
                    // README: 404 for /today — "digest being prepared" + offer "Show latest"
                    VStack(spacing: 20) {
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("digest_being_prepared".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("show_latest_news".localized) { newsViewModel.loadLatestDigest() }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if newsViewModel.filteredArticles.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "newspaper")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("no_articles_found".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("try_different_search".localized)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Stale cache banner (README: "indicator that it may be outdated")
                            if newsViewModel.isShowingStaleCache, let d = newsViewModel.digestDate {
                                StaleCacheBanner(
                                    date: d,
                                    formatter: { newsViewModel.pickerLabel(for: $0) }
                                )
                            }
                            // Today not ready but showing latest (README: "viewing latest from [date]")
                            if newsViewModel.todayNotFound, let d = newsViewModel.digestDate {
                                TodayNotReadyBanner(dateLabel: newsViewModel.pickerLabel(for: d))
                            }

                            if let summary = newsViewModel.digestSummary {
                                DigestSummaryCard(
                                    sectionTitle: newsViewModel.digestSectionTitle,
                                    summary: summary,
                                    dateCaption: newsViewModel.digestCardDateCaption
                                )
                            }

                            ForEach(newsViewModel.filteredArticles) { article in
                                ArticleCard(article: article) { newsViewModel.selectArticle(article) }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("phishing_news".localized)
            .navigationBarTitleDisplayMode(.large)
            .refreshable { newsViewModel.refreshArticles() }
            .onAppear { newsViewModel.loadAvailableDigestsIfNeeded() }
        }
        .sheet(isPresented: $newsViewModel.showingArticleDetail) {
            if let article = newsViewModel.selectedArticle {
                NewsDetailView(article: article) { newsViewModel.showingArticleDetail = false }
            }
        }
    }
}

// MARK: - Stale cache / today-not-ready banners
private struct StaleCacheBanner: View {
    let date: String
    let formatter: (String) -> String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(format: "showing_cached_from".localized, formatter(date)))
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("may_be_outdated".localized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.orange.opacity(0.12))
        .cornerRadius(10)
    }
}

private struct TodayNotReadyBanner: View {
    let dateLabel: String
    var body: some View {
        Text(String(format: "today_not_ready_showing_latest".localized, dateLabel))
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

// MARK: - Digest Summary Card
/// Section title reflects "Today's News" or "News from [date]"; summary preserves newlines (API_README § Summary Display).
struct DigestSummaryCard: View {
    let sectionTitle: String
    let summary: String
    let dateCaption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sectionTitle)
                .font(.headline)
            if let cap = dateCaption, !cap.isEmpty {
                Text(cap)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(summary.strippingHTML)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Article Card (README: ArticleRow with Text(date, style: .relative))
struct ArticleCard: View {
    let article: Article
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.title.strippingHTML)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        Text(article.source)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        if let date = article.publishedDateObject {
                            Text(date, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text(article.publishedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Text(article.description.strippingHTML)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(article.title.strippingHTML). \(article.description.strippingHTML)")
    }
}

// MARK: - Preview
#Preview {
    NewsListView(appViewModel: AppViewModel())
}
