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
                Section(header: Text("language_settings".localized)) {
                    ForEach(Language.allCases, id: \.self) { language in
                        LanguageRow(
                            language: language,
                            isSelected: appViewModel.currentLanguage == language,
                            onTap: {
                                if language != appViewModel.currentLanguage {
                                    appViewModel.changeLanguage(to: language)
                                }
                            }
                        )
                    }
                }
                
                // App Info Section
                Section(header: Text("app_info".localized)) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("app_version".localized)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.green)
                        Text("supported_languages".localized)
                        Spacer()
                        Text("English, Nederlands")
                            .foregroundColor(.secondary)
                    }
                    
                    // Privacy Policy Link
                    if let privacyURL = URL(string: "https://phish-wise-web.vercel.app/privacy-policy") {
                        Link(destination: privacyURL) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(.blue)
                                Text("privacy_policy".localized)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Terms of Service Link
                    if let termsURL = URL(string: "https://phish-wise-web.vercel.app/terms") {
                        Link(destination: termsURL) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.blue)
                                Text("terms_of_service".localized)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.large)
        }
        .accessibilityLabel("settings".localized)
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
        .accessibilityHint(isSelected ? "currently_selected".localized : "tap_to_select".localized)
    }
}

// MARK: - Preview
#Preview {
    SettingsView(appViewModel: AppViewModel())
}
