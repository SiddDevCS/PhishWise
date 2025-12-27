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
    @ObservedObject private var attemptManager = QuizAttemptManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                                .accessibilityLabel("Progress Icon")
                            
                            Text("progress".localized)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .accessibilityAddTraits(.isHeader)
                        }
                        .padding(.top, 10)
                        
                        // Most Recent Attempt Section
                        if let recentAttempt = attemptManager.mostRecentAttempt {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("last_attempt".localized)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    // Score Card
                                    ProgressCard(
                                        title: "last_attempt_score".localized,
                                        titleNl: "Laatste Poging Score",
                                        value: "\(recentAttempt.score)",
                                        subtitle: String(format: "last_attempt_out_of".localized, recentAttempt.totalQuestions),
                                        subtitleNl: String(format: "last_attempt_out_of_nl".localized, recentAttempt.totalQuestions),
                                        icon: "star.fill",
                                        color: .orange,
                                        appViewModel: appViewModel
                                    )
                                    
                                    // Percentage Card
                                    ProgressCard(
                                        title: "last_attempt_percentage".localized,
                                        titleNl: "Laatste Poging Percentage",
                                        value: String(format: "%.0f%%", recentAttempt.scorePercentage),
                                        subtitle: recentAttempt.formattedDate,
                                        subtitleNl: recentAttempt.formattedDate,
                                        icon: "percent",
                                        color: .blue,
                                        appViewModel: appViewModel
                                    )
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            // No attempts yet
                            VStack(spacing: 12) {
                                Image(systemName: "clock.badge.questionmark")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("no_attempts_yet".localized)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Progress Stats
                        VStack(spacing: 12) {
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
                                    Text("restart".localized)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 60)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .cornerRadius(16)
                            }
                            .accessibilityLabel("accessibility_quiz_button".localized)
                            
                            Button(action: {
                                appViewModel.navigateTo(.lessons)
                            }) {
                                HStack {
                                    Image(systemName: "book.fill")
                                        .font(.title2)
                                    Text("lessons".localized)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 60)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(16)
                            }
                            .accessibilityLabel("accessibility_lesson_button".localized)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("progress".localized)
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
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedTitle)
                        .font(.body)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    Text(localizedSubtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    PhishWiseProgressView(appViewModel: AppViewModel())
}
