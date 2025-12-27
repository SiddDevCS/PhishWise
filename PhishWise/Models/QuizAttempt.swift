//
//  QuizAttempt.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation

// MARK: - Quiz Attempt Model
/// Represents a completed quiz attempt with results
struct QuizAttempt: Identifiable, Codable {
    let id: UUID
    let score: Int
    let totalQuestions: Int
    let completionDate: Date
    
    var scorePercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: completionDate)
    }
}

// MARK: - Quiz Attempt Manager
/// Manages storing and retrieving quiz attempts locally
class QuizAttemptManager: ObservableObject {
    static let shared = QuizAttemptManager()
    
    @Published var attempts: [QuizAttempt] = []
    
    private let attemptsKey = "quizAttempts"
    
    private init() {
        loadAttempts()
    }
    
    /// Saves a new quiz attempt
    func saveAttempt(score: Int, totalQuestions: Int) {
        let attempt = QuizAttempt(
            id: UUID(),
            score: score,
            totalQuestions: totalQuestions,
            completionDate: Date()
        )
        
        attempts.insert(attempt, at: 0) // Add to beginning (most recent first)
        
        // Keep only the last 50 attempts to avoid storage issues
        if attempts.count > 50 {
            attempts = Array(attempts.prefix(50))
        }
        
        saveAttempts()
    }
    
    /// Gets the most recent attempt
    var mostRecentAttempt: QuizAttempt? {
        return attempts.first
    }
    
    /// Saves attempts to UserDefaults
    private func saveAttempts() {
        if let encoded = try? JSONEncoder().encode(attempts) {
            UserDefaults.standard.set(encoded, forKey: attemptsKey)
        }
    }
    
    /// Loads attempts from UserDefaults
    private func loadAttempts() {
        if let data = UserDefaults.standard.data(forKey: attemptsKey),
           let decoded = try? JSONDecoder().decode([QuizAttempt].self, from: data) {
            attempts = decoded
        }
    }
    
    /// Clears all attempts (for testing/reset)
    func clearAllAttempts() {
        attempts = []
        UserDefaults.standard.removeObject(forKey: attemptsKey)
    }
}

