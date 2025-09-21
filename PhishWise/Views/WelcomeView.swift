//
//  WelcomeView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Welcome View
/// The main welcome screen with language selection and navigation options
struct WelcomeView: View {
    @ObservedObject var appViewModel: AppViewModel
    @State private var showingLanguagePicker = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon and Title
            VStack(spacing: 20) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .accessibilityLabel("PhishWise App Icon")
                    .accessibilityAddTraits(.isImage)
                
                Text(NSLocalizedString("welcome_title", comment: "Welcome title"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h1)
                
                Text(NSLocalizedString("welcome_subtitle", comment: "Welcome subtitle"))
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .accessibilityAddTraits(.isStaticText)
            }
            
            Spacer()
            
            // Language Selection Button
            Button(action: {
                showingLanguagePicker = true
            }) {
                HStack {
                    Text(appViewModel.currentLanguage.flag)
                        .font(.title)
                    Text(NSLocalizedString("language_settings", comment: "Language settings"))
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .accessibilityLabel(NSLocalizedString("accessibility_language_button", comment: "Language button accessibility"))
            }
            .padding(.horizontal)
            
            // Main Action Buttons
            VStack(spacing: 16) {
                // Start Learning Button
                Button(action: {
                    appViewModel.navigateTo(.lessons)
                }) {
                    Text(NSLocalizedString("start_learning", comment: "Start learning"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .accessibilityLabel(NSLocalizedString("accessibility_lesson_button", comment: "Lesson button accessibility"))
                
                // Quick Quiz Button
                Button(action: {
                    appViewModel.startQuiz()
                }) {
                    Text(NSLocalizedString("quiz", comment: "Quiz"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
                .accessibilityLabel(NSLocalizedString("accessibility_quiz_button", comment: "Quiz button accessibility"))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingLanguagePicker) {
            LanguagePickerView(appViewModel: appViewModel)
        }
    }
}

// MARK: - Language Picker View
struct LanguagePickerView: View {
    @ObservedObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Language.allCases, id: \.self) { language in
                    Button(action: {
                        appViewModel.currentLanguage = language
                        dismiss()
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.title2)
                            Text(language.displayName)
                                .font(.headline)
                            Spacer()
                            if appViewModel.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle(NSLocalizedString("language_settings", comment: "Language settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("finish", comment: "Finish")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(appViewModel: AppViewModel())
}
