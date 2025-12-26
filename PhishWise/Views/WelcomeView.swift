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
                
                Text("welcome_title".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h1)
                
                Text("welcome_subtitle".localized)
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
                    Text("language_settings".localized)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
                .frame(minHeight: 60)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .accessibilityLabel("accessibility_language_button".localized)
            }
            .padding(.horizontal)
            
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
                        appViewModel.changeLanguage(to: language)
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
            .navigationTitle("language_settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("finish".localized) {
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
