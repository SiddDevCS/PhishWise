//
//  NewsArticle.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation

// MARK: - News Article Model
/// Represents a news article with bilingual support
struct NewsArticle: Identifiable, Codable, Equatable {
    let id: Int
    let titleEn: String
    let titleNl: String
    let summaryEn: String
    let summaryNl: String
    let contentEn: String
    let contentNl: String
    let date: String
    let category: String
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case titleEn = "title_en"
        case titleNl = "title_nl"
        case summaryEn = "summary_en"
        case summaryNl = "summary_nl"
        case contentEn = "content_en"
        case contentNl = "content_nl"
        case date
        case category
    }
    
    // MARK: - Computed Properties
    /// Returns the article title in the current language
    func title(for language: Language) -> String {
        switch language {
        case .english:
            return titleEn
        case .dutch:
            return titleNl
        }
    }
    
    /// Returns the article summary in the current language
    func summary(for language: Language) -> String {
        switch language {
        case .english:
            return summaryEn
        case .dutch:
            return summaryNl
        }
    }
    
    /// Returns the article content in the current language
    func content(for language: Language) -> String {
        switch language {
        case .english:
            return contentEn
        case .dutch:
            return contentNl
        }
    }
    
    /// Returns formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: date) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return date
    }
}

// MARK: - News Data Manager
class NewsDataManager: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        loadArticles()
    }
    
    /// Loads news articles from the local JSON file
    func loadArticles() {
        isLoading = true
        self.error = nil
        
        guard let url = Bundle.main.url(forResource: "news_articles", withExtension: "json") else {
            self.error = "News data file not found"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            articles = try decoder.decode([NewsArticle].self, from: data)
            isLoading = false
        } catch {
            self.error = "Failed to load news data: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
