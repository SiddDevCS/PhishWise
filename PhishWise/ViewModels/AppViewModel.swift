//
//  AppViewModel.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation
import SwiftUI

// MARK: - App View Model
/// Main view model that manages app state and navigation
class AppViewModel: ObservableObject {
    @Published var currentView: AppView = .welcome
    @Published var quizScore: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswer: Bool?
    @Published var showFeedback: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var userName: String?
    
    // Use the shared localization helper
    var currentLanguage: Language {
        return LocalizationHelper.shared.currentLanguage
    }
    
    // Computed property for greeting
    var greeting: String {
        if let name = userName, !name.isEmpty {
            return currentLanguage == .dutch ? "Hoi \(name)!" : "Hi \(name)!"
        } else {
            return currentLanguage == .dutch ? "Hoi!" : "Hi!"
        }
    }
    
    // MARK: - Navigation Methods
    func navigateTo(_ view: AppView) {
        currentView = view
    }
    
    func startQuiz() {
        quizScore = 0
        currentQuestionIndex = 0
        selectedAnswer = nil
        showFeedback = false
        navigateTo(.quizOverview)
    }
    
    func beginNewQuiz() {
        quizScore = 0
        currentQuestionIndex = 0
        selectedAnswer = nil
        showFeedback = false
        navigateTo(.quiz)
    }
    
    func submitAnswer(_ isPhishing: Bool) {
        selectedAnswer = isPhishing
        showFeedback = true
    }
    
    func nextQuestion() {
        if let answer = selectedAnswer {
            // Check if answer is correct (you'll need to pass the current question)
            // This will be handled in QuizView
        }
        
        currentQuestionIndex += 1
        selectedAnswer = nil
        showFeedback = false
    }
    
    func finishQuiz() {
        navigateTo(.progress)
    }
    
    func resetApp() {
        currentView = .welcome
        quizScore = 0
        currentQuestionIndex = 0
        selectedAnswer = nil
        showFeedback = false
    }
    
    // MARK: - Language Management
    func changeLanguage(to language: Language) {
        LocalizationHelper.shared.setLanguage(language)
        // Trigger UI update
        objectWillChange.send()
    }
    
    // MARK: - Onboarding Management
    func saveUserName(_ name: String?) {
        userName = name
        if let name = name, !name.isEmpty {
            UserDefaults.standard.set(name, forKey: "userName")
        } else {
            UserDefaults.standard.removeObject(forKey: "userName")
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        userName = nil
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "userName")
    }
    
    private func loadOnboardingState() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        userName = UserDefaults.standard.string(forKey: "userName")
    }
    
    init() {
        // Load onboarding state
        loadOnboardingState()
        
        // Listen for language changes
        NotificationCenter.default.addObserver(
            forName: .languageChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}

// MARK: - App View Enum
enum AppView {
    case welcome
    case lessons
    case quizOverview
    case quiz
    case feedback
    case progress
    case certificate
}

// MARK: - Tab Selection Enum
enum TabSelection {
    case news
    case course
    case settings
}

