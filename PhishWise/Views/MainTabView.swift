//
//  MainTabView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Main Tab View
/// Root view with TabView containing News and Course sections
struct MainTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab: TabSelection = .news
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // News Tab
            NewsListView(appViewModel: appViewModel)
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("phishing_news".localized)
                }
                .tag(TabSelection.news)
                .accessibilityLabel("phishing_news".localized)
            
            // Course Tab
            CourseTabView(appViewModel: appViewModel)
                .tabItem {
                    Image(systemName: "graduationcap")
                    Text("course_certificate".localized)
                }
                .tag(TabSelection.course)
                .accessibilityLabel("course_certificate".localized)
            
            // Settings Tab
            SettingsView(appViewModel: appViewModel)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("settings".localized)
                }
                .tag(TabSelection.settings)
                .accessibilityLabel("settings".localized)
        }
        .preferredColorScheme(.light) // Force light mode for high contrast
        .dynamicTypeSize(.large ... .accessibility3) // Support Dynamic Type
    }
}

// MARK: - Course Tab View
/// Contains the course-related views (welcome, lessons, quiz, progress, certificate)
struct CourseTabView: View {
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        Group {
            switch appViewModel.currentView {
            case .welcome:
                WelcomeView(appViewModel: appViewModel)
            case .lessons:
                LessonView(appViewModel: appViewModel)
            case .quiz:
                QuizView(appViewModel: appViewModel)
            case .feedback:
                // Feedback is handled as a sheet in QuizView
                EmptyView()
            case .progress:
                PhishWiseProgressView(appViewModel: appViewModel)
            case .certificate:
                CertificateView(appViewModel: appViewModel)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}
