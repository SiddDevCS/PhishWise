# Swift Integration Guide

Complete guide for integrating the Phishing News Digest API into your Swift iOS/macOS app.

## API Base URL

```
https://phishing-news-api.fly.dev
```

## Quick Start

### 1. Recommended Endpoint

Use `/api/phishing-news/today` to get today's phishing news digest.

### 2. Basic Swift Implementation

```swift
import Foundation

// MARK: - Data Models

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
    
    // Computed property for Date object
    var publishedDateObject: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: publishedDate) ?? formatter.date(from: publishedDate.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression))
    }
    
    // Computed property for formatted date string
    var formattedDate: String {
        guard let date = publishedDateObject else { return publishedDate }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - API Service

class PhishingNewsService {
    static let shared = PhishingNewsService()
    
    private let baseURL = "https://phishing-news-api.fly.dev"
    
    private init() {}
    
    // MARK: - Get Today's Digest
    
    func fetchTodayDigest() async throws -> DailyDigest {
        let url = URL(string: "\(baseURL)/api/phishing-news/today")!
        return try await fetchDigest(from: url)
    }
    
    // MARK: - Get Latest Digest
    
    func fetchLatestDigest() async throws -> DailyDigest {
        let url = URL(string: "\(baseURL)/api/phishing-news/latest")!
        return try await fetchDigest(from: url)
    }
    
    // MARK: - Get Digest by Date
    
    func fetchDigest(for date: Date) async throws -> DailyDigest {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let url = URL(string: "\(baseURL)/api/phishing-news/\(dateString)")!
        return try await fetchDigest(from: url)
    }
    
    // MARK: - List Available Digests
    
    func listDigests(limit: Int = 10) async throws -> [DigestSummary] {
        let url = URL(string: "\(baseURL)/api/phishing-news?limit=\(limit)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(DigestListResponse.self, from: data)
        return result.digests
    }
    
    // MARK: - Private Helper
    
    private func fetchDigest(from url: URL) async throws -> DailyDigest {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(DailyDigest.self, from: data)
        case 404:
            throw APIError.notFound
        case 429:
            throw APIError.rateLimited
        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
}

// MARK: - Supporting Models

struct DigestListResponse: Codable {
    let count: Int
    let digests: [DigestSummary]
}

struct DigestSummary: Codable, Identifiable {
    let id = UUID()
    let date: String
    let generatedAt: String
    let articleCount: Int
    let sourceCount: Int
    
    enum CodingKeys: String, CodingKey {
        case date
        case generatedAt = "generated_at"
        case articleCount = "article_count"
        case sourceCount = "source_count"
    }
}

// MARK: - Error Handling

enum APIError: LocalizedError {
    case invalidResponse
    case notFound
    case rateLimited
    case httpError(Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .notFound:
            return "No digest available for this date"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
```

## SwiftUI Example

### Complete SwiftUI View

```swift
import SwiftUI

struct PhishingNewsView: View {
    @StateObject private var viewModel = PhishingNewsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading today's phishing news...")
                    
                case .loaded(let digest):
                    DigestContentView(digest: digest)
                    
                case .error(let error):
                    ErrorView(error: error, retry: viewModel.loadToday)
                    
                case .empty:
                    EmptyStateView()
                }
            }
            .navigationTitle("Phishing News")
            .refreshable {
                await viewModel.loadToday()
            }
        }
        .task {
            await viewModel.loadToday()
        }
    }
}

// MARK: - View Model

@MainActor
class PhishingNewsViewModel: ObservableObject {
    @Published var state: LoadingState = .loading
    
    enum LoadingState {
        case loading
        case loaded(DailyDigest)
        case error(Error)
        case empty
    }
    
    private let service = PhishingNewsService.shared
    
    func loadToday() async {
        state = .loading
        
        do {
            let digest = try await service.fetchTodayDigest()
            state = .loaded(digest)
        } catch APIError.notFound {
            state = .empty
        } catch {
            state = .error(error)
        }
    }
}

// MARK: - Content Views

struct DigestContentView: View {
    let digest: DailyDigest
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Summary Section
                SummaryCard(summary: digest.summary)
                
                // Articles List
                ArticlesList(articles: digest.articles)
            }
            .padding()
        }
    }
}

struct SummaryCard: View {
    let summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Summary")
                .font(.headline)
            
            Text(summary)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ArticlesList: View {
    let articles: [Article]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Articles (\(articles.count))")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(articles) { article in
                ArticleRow(article: article)
            }
        }
    }
}

struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(article.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(article.source)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(article.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
        .onTapGesture {
            if let url = URL(string: article.link) {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    let retry: () async -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error Loading News")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await retry()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Digest Available")
                .font(.headline)
            
            Text("Today's digest hasn't been generated yet. Please check back later.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}
```

