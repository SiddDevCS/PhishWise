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
                             NSLocalizedString("correct_answer", comment: "Correct answer") : 
                             NSLocalizedString("incorrect_answer", comment: "Incorrect answer"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(isCorrect ? .green : .red)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .padding(.top, 20)
                    
                    // Question Review
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("explanation", comment: "Explanation"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(question.text(for: appViewModel.currentLanguage))
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .accessibilityLabel("Question content")
                        
                        Text(question.explanation(for: appViewModel.currentLanguage))
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .accessibilityLabel("Answer explanation")
                    }
                    .padding(.horizontal)
                    
                    // Additional Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("💡 Tips:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(icon: "magnifyingglass", text: "Check the sender's email address carefully")
                            TipRow(icon: "exclamationmark.triangle", text: "Look for urgent or threatening language")
                            TipRow(icon: "link", text: "Hover over links before clicking")
                            TipRow(icon: "envelope", text: "When in doubt, contact the company directly")
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle(NSLocalizedString("explanation", comment: "Explanation"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("continue", comment: "Continue")) {
                        if quizViewModel.isLastQuestion {
                            quizViewModel.nextQuestion()
                            dismiss()
                        } else {
                            quizViewModel.nextQuestion()
                            dismiss()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
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
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
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
        quizViewModel: QuizViewModel(questions: [])
    )
}
