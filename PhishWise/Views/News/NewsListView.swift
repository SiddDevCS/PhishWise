//
//  NewsListView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - News List View
/// Displays a list of news articles with filtering and search
struct NewsListView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var newsViewModel = NewsViewModel()
    @State private var showingSearch = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    // Search Bar
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
                    
                    // Category Filter
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
                    // Loading State
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("loading_news".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = newsViewModel.error {
                    // Error State
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
                    // Empty State
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
                    // Articles List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(newsViewModel.filteredArticles) { article in
                                NewsArticleCard(
                                    article: article,
                                    language: appViewModel.currentLanguage,
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
                    language: appViewModel.currentLanguage,
                    onDismiss: {
                        newsViewModel.showingArticleDetail = false
                    }
                )
            }
        }
    }
}

// MARK: - News Article Card
struct NewsArticleCard: View {
    let article: NewsArticle
    let language: Language
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.title(for: language))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text(article.category)
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
                        Text(article.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Summary
                Text(article.summary(for: language))
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
        .accessibilityLabel("\(article.title(for: language)). \(article.summary(for: language))")
    }
}

// MARK: - Preview
#Preview {
    NewsListView(appViewModel: AppViewModel())
}