## UIKit Example

### View Controller Implementation

```swift
import UIKit

class PhishingNewsViewController: UIViewController {
    private let tableView = UITableView()
    private var digest: DailyDigest?
    private let service = PhishingNewsService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadToday()
    }
    
    private func setupUI() {
        title = "Phishing News"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArticleCell.self, forCellReuseIdentifier: "ArticleCell")
        tableView.register(SummaryHeaderView.self, forHeaderFooterViewReuseIdentifier: "SummaryHeader")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refresh() {
        loadToday()
    }
    
    private func loadToday() {
        Task {
            do {
                let digest = try await service.fetchTodayDigest()
                await MainActor.run {
                    self.digest = digest
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PhishingNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return digest != nil ? 2 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let digest = digest else { return 0 }
        return section == 0 ? 0 : digest.articles.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0, let digest = digest else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SummaryHeader") as? SummaryHeaderView
        header?.configure(with: digest.summary)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? UITableView.automaticDimension : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        if let article = digest?.articles[indexPath.row] {
            cell.configure(with: article)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let article = digest?.articles[indexPath.row],
           let url = URL(string: article.link) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Custom Cells

class SummaryHeaderView: UITableViewHeaderFooterView {
    private let summaryLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        summaryLabel.numberOfLines = 0
        summaryLabel.font = .systemFont(ofSize: 16)
        summaryLabel.textColor = .secondaryLabel
        
        contentView.addSubview(summaryLabel)
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            summaryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with summary: String) {
        summaryLabel.text = summary
    }
}

class ArticleCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let sourceLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 3
        
        sourceLabel.font = .systemFont(ofSize: 12)
        sourceLabel.textColor = .systemBlue
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, sourceLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        sourceLabel.text = article.source
        dateLabel.text = article.formattedDate
    }
}
```

## Advanced Features

### Caching

```swift
class CachedPhishingNewsService {
    static let shared = CachedPhishingNewsService()
    
    private let service = PhishingNewsService.shared
    private var cache: [String: DailyDigest] = [:]
    private var cacheDate: [String: Date] = [:]
    private let cacheExpiration: TimeInterval = 3600 // 1 hour
    
    private init() {}
    
    func fetchTodayDigest(forceRefresh: Bool = false) async throws -> DailyDigest {
        let today = DateFormatter.todayString
        
        // Check cache
        if !forceRefresh,
           let cached = cache[today],
           let cachedDate = cacheDate[today],
           Date().timeIntervalSince(cachedDate) < cacheExpiration {
            return cached
        }
        
        // Fetch fresh data
        let digest = try await service.fetchTodayDigest()
        
        // Update cache
        cache[today] = digest
        cacheDate[today] = Date()
        
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

### Offline Support

```swift
import Foundation

class PersistentPhishingNewsService {
    static let shared = PersistentPhishingNewsService()
    
