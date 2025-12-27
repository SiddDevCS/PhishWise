//
//  QuizViewModel.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation
import SwiftUI

// MARK: - Quiz View Model
/// Manages quiz-specific state and logic
class QuizViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswer: Bool?
    @Published var showFeedback: Bool = false
    @Published var isCorrect: Bool = false
    @Published var quizCompleted: Bool = false
    
    let questions: [Question]
    private var correctAnswers: Int = 0
    
    init(questions: [Question] = []) {
        self.questions = questions
    }
    
    // MARK: - Computed Properties
    var currentQuestion: Question? {
        guard !questions.isEmpty, currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        guard !questions.isEmpty else { return false }
        return currentQuestionIndex >= questions.count - 1
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var score: Int {
        correctAnswers
    }
    
    var totalQuestions: Int {
        questions.count
    }
    
    // MARK: - Quiz Methods
    func selectAnswer(_ isPhishing: Bool) {
        selectedAnswer = isPhishing
        showFeedback = true
        
        // Check if answer is correct
        if let question = currentQuestion {
            isCorrect = (isPhishing == question.isPhishing)
            if isCorrect {
                correctAnswers += 1
            }
        }
    }
    
    func nextQuestion() {
        if isLastQuestion {
            quizCompleted = true
        } else {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showFeedback = false
            isCorrect = false
        }
    }
    
    func resetQuiz() {
        currentQuestionIndex = 0
        selectedAnswer = nil
        showFeedback = false
        isCorrect = false
        quizCompleted = false
        correctAnswers = 0
    }
}
