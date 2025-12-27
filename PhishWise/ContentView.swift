//
//  ContentView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Main Content View
/// Root view that manages the main TabView structure
struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        Group {
            if appViewModel.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(appViewModel)
            } else {
                OnboardingView(appViewModel: appViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
