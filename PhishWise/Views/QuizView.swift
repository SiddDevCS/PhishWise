//
//  QuizView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Quiz View
/// Displays quiz questions and handles user interactions
struct QuizView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var quizDataManager = QuizDataManager()
    @State private var quizViewModel: QuizViewModel?
    @State private var showingFeedback = false
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if quizDataManager.isLoading {
                    // Loading State
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading quiz...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = quizDataManager.error {
                    // Error State
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Error loading quiz")
                            .font(.headline)
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            quizDataManager.loadQuestions()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let quizVM = quizViewModel, quizVM.quizCompleted {
                    // Quiz Completed
                    QuizCompleteView(quizViewModel: quizVM, appViewModel: appViewModel)
                } else if let quizVM = quizViewModel, let question = quizVM.currentQuestion {
                    // Quiz Question
                    QuizQuestionView(
                        quizViewModel: quizVM,
                        question: question,
                        appViewModel: appViewModel,
                        showingFeedback: $showingFeedback
                    )
                }
            }
            .navigationTitle("quiz".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("back".localized) {
                        appViewModel.navigateTo(.welcome)
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
            }
        }
        .onAppear {
            if quizDataManager.questions.isEmpty {
                quizDataManager.loadQuestions()
            } else if quizViewModel == nil || quizViewModel?.questions.isEmpty == true {
                quizViewModel = QuizViewModel(questions: quizDataManager.questions)
            }
        }
        .onChange(of: quizDataManager.questions) { newQuestions in
            if !newQuestions.isEmpty && (quizViewModel == nil || quizViewModel?.questions.isEmpty == true) {
                quizViewModel = QuizViewModel(questions: newQuestions)
            }
        }
        .onChange(of: showingFeedback) { isShowing in
            // Force view update when feedback sheet is dismissed
            if !isShowing {
                // Trigger view update
            }
        }
        .sheet(isPresented: $showingFeedback) {
            if let quizVM = quizViewModel, let question = quizVM.currentQuestion {
                FeedbackView(
                    question: question,
                    selectedAnswer: quizVM.selectedAnswer ?? false,
                    isCorrect: quizVM.isCorrect,
                    appViewModel: appViewModel,
                    quizViewModel: quizVM,
                    onContinue: {
                        // This will be called after dismiss
                    }
                )
            }
        }
    }
}

// MARK: - Quiz Question View
struct QuizQuestionView: View {
    @ObservedObject var quizViewModel: QuizViewModel
    let question: Question
    @ObservedObject var appViewModel: AppViewModel
    @Binding var showingFeedback: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressView(value: quizViewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal)
                .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Question Header
                    VStack(spacing: 16) {
                        Text(String(format: "question_number".localized, 
                                  quizViewModel.currentQuestionIndex + 1, 
                                  quizViewModel.totalQuestions))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("is_this_phishing".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityHeading(.h2)
                    }
                    .padding(.top, 20)
                    
                    // Question Content
                    VStack(spacing: 20) {
                        Text(question.text(for: appViewModel.currentLanguage))
                            .font(.title2)
                            .lineSpacing(6)
                            .multilineTextAlignment(.leading)
                            .padding(20)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .accessibilityLabel("Question content")
                        
                        // Answer Buttons
                        VStack(spacing: 20) {
                            Button(action: {
                                quizViewModel.selectAnswer(true)
                                showingFeedback = true
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                    Text("yes".localized)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .frame(minHeight: 70)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(Color.blue)
                                .cornerRadius(16)
                            }
                            .accessibilityLabel("accessibility_yes_button".localized)
                            
                            Button(action: {
                                quizViewModel.selectAnswer(false)
                                showingFeedback = true
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                    Text("no".localized)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .frame(minHeight: 70)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(Color.blue)
                                .cornerRadius(16)
                            }
                            .accessibilityLabel("accessibility_no_button".localized)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .id(quizViewModel.currentQuestionIndex)
    }
}

// MARK: - Quiz Complete View
struct QuizCompleteView: View {
    @ObservedObject var quizViewModel: QuizViewModel
    @ObservedObject var appViewModel: AppViewModel
    
    var scorePercentage: Double {
        guard quizViewModel.totalQuestions > 0 else { return 0 }
        return Double(quizViewModel.score) / Double(quizViewModel.totalQuestions) * 100
    }
    
    var performanceMessage: String {
        switch scorePercentage {
        case 90...100:
            return "excellent".localized
        case 70..<90:
            return "good_job".localized
        case 50..<70:
            return "keep_learning".localized
        default:
            return "try_again".localized
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Completion Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .accessibilityLabel("Quiz completed")
            
            // Results
            VStack(spacing: 16) {
                Text("quiz_complete".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(performanceMessage)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text(String(format: "your_score".localized, 
                          quizViewModel.score, 
                          quizViewModel.totalQuestions))
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text(String(format: "percentage".localized, scorePercentage))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 20) {
                Button(action: {
                    appViewModel.navigateTo(.certificate)
                }) {
                    Text("get_certificate".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 70)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                
                Button(action: {
                    quizViewModel.resetQuiz()
                }) {
                    Text("restart".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 70)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Save the quiz attempt when quiz is completed
            QuizAttemptManager.shared.saveAttempt(
                score: quizViewModel.score,
                totalQuestions: quizViewModel.totalQuestions
            )
            // Update AppViewModel with the quiz results
            appViewModel.updateQuizScore(
                score: quizViewModel.score,
                totalQuestions: quizViewModel.totalQuestions
            )
        }
    }
}

// MARK: - Preview
#Preview {
    QuizView(appViewModel: AppViewModel())
}
