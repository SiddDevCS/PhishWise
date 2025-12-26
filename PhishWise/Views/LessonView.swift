//
//  LessonView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Lesson View
/// Displays learning modules with educational content
struct LessonView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var lessonDataManager = LessonDataManager()
    
    var body: some View {
        NavigationView {
            Group {
                if lessonDataManager.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("loading_lessons".localized)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = lessonDataManager.error {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("error_loading_lessons".localized)
                            .font(.headline)
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("try_again".localized) {
                            lessonDataManager.loadLessons()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.title3)
                        .padding()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            VStack(spacing: 16) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                    .accessibilityLabel("Learning Icon")
                                
                                Text("lesson_title".localized)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .accessibilityAddTraits(.isHeader)
                            }
                            .padding(.top)
                            
                            // Lesson Cards
                            VStack(spacing: 20) {
                                ForEach(lessonDataManager.lessons) { lesson in
                                    LessonCardView(
                                        lesson: lesson,
                                        appViewModel: appViewModel
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 100)
                        }
                    }
                }
            }
            .navigationTitle("lessons".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("back".localized) {
                        appViewModel.navigateTo(.welcome)
                    }
                    .font(.title3)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

// MARK: - Lesson Card View
struct LessonCardView: View {
    let lesson: Lesson
    @ObservedObject var appViewModel: AppViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Card Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: lesson.icon)
                        .font(.title2)
                        .foregroundColor(lesson.color)
                        .frame(width: 40)
                    
                    Text(lesson.title(for: appViewModel.currentLanguage))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Card Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(lesson.content(for: appViewModel.currentLanguage).enumerated()), id: \.offset) { index, section in
                        LessonSectionView(section: section, language: appViewModel.currentLanguage, color: lesson.color)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lesson.color.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Lesson Section View
struct LessonSectionView: View {
    let section: LessonSection
    let language: Language
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = section.title(for: language) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(section.text(for: language))
                .font(.body)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            Group {
                switch section.type {
                case "example":
                    Color.orange.opacity(0.1)
                case "tip":
                    Color.blue.opacity(0.1)
                default:
                    Color(.systemGray6)
                }
            }
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    section.type == "example" ? Color.orange.opacity(0.3) :
                    section.type == "tip" ? Color.blue.opacity(0.3) :
                    Color.clear,
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Preview
#Preview {
    LessonView(appViewModel: AppViewModel())
}
