# Phishing News API - Swift Integration Guide

Quick reference guide for integrating the Phishing News Digest API into your Swift iOS/macOS app.

## API Endpoint

**Base URL:** `https://phishing-news-api.fly.dev`

**Recommended Endpoint:** `/api/phishing-news/today`

## Quick Start

### 1. Data Models

Add these models to your Swift project:

```swift
import Foundation

struct DailyDigest: Codable {
    let date: String
    let generatedAt: String
    let summary: String
    let articles: [Article]
    let sources: [String]
    
    enum CodingKeys: String, CodingKey {
        case date
        case generatedAt = "generated_at"
        case summary
        case articles
        case sources
    }
}

struct Article: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let link: String
    let publishedDate: String
    let source: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case link
        case publishedDate = "published_date"
        case source
    }
    
    var publishedDateObject: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: publishedDate) ?? 
               formatter.date(from: publishedDate.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression))
    }
}
```

### 2. Fetch Today's News

```swift
func fetchTodayDigest() async throws -> DailyDigest {
    let url = URL(string: "https://phishing-news-api.fly.dev/api/phishing-news/today")!
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    return try JSONDecoder().decode(DailyDigest.self, from: data)
}
```

### 3. Usage in SwiftUI

```swift
import SwiftUI

struct PhishingNewsView: View {
    @State private var digest: DailyDigest?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else if let error = error {
                    Text("Error: \(error.localizedDescription)")
                } else if let digest = digest {
                    List {
                        // Summary
                        Section("Summary") {
                            Text(digest.summary)
                        }
                        
                        // Articles
                        Section("Articles (\(digest.articles.count))") {
                            ForEach(digest.articles) { article in
                                ArticleRow(article: article)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Phishing News")
            .refreshable {
                await loadDigest()
            }
        }
        .task {
            await loadDigest()
        }
    }
    
    func loadDigest() async {
        isLoading = true
        error = nil
        
        do {
            digest = try await fetchTodayDigest()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
            
            Text(article.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(article.source)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if let date = article.publishedDateObject {
                    Text(date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onTapGesture {
            if let url = URL(string: article.link) {
                UIApplication.shared.open(url)
            }
        }
    }
}
```

## API Endpoints

### Get Today's Digest (Recommended)
```swift
GET https://phishing-news-api.fly.dev/api/phishing-news/today
```

### Get Latest Digest
```swift
GET https://phishing-news-api.fly.dev/api/phishing-news/latest
```

### Get Digest by Date
```swift
GET https://phishing-news-api.fly.dev/api/phishing-news/{date}
// Example: /api/phishing-news/2026-01-21
```

### List All Digests
```swift
GET https://phishing-news-api.fly.dev/api/phishing-news?limit=10
```

## Complete Service Class

```swift
class PhishingNewsService {
    static let shared = PhishingNewsService()
    private let baseURL = "https://phishing-news-api.fly.dev"
    
    private init() {}
    
    func fetchTodayDigest() async throws -> DailyDigest {
        let url = URL(string: "\(baseURL)/api/phishing-news/today")!
        return try await fetchDigest(from: url)
    }
    
    func fetchLatestDigest() async throws -> DailyDigest {
        let url = URL(string: "\(baseURL)/api/phishing-news/latest")!
        return try await fetchDigest(from: url)
    }
    
    func fetchDigest(for date: Date) async throws -> DailyDigest {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let url = URL(string: "\(baseURL)/api/phishing-news/\(dateString)")!
        return try await fetchDigest(from: url)
    }
    
    private func fetchDigest(from url: URL) async throws -> DailyDigest {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(DailyDigest.self, from: data)
        case 404:
            throw PhishingNewsError.notFound
        case 429:
            throw PhishingNewsError.rateLimited
        default:
            throw URLError(.badServerResponse)
        }
    }
}

enum PhishingNewsError: LocalizedError {
    case notFound
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "No digest available for this date"
        case .rateLimited:
            return "Too many requests. Please try again later."
        }
    }
}
```

## Response Format

```json
{
  "date": "2026-01-21",
  "generated_at": "2026-01-21T10:23:47.901756",
  "summary": "Today's phishing landscape reveals...",
  "articles": [
    {
      "title": "Article Title",
      "description": "Article description...",
      "link": "https://example.com/article",
      "published_date": "2026-01-21T10:00:00Z",
      "source": "source-name.com"
    }
  ],
  "sources": [
    "https://cofense.com/feed/",
    "https://krebsonsecurity.com/feed/"
  ]
}
```

## Error Handling

### Handle 404 (No Digest Available)

```swift
do {
    let digest = try await fetchTodayDigest()
    // Use digest
} catch PhishingNewsError.notFound {
    // Show "No digest available" message
    showEmptyState()
} catch {
    // Handle other errors
    showError(error)
}
```

### Handle Rate Limiting (429)

The API limits to 60 requests per minute. If you get a 429 error:

```swift
catch PhishingNewsError.rateLimited {
    // Wait and retry, or show cached data
    await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    // Retry or use cached data
}
```

## Best Practices

1. **Cache Responses**: Digests don't change once generated, so cache them locally
2. **Handle 404 Gracefully**: Show a friendly "No digest available" message
3. **Refresh on Launch**: Check for new digests when the app opens
4. **Display Date**: Show users which date they're viewing
5. **Open Articles**: Use `UIApplication.shared.open(url)` to open article links

## Caching Example

```swift
class CachedPhishingNewsService {
    static let shared = CachedPhishingNewsService()
    private let service = PhishingNewsService.shared
    private var cache: [String: DailyDigest] = [:]
    
    func fetchTodayDigest(forceRefresh: Bool = false) async throws -> DailyDigest {
        let today = DateFormatter.todayString
        
        // Return cached if available and not forcing refresh
        if !forceRefresh, let cached = cache[today] {
            return cached
        }
        
        // Fetch fresh data
        let digest = try await service.fetchTodayDigest()
        cache[today] = digest
        return digest
    }
}

extension DateFormatter {
    static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
```

## Testing

Test the API directly:

```bash
# Get today's digest
curl https://phishing-news-api.fly.dev/api/phishing-news/today

# Check API status
curl https://phishing-news-api.fly.dev/
```

## Support

- **API Status**: `https://phishing-news-api.fly.dev/`
- **Full Documentation**: See `SWIFT_INTEGRATION.md` for complete examples
- **Rate Limit**: 60 requests/minute per IP

## Example: Complete SwiftUI App

```swift
import SwiftUI

@main
struct PhishingNewsApp: App {
    var body: some Scene {
        WindowGroup {
            PhishingNewsView()
        }
    }
}
```

That's it! Your Swift app can now fetch and display phishing news digests.
