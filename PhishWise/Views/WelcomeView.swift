//
//  WelcomeView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Welcome View
/// The main welcome screen with navigation options
struct WelcomeView: View {
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Spacer()
                    .frame(height: 10)
                
                // App Icon and Title
                VStack(spacing: 12) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 70))
                        .foregroundColor(.blue)
                        .accessibilityLabel("PhishWise App Icon")
                        .accessibilityAddTraits(.isImage)
                    
                    // Personalized Greeting
                    Text(appViewModel.greeting)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityHeading(.h1)
                    
                    Text("welcome_subtitle".localized)
                        .font(.body)
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .accessibilityAddTraits(.isStaticText)
                }
                
                // Instructional Text
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "1.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        Text("welcome_instruction_learn".localized)
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "2.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        Text("welcome_instruction_quiz".localized)
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                .padding(14)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 12)
                
                // Main Action Buttons
                VStack(spacing: 16) {
                    // Start Learning Button
                    Button(action: {
                        appViewModel.navigateTo(.lessons)
                    }) {
                        Text("start_learning".localized)
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
                    .accessibilityLabel("accessibility_lesson_button".localized)
                    
                    // Quick Quiz Button
                    Button(action: {
                        appViewModel.startQuiz()
                    }) {
                        Text("quiz".localized)
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
                    .accessibilityLabel("accessibility_quiz_button".localized)
                }
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 20)
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(appViewModel: AppViewModel())
}
