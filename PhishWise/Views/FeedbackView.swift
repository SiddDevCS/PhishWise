//
//  FeedbackView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Feedback View
/// Shows explanation for the chosen answer
struct FeedbackView: View {
    let question: Question
    let selectedAnswer: Bool
    let isCorrect: Bool
    @ObservedObject var appViewModel: AppViewModel
    @ObservedObject var quizViewModel: QuizViewModel
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Result Header
                    VStack(spacing: 16) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(isCorrect ? .green : .red)
                            .accessibilityLabel(isCorrect ? "Correct answer" : "Incorrect answer")
                        
                        Text(isCorrect ? 
                             "correct_answer".localized : 
                             "incorrect_answer".localized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(isCorrect ? .green : .red)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .padding(.top, 20)
                    
                    // Question Review
                    VStack(alignment: .leading, spacing: 16) {
                        Text("explanation".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(question.text(for: appViewModel.currentLanguage))
                            .font(.body)
                            .lineSpacing(4)
                            .padding(16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .accessibilityLabel("Question content")
                        
                        Text(question.explanation(for: appViewModel.currentLanguage))
                            .font(.body)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .padding(16)
                            .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .accessibilityLabel("Answer explanation")
                    }
                    .padding(.horizontal)
                    
                    // Additional Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("tips_title".localized)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            TipRow(icon: "magnifyingglass", text: "tip_check_sender".localized)
                            TipRow(icon: "exclamationmark.triangle", text: "tip_urgent_language".localized)
                            TipRow(icon: "link", text: "tip_check_links".localized)
                            TipRow(icon: "envelope", text: "tip_contact_directly".localized)
                            TipRow(icon: "lock.shield", text: "tip_never_share_password".localized)
                        }
                    }
                    .padding(20)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("explanation".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("continue".localized) {
                        quizViewModel.nextQuestion()
                        onContinue()
                        dismiss()
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleQuestion = Question(
        id: 1,
        textEn: "Sample question text",
        textNl: "Voorbeeld vraag tekst",
        isPhishing: true,
        explanationEn: "This is a sample explanation",
        explanationNl: "Dit is een voorbeeld uitleg"
    )
    
    FeedbackView(
        question: sampleQuestion,
        selectedAnswer: true,
        isCorrect: true,
        appViewModel: AppViewModel(),
        quizViewModel: QuizViewModel(questions: []),
        onContinue: {}
    )
}
