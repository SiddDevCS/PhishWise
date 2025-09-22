//
//  SettingsView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Settings View
/// Settings view for language selection and app preferences
struct SettingsView: View {
    @ObservedObject var appViewModel: AppViewModel
    @State private var showingLanguageAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Language Section
                Section(header: Text(NSLocalizedString("language_settings", comment: "Language Settings"))) {
                    ForEach(Language.allCases, id: \.self) { language in
                        LanguageRow(
                            language: language,
                            isSelected: appViewModel.currentLanguage == language,
                            onTap: {
                                if language != appViewModel.currentLanguage {
                                    showingLanguageAlert = true
                                }
                            }
                        )
                    }
                }
                
                // App Info Section
                Section(header: Text(NSLocalizedString("app_info", comment: "App Information"))) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text(NSLocalizedString("app_version", comment: "App Version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("supported_languages", comment: "Supported Languages"))
                        Spacer()
                        Text("English, Nederlands")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("settings", comment: "Settings"))
            .navigationBarTitleDisplayMode(.large)
            .alert(NSLocalizedString("change_language", comment: "Change Language"), isPresented: $showingLanguageAlert) {
                Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) { }
                Button(NSLocalizedString("change", comment: "Change")) {
                    // Find the selected language
                    if let selectedLanguage = Language.allCases.first(where: { $0 != appViewModel.currentLanguage }) {
                        appViewModel.changeLanguage(to: selectedLanguage)
                    }
                }
            } message: {
                Text(NSLocalizedString("language_change_message", comment: "Changing the language will restart the app to apply the new language."))
            }
        }
        .accessibilityLabel(NSLocalizedString("settings", comment: "Settings"))
    }
}

// MARK: - Language Row
/// Individual language selection row
struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(language.flag)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(language.rawValue.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(language.displayName) \(isSelected ? "selected" : "not selected")")
        .accessibilityHint(isSelected ? NSLocalizedString("currently_selected", comment: "Currently selected") : NSLocalizedString("tap_to_select", comment: "Tap to select"))
    }
}

// MARK: - Preview
#Preview {
    SettingsView(appViewModel: AppViewModel())
}
