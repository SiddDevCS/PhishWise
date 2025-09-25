//
//  LocalizationHelper.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation

// MARK: - Localization Helper
/// Handles dynamic language switching and localization
class LocalizationHelper: ObservableObject {
    static let shared = LocalizationHelper()
    
    @Published var currentLanguage: Language = .dutch
    
    private var localizedStrings: [String: [String: String]] = [:]
    
    private init() {
        loadLocalizedStrings()
        loadLanguagePreference()
    }
    
    // MARK: - Language Management
    func setLanguage(_ language: Language) {
        currentLanguage = language
        saveLanguagePreference()
        
        // Post notification to update UI
        NotificationCenter.default.post(name: .languageChanged, object: language)
    }
    
    private func saveLanguagePreference() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
    }
    
    private func loadLanguagePreference() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
    
    // MARK: - Localization
    func localizedString(for key: String, comment: String = "") -> String {
        let languageCode = currentLanguage.rawValue
        
        // First try to get from loaded strings
        if let languageStrings = localizedStrings[languageCode],
           let localizedString = languageStrings[key] {
            return localizedString
        }
        
        // Fallback to NSLocalizedString
        return NSLocalizedString(key, comment: comment)
    }
    
    // MARK: - String Loading
    private func loadLocalizedStrings() {
        // Load English strings
        if let enPath = Bundle.main.path(forResource: "Localizable", ofType: "strings"),
           let enStrings = NSDictionary(contentsOfFile: enPath) as? [String: String] {
            localizedStrings["en"] = enStrings
        }
        
        // Load Dutch strings
        if let nlPath = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: "nl.lproj"),
           let nlStrings = NSDictionary(contentsOfFile: nlPath) as? [String: String] {
            localizedStrings["nl"] = nlStrings
        }
    }
}

// MARK: - String Extension
extension String {
    /// Localized string using the current app language
    var localized: String {
        return LocalizationHelper.shared.localizedString(for: self)
    }
    
    /// Localized string with comment
    func localized(comment: String = "") -> String {
        return LocalizationHelper.shared.localizedString(for: self, comment: comment)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
