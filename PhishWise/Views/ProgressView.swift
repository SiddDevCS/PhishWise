//
//  ProgressView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Progress View
/// Shows user's progress and statistics
struct PhishWiseProgressView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var quizDataManager = QuizDataManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .accessibilityLabel("Progress Icon")
                        
                        Text(NSLocalizedString("progress", comment: "Progress"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .padding(.top, 20)
                    
                    // Progress Stats
                    VStack(spacing: 20) {
                        // Overall Score Card
                        ProgressCard(
                            title: "Overall Score",
                            titleNl: "Algemene Score",
                            value: "\(appViewModel.quizScore)",
                            subtitle: "out of \(appViewModel.totalQuestions)",
                            subtitleNl: "van \(appViewModel.totalQuestions)",
                            icon: "star.fill",
                            color: .orange,
                            appViewModel: appViewModel
                        )
                        
                        // Accuracy Card
                        let accuracy = appViewModel.totalQuestions > 0 ? 
                            Double(appViewModel.quizScore) / Double(appViewModel.totalQuestions) * 100 : 0
                        
                        ProgressCard(
                            title: "Accuracy",
                            titleNl: "Nauwkeurigheid",
                            value: String(format: "%.0f%%", accuracy),
                            subtitle: "Correct answers",
                            subtitleNl: "Correcte antwoorden",
                            icon: "target",
                            color: .green,
                            appViewModel: appViewModel
                        )
                        
                        // Questions Completed Card
                        ProgressCard(
                            title: "Questions Completed",
                            titleNl: "Vragen Voltooid",
                            value: "\(appViewModel.totalQuestions)",
                            subtitle: "Total questions",
                            subtitleNl: "Totaal vragen",
                            icon: "questionmark.circle.fill",
                            color: .blue,
                            appViewModel: appViewModel
                        )
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            appViewModel.startQuiz()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title2)
                                Text(NSLocalizedString("restart", comment: "Restart"))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .accessibilityLabel(NSLocalizedString("accessibility_quiz_button", comment: "Quiz button accessibility"))
                        
                        Button(action: {
                            appViewModel.navigateTo(.lessons)
                        }) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.title2)
                                Text(NSLocalizedString("lessons", comment: "Lessons"))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .accessibilityLabel(NSLocalizedString("accessibility_lesson_button", comment: "Lesson button accessibility"))
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle(NSLocalizedString("progress", comment: "Progress"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("back", comment: "Back")) {
                        appViewModel.navigateTo(.welcome)
                    }
                }
            }
        }
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    let title: String
    let titleNl: String
    let value: String
    let subtitle: String
    let subtitleNl: String
    let icon: String
    let color: Color
    @ObservedObject var appViewModel: AppViewModel
    
    var localizedTitle: String {
        appViewModel.currentLanguage == .dutch ? titleNl : title
    }
    
    var localizedSubtitle: String {
        appViewModel.currentLanguage == .dutch ? subtitleNl : subtitle
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizedTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    Text(localizedSubtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    PhishWiseProgressView(appViewModel: AppViewModel())
}
