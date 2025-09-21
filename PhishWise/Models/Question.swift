//
//  Question.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation

// MARK: - Question Model
/// Represents a quiz question with bilingual support
struct Question: Identifiable, Codable, Equatable {
    let id: Int
    let textEn: String
    let textNl: String
    let isPhishing: Bool
    let explanationEn: String
    let explanationNl: String
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case textEn = "text_en"
        case textNl = "text_nl"
        case isPhishing = "is_phishing"
        case explanationEn = "explanation_en"
        case explanationNl = "explanation_nl"
    }
    
    // MARK: - Computed Properties
    /// Returns the question text in the current language
    func text(for language: Language) -> String {
        switch language {
        case .english:
            return textEn
        case .dutch:
            return textNl
        }
    }
    
    /// Returns the explanation text in the current language
    func explanation(for language: Language) -> String {
        switch language {
        case .english:
            return explanationEn
        case .dutch:
            return explanationNl
        }
    }
}

// MARK: - Language Enum
enum Language: String, CaseIterable {
    case english = "en"
    case dutch = "nl"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .dutch:
            return "Nederlands"
        }
    }
    
    var flag: String {
        switch self {
        case .english:
            return "🇬🇧"
        case .dutch:
            return "🇳🇱"
        }
    }
}

// MARK: - Quiz Data Manager
class QuizDataManager: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        loadQuestions()
    }
    
    /// Loads questions from the local JSON file
    func loadQuestions() {
        isLoading = true
        error = nil
        
        guard let url = Bundle.main.url(forResource: "quiz_questions", withExtension: "json") else {
            self.error = "Quiz data file not found"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            questions = try decoder.decode([Question].self, from: data)
            isLoading = false
        } catch {
            self.error = "Failed to load quiz data: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
