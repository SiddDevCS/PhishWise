//
//  PhishWiseApp.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

@main
struct PhishWiseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Configure accessibility settings
                    configureAccessibility()
                }
        }
    }
    
    /// Configures accessibility settings for better user experience
    private func configureAccessibility() {
        // Enable accessibility features
        UIAccessibility.post(notification: .announcement, argument: "PhishWise app launched")
    }
}
