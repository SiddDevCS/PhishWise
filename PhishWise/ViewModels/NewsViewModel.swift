//
//  NewsViewModel.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation
import SwiftUI

// MARK: - News View Model
/// Manages news-specific state and logic
class NewsViewModel: ObservableObject {
    @Published var selectedArticle: NewsArticle?
    @Published var showingArticleDetail = false
    @Published var searchText = ""
    @Published var selectedCategory = "All"
    
    private let newsDataManager = NewsDataManager()
    
    // MARK: - Computed Properties
    var articles: [NewsArticle] {
        newsDataManager.articles
    }
    
    var isLoading: Bool {
        newsDataManager.isLoading
    }
    
    var error: String? {
        newsDataManager.error
    }
    
    var categories: [String] {
        let allCategories = articles.map { $0.category }
        return ["All"] + Array(Set(allCategories)).sorted()
    }
    
    var filteredArticles: [NewsArticle] {
        var filtered = articles
        
        // Filter by category
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { article in
                article.titleEn.localizedCaseInsensitiveContains(searchText) ||
                article.titleNl.localizedCaseInsensitiveContains(searchText) ||
                article.summaryEn.localizedCaseInsensitiveContains(searchText) ||
                article.summaryNl.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by date (newest first)
        return filtered.sorted { $0.date > $1.date }
    }
    
    // MARK: - Methods
    func selectArticle(_ article: NewsArticle) {
        selectedArticle = article
        showingArticleDetail = true
    }
    
    func refreshArticles() {
        newsDataManager.loadArticles()
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
}
