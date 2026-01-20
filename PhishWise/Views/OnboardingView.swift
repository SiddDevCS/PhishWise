//
//  OnboardingView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Onboarding View
/// Onboarding flow with language selection, name input and app purpose explanation
struct OnboardingView: View {
    @ObservedObject var appViewModel: AppViewModel
    @State private var currentPage = 0
    @State private var userName: String = ""
    @State private var showNameInput = true
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 0: Language Selection
            LanguageSelectionView(
                appViewModel: appViewModel,
                onContinue: {
                    withAnimation {
                        currentPage = 1
                    }
                }
            )
            .tag(0)
            
            // Page 1: Name Input
            NameInputView(
                userName: $userName,
                showNameInput: $showNameInput,
                onContinue: {
                    appViewModel.saveUserName(showNameInput ? userName.trimmingCharacters(in: .whitespacesAndNewlines) : nil)
                    withAnimation {
                        currentPage = 2
                    }
                }
            )
            .tag(1)
            
            // Page 2: App Purpose
            AppPurposeView(
                onGetStarted: {
                    appViewModel.completeOnboarding()
                }
            )
            .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onChange(of: currentPage) { newPage in
            // Dismiss keyboard when navigating away from name input screen (page 1)
            if newPage != 1 {
                // Force keyboard dismissal by resigning first responder
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

// MARK: - Language Selection View
struct LanguageSelectionView: View {
    @ObservedObject var appViewModel: AppViewModel
    let onContinue: () -> Void
    @State private var selectedLanguage: Language?
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .accessibilityLabel("Language selection icon")
            
            // Title - using current language for display
            Text("onboarding_language_title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal)
            
            // Subtitle
            Text("onboarding_language_subtitle".localized)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            // Language Options
            VStack(spacing: 20) {
                ForEach(Language.allCases, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                        appViewModel.changeLanguage(to: language)
                        // Small delay to show selection before continuing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onContinue()
                        }
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.system(size: 50))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(language.displayName)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(language.rawValue.uppercased())
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if (selectedLanguage ?? appViewModel.currentLanguage) == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(20)
                        .background((selectedLanguage ?? appViewModel.currentLanguage) == language ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke((selectedLanguage ?? appViewModel.currentLanguage) == language ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .accessibilityLabel("\(language.displayName)")
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .onAppear {
            // Initialize selected language to current language
            selectedLanguage = appViewModel.currentLanguage
        }
    }
}

// MARK: - Name Input View
struct NameInputView: View {
    @Binding var userName: String
    @Binding var showNameInput: Bool
    let onContinue: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    private let maxCharacters = 15
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top spacing - reduced when keyboard is visible
                Spacer()
                    .frame(height: 40)
                
                // Icon
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                    .accessibilityLabel("Name input icon")
                
                // Title
                Text("onboarding_name_title".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal)
                
                // Subtitle
                Text("onboarding_name_subtitle".localized)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Spacing before input
                Spacer()
                    .frame(height: 30)
                
                // Name Input Field
                VStack(spacing: 16) {
                    TextField("onboarding_name_placeholder".localized, text: Binding(
                        get: { userName },
                        set: { newValue in
                            // Limit to maxCharacters
                            if newValue.count <= maxCharacters {
                                userName = newValue
                            }
                        }
                    ))
                        .font(.title2)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .focused($isTextFieldFocused)
                        .accessibilityLabel("onboarding_name_placeholder".localized)
                        .submitLabel(.done)
                        .onSubmit {
                            if !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                showNameInput = true
                                onContinue()
                            }
                        }
                    
                    // Character count indicator
                    HStack {
                        Spacer()
                        Text("\(userName.count)/\(maxCharacters)")
                            .font(.caption)
                            .foregroundColor(userName.count >= maxCharacters ? .red : .secondary)
                    }
                    .padding(.horizontal, 4)
                    
                    // Skip Option
                    Button(action: {
                        isTextFieldFocused = false
                        showNameInput = false
                        onContinue()
                    }) {
                        Text("onboarding_skip_name".localized)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .underline()
                    }
                    .accessibilityLabel("onboarding_skip_name".localized)
                }
                .padding(.horizontal)
                
                // Continue Button
                Button(action: {
                    isTextFieldFocused = false
                    showNameInput = !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    onContinue()
                }) {
                    Text("continue".localized)
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
                .accessibilityLabel("continue".localized)
                .padding(.horizontal)
                
                // Bottom spacing for keyboard
                Spacer()
                    .frame(height: 100)
            }
            .padding(.vertical)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemBackground))
        .onDisappear {
            // Dismiss keyboard when leaving this view
            isTextFieldFocused = false
        }
    }
}

// MARK: - App Purpose View
struct AppPurposeView: View {
    let onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon - smaller
            Image(systemName: "shield.checkered")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .accessibilityLabel("App purpose icon")
            
            // Title - smaller
            Text("onboarding_purpose_title".localized)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal)
            
            // Purpose Description - smaller and more compact
            VStack(alignment: .leading, spacing: 12) {
                PurposeRow(
                    icon: "book.fill",
                    text: "onboarding_purpose_learn".localized
                )
                
                PurposeRow(
                    icon: "questionmark.circle.fill",
                    text: "onboarding_purpose_practice".localized
                )
                
                PurposeRow(
                    icon: "checkmark.shield.fill",
                    text: "onboarding_purpose_protect".localized
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Get Started Button
            Button(action: {
                onGetStarted()
            }) {
                Text("onboarding_get_started".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 60)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .accessibilityLabel("onboarding_get_started".localized)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Purpose Row
struct PurposeRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(14)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(appViewModel: AppViewModel())
}