    private let service = PhishingNewsService.shared
    private let cacheFile: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheFile = documentsPath.appendingPathComponent("phishing_news_cache.json")
    }
    
    func fetchTodayDigest() async throws -> DailyDigest {
        // Try to fetch from API
        do {
            let digest = try await service.fetchTodayDigest()
            // Save to disk
            try saveToDisk(digest)
            return digest
        } catch {
            // If API fails, try to load from disk
            if let cached = loadFromDisk() {
                return cached
            }
            throw error
        }
    }
    
    private func saveToDisk(_ digest: DailyDigest) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(digest)
        try data.write(to: cacheFile)
    }
    
    private func loadFromDisk() -> DailyDigest? {
        guard let data = try? Data(contentsOf: cacheFile) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(DailyDigest.self, from: data)
    }
}
```

## Error Handling Best Practices

```swift
extension PhishingNewsService {
    func fetchTodayDigestWithRetry(maxRetries: Int = 3) async throws -> DailyDigest {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await fetchTodayDigest()
            } catch {
                lastError = error
                
                // Don't retry on certain errors
                if case APIError.notFound = error {
                    throw error
                }
                
                // Wait before retry (exponential backoff)
                if attempt < maxRetries {
                    let delay = pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? APIError.invalidResponse
    }
}
```

## Response Format Reference

### DailyDigest Structure

```swift
{
    "date": "2026-01-21",                    // YYYY-MM-DD format
    "generated_at": "2026-01-21T10:23:47...", // ISO 8601 timestamp
    "summary": "Today's phishing landscape...", // AI-generated summary
    "articles": [                             // Array of articles
        {
            "title": "Article Title",
            "description": "Article description...",
            "link": "https://example.com/article",
            "published_date": "2026-01-21T10:00:00Z",
            "source": "source-name.com"
        }
    ],
    "sources": [                              // RSS feed sources used
        "https://cofense.com/feed/",
        "https://krebsonsecurity.com/feed/"
    ]
}
```

## API Endpoints Summary

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/phishing-news/today` | GET | Get today's digest (recommended) |
| `/api/phishing-news/latest` | GET | Get most recent digest |
| `/api/phishing-news/{date}` | GET | Get digest for specific date (YYYY-MM-DD) |
| `/api/phishing-news` | GET | List available digests |

## Rate Limiting

- Default: 60 requests per minute per IP
- If exceeded: Returns HTTP 429 (Too Many Requests)
- Recommendation: Cache responses in your app

## Best Practices

1. **Cache responses**: Digests don't change once generated
2. **Handle 404 gracefully**: Show "No digest available" message
3. **Refresh on app launch**: Check for new digests when user opens app
4. **Display date**: Show users which date they're viewing
5. **Link to articles**: Use the `link` field to open full articles in Safari
6. **Error handling**: Implement retry logic for network errors
7. **Offline support**: Cache last successful response for offline viewing

## Example: Complete App Structure

```
PhishingNewsApp/
├── Models/
│   ├── DailyDigest.swift
│   ├── Article.swift
│   └── APIError.swift
├── Services/
│   └── PhishingNewsService.swift
├── Views/
│   ├── PhishingNewsView.swift
│   ├── ArticleDetailView.swift
│   └── Components/
│       ├── ArticleRow.swift
│       └── SummaryCard.swift
└── ViewModels/
    └── PhishingNewsViewModel.swift
```

## Testing

### Unit Test Example

```swift
import XCTest
@testable import YourApp

class PhishingNewsServiceTests: XCTestCase {
    var service: PhishingNewsService!
    
    override func setUp() {
        super.setUp()
        service = PhishingNewsService.shared
    }
    
    func testFetchTodayDigest() async throws {
        let digest = try await service.fetchTodayDigest()
        
        XCTAssertNotNil(digest)
        XCTAssertFalse(digest.date.isEmpty)
        XCTAssertFalse(digest.summary.isEmpty)
        XCTAssertFalse(digest.articles.isEmpty)
    }
    
    func testArticleDecoding() throws {
        let json = """
        {
            "title": "Test Article",
            "description": "Test description",
            "link": "https://example.com",
            "published_date": "2026-01-21T10:00:00Z",
            "source": "test.com"
        }
        """.data(using: .utf8)!
        
        let article = try JSONDecoder().decode(Article.self, from: json)
        XCTAssertEqual(article.title, "Test Article")
    }
}
```

## Troubleshooting

### Common Issues

1. **404 Not Found**
   - Today's digest hasn't been generated yet
   - Solution: Show empty state or use `/latest` endpoint

2. **429 Rate Limited**
   - Too many requests
   - Solution: Implement caching, reduce request frequency

3. **Network Errors**
   - No internet connection
   - Solution: Implement offline caching, show cached data

4. **Decoding Errors**
   - API response format changed
   - Solution: Check API version, update models

## Support

- **API Status**: Check `https://phishing-news-api.fly.dev/`
- **Documentation**: See `README.md` and `QUICK_START.md`
- **Issues**: Check logs via Fly.io dashboard
