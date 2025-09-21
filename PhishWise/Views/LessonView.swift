//
//  LessonView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Lesson View
/// Displays learning modules with placeholder content
struct LessonView: View {
    @ObservedObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                            .accessibilityLabel("Learning Icon")
                        
                        Text(NSLocalizedString("lesson_title", comment: "Lesson title"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .padding(.top)
                    
                    // Placeholder Lesson Cards
                    VStack(spacing: 20) {
                        LessonCard(
                            title: "What is Phishing?",
                            titleNl: "Wat is Phishing?",
                            icon: "exclamationmark.triangle.fill",
                            color: .red,
                            appViewModel: appViewModel
                        )
                        
                        LessonCard(
                            title: "Common Phishing Techniques",
                            titleNl: "Veelvoorkomende Phishing Technieken",
                            icon: "eye.fill",
                            color: .orange,
                            appViewModel: appViewModel
                        )
                        
                        LessonCard(
                            title: "How to Protect Yourself",
                            titleNl: "Hoe Jezelf te Beschermen",
                            icon: "shield.fill",
                            color: .blue,
                            appViewModel: appViewModel
                        )
                        
                        LessonCard(
                            title: "Real Examples",
                            titleNl: "Echte Voorbeelden",
                            icon: "doc.text.fill",
                            color: .purple,
                            appViewModel: appViewModel
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle(NSLocalizedString("lessons", comment: "Lessons"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("back", comment: "Back")) {
                        appViewModel.navigateTo(.welcome)
                    }
                }
            }
        }
    }
}

// MARK: - Lesson Card
struct LessonCard: View {
    let title: String
    let titleNl: String
    let icon: String
    let color: Color
    @ObservedObject var appViewModel: AppViewModel
    @State private var isExpanded = false
    
    var localizedTitle: String {
        appViewModel.currentLanguage == .dutch ? titleNl : title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card Header
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(localizedTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Card Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(NSLocalizedString("lesson_placeholder", comment: "Lesson placeholder"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    // Placeholder for future content
                    Text(NSLocalizedString("coming_soon", comment: "Coming soon"))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.1))
                        .cornerRadius(8)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    LessonView(appViewModel: AppViewModel())
}
