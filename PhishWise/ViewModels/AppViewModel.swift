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
    @Published var currentLanguage: Language = .english
    @Published var currentView: AppView = .welcome
    @Published var quizScore: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswer: Bool?
    @Published var showFeedback: Bool = false
    
    // MARK: - Navigation Methods
    func navigateTo(_ view: AppView) {
        currentView = view
    }
    
    func startQuiz() {
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
}

// MARK: - App View Enum
enum AppView {
    case welcome
    case lessons
    case quiz
    case feedback
    case progress
    case certificate
}

// MARK: - Tab Selection Enum
enum TabSelection {
    case news
    case course
}
