//
//  NewsDetailView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - News Detail View
/// Displays a phishing article from the Fly API; opens the full article in Safari
struct NewsDetailView: View {
    let article: Article
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(article.source)
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

                        Text(article.title.strippingHTML)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityHeading(.h1)
                    }
                    .padding(.horizontal)

                    // Description
                    Text(article.description.strippingHTML)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .padding(.horizontal)

                    // Read Full Article
                    if let url = URL(string: article.link) {
                        Button(action: {
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Image(systemName: "safari")
                                Text("read_full_article".localized)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .accessibilityLabel("read_full_article".localized)
                        .accessibilityHint("Opens the article in Safari")
                    }

                    // Footer
                    VStack(spacing: 12) {
                        Divider()

                        Text("stay_informed".localized)
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("phishing_awareness_tip".localized)
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
            .navigationTitle("article".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("close".localized) {
                        dismiss()
                        onDismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if let url = URL(string: article.link) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("share_article".localized)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NewsDetailView(
        article: Article(
            title: "Sample Phishing Campaign Targets Banks",
            description: "Security researchers have identified a new phishing campaign targeting customers of major banks with sophisticated fake login pages.",
            link: "https://example.com/article",
            publishedDate: "2025-01-21T10:00:00Z",
            source: "Security Blog"
        ),
        onDismiss: {}
    )
}
