//
//  QuizOverviewView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Quiz Overview View
/// Overview screen with options to see previous attempts or start a new quiz
struct QuizOverviewView: View {
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Icon
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .accessibilityLabel("Quiz icon")
                    
                    // Title
                    Text("quiz".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Subtitle
                    Text("quiz_overview_subtitle".localized)
                        .font(.body)
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    // Action Buttons
                    VStack(spacing: 20) {
                        // Make Quiz Button
                        Button(action: {
                            appViewModel.beginNewQuiz()
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                Text("make_quiz".localized)
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
                        .accessibilityLabel("make_quiz".localized)
                        
                        // See Previous Attempts Button
                        Button(action: {
                            appViewModel.navigateTo(.progress)
                        }) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .font(.title)
                                Text("see_previous_attempts".localized)
                                    .font(.title)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .foregroundColor(.blue)
                            .frame(minHeight: 70)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(16)
                        }
                        .accessibilityLabel("see_previous_attempts".localized)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding()
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
    }
}

// MARK: - Preview
#Preview {
    QuizOverviewView(appViewModel: AppViewModel())
}

