//
//  NewsDetailView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - News Detail View
/// Displays the full content of a news article
struct NewsDetailView: View {
    let article: NewsArticle
    let language: Language
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        // Category and Date
                        HStack {
                            Text(article.category)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(12)
                            
                            Spacer()
                            
                            Text(article.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Title
                        Text(article.title(for: language))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityHeading(.h1)
                    }
                    .padding(.horizontal)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.content(for: language))
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    // Footer
                    VStack(spacing: 12) {
                        Divider()
                        
                        Text(NSLocalizedString("stay_informed", comment: "Stay informed"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(NSLocalizedString("phishing_awareness_tip", comment: "Phishing awareness tip"))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle(NSLocalizedString("article", comment: "Article"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("close", comment: "Close")) {
                        dismiss()
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Share functionality could be added here
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel(NSLocalizedString("share_article", comment: "Share article"))
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleArticle = NewsArticle(
        id: 1,
        titleEn: "Sample Article",
        titleNl: "Voorbeeld Artikel",
        summaryEn: "This is a sample article summary",
        summaryNl: "Dit is een voorbeeld artikel samenvatting",
        contentEn: "This is the full content of the sample article.",
        contentNl: "Dit is de volledige inhoud van het voorbeeld artikel.",
        date: "2025-01-15",
        category: "Sample"
    )
    
    NewsDetailView(
        article: sampleArticle,
        language: .english,
        onDismiss: {}
    )
}
