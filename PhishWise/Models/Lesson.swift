//
//  Lesson.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation
import SwiftUI

// MARK: - Lesson Model
/// Represents a lesson with bilingual support
struct Lesson: Identifiable, Codable {
    let id: Int
    let titleEn: String
    let titleNl: String
    let icon: String
    let colorName: String
    let contentEn: [LessonSection]
    let contentNl: [LessonSection]
    
    enum CodingKeys: String, CodingKey {
        case id
        case titleEn = "title_en"
        case titleNl = "title_nl"
        case icon
        case colorName = "color_name"
        case contentEn = "content_en"
        case contentNl = "content_nl"
    }
    
    func title(for language: Language) -> String {
        switch language {
        case .english:
            return titleEn
        case .dutch:
            return titleNl
        }
    }
    
    func content(for language: Language) -> [LessonSection] {
        switch language {
        case .english:
            return contentEn
        case .dutch:
            return contentNl
        }
    }
    
    var color: Color {
        switch colorName {
        case "red":
            return .red
        case "orange":
            return .orange
        case "blue":
            return .blue
        case "purple":
            return .purple
        case "green":
            return .green
        default:
            return .blue
        }
    }
}

// MARK: - Lesson Section
struct LessonSection: Codable {
    let type: String // "text", "example", "tip"
    let titleEn: String?
    let titleNl: String?
    let textEn: String
    let textNl: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case titleEn = "title_en"
        case titleNl = "title_nl"
        case textEn = "text_en"
        case textNl = "text_nl"
    }
    
    func title(for language: Language) -> String? {
        guard let titleEn = titleEn, let titleNl = titleNl else { return nil }
        switch language {
        case .english:
            return titleEn
        case .dutch:
            return titleNl
        }
    }
    
    func text(for language: Language) -> String {
        switch language {
        case .english:
            return textEn
        case .dutch:
            return textNl
        }
    }
}

// MARK: - Lesson Data Manager
class LessonDataManager: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        loadLessons()
    }
    
    /// Loads lessons from the local JSON file
    func loadLessons() {
        isLoading = true
        error = nil
        
        guard let url = Bundle.main.url(forResource: "lessons", withExtension: "json") else {
            self.error = "Lessons data file not found"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            lessons = try decoder.decode([Lesson].self, from: data)
            isLoading = false
        } catch {
            self.error = "Failed to load lessons data: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

