//
//  NewsListView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - News List View
/// Displays phishing news from the Fly API with digest summary, search, and source filter
struct NewsListView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var newsViewModel = NewsViewModel()
    @State private var showingSearch = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("search_news".localized, text: $newsViewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .accessibilityLabel("search_news".localized)

                        if !newsViewModel.searchText.isEmpty {
                            Button(action: {
                                newsViewModel.clearSearch()
                            }) {
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
                                Button(action: {
                                    newsViewModel.selectCategory(category)
                                }) {
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
                if newsViewModel.isLoading {
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
                        Button("try_again".localized) {
                            newsViewModel.refreshArticles()
                        }
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
                            // Digest summary card
                            if let summary = newsViewModel.digestSummary {
                                DigestSummaryCard(
                                    summary: summary,
                                    date: newsViewModel.digestDate
                                )
                            }

                            ForEach(newsViewModel.filteredArticles) { article in
                                ArticleCard(
                                    article: article,
                                    onTap: {
                                        newsViewModel.selectArticle(article)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("phishing_news".localized)
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                newsViewModel.refreshArticles()
            }
        }
        .sheet(isPresented: $newsViewModel.showingArticleDetail) {
            if let article = newsViewModel.selectedArticle {
                NewsDetailView(
                    article: article,
                    onDismiss: {
                        newsViewModel.showingArticleDetail = false
                    }
                )
            }
        }
    }
}

// MARK: - Digest Summary Card
struct DigestSummaryCard: View {
    let summary: String
    let date: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("todays_summary".localized)
                .font(.headline)
            if let date = date, !date.isEmpty {
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(summary)
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
                        Text(article.title)
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

                Text(article.description)
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
        .accessibilityLabel("\(article.title). \(article.description)")
    }
}

// MARK: - Preview
#Preview {
    NewsListView(appViewModel: AppViewModel())
}
