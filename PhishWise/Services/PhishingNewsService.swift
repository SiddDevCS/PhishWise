//
//  PhishingNewsService.swift
//  PhishWise
//
//  Fetches phishing news from the custom Fly app: https://phishing-news-api.fly.dev
//

import Foundation

// MARK: - API Models

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

struct Article: Codable, Identifiable, Equatable {
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

    /// Stable id for Identifiable; not in JSON (README uses UUID() which doesn't work with Codable)
    var id: String { link }

    var publishedDateObject: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: publishedDate)
            ?? formatter.date(from: publishedDate.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression))
    }

    var formattedDate: String {
        guard let date = publishedDateObject else { return publishedDate }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - List Endpoint Models (GET /api/phishing-news)

struct DigestSummary: Codable {
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

struct DigestListResponse: Codable {
    let count: Int
    let digests: [DigestSummary]
}

// MARK: - API Error Response (README: error + detail in JSON)

struct APIErrorResponse: Codable {
    let error: String?
    let detail: String?
}

// MARK: - API Errors (README: PhishingNewsError with notFound, rateLimited)

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

// MARK: - Phishing News Service

class PhishingNewsService {
    static let shared = PhishingNewsService()

    private let baseURL = "https://phishing-news-api.fly.dev"

    private static let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 25
        c.timeoutIntervalForResource = 60
        return URLSession(configuration: c)
    }()

    private init() {}

    func fetchTodayDigest() async throws -> DailyDigest {
        let todayURL = URL(string: "\(baseURL)/api/phishing-news/today")!
        do {
            return try await fetchDigest(from: todayURL)
        } catch {
            // /today may 404, 500, or be unimplemented; fall back to /api/phishing-news/{yyyy-MM-dd}
            return try await fetchDigest(for: Date())
        }
    }

    func fetchLatestDigest() async throws -> DailyDigest {
        let url = URL(string: "\(baseURL)/api/phishing-news/latest")!
        return try await fetchDigest(from: url)
    }

    func fetchDigest(for date: Date) async throws -> DailyDigest {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = formatter.string(from: date)
        let url = URL(string: "\(baseURL)/api/phishing-news/\(dateString)")!
        return try await fetchDigest(from: url)
    }

    /// GET /api/phishing-news?limit= — list available digests for date picker (README §4).
    func listDigests(limit: Int = 20) async throws -> DigestListResponse {
        var components = URLComponents(string: "\(baseURL)/api/phishing-news")!
        components.queryItems = [URLQueryItem(name: "limit", value: "\(min(limit, 50))")]
        let url = components.url!
        let (data, http) = try await dataAndResponse(for: url)
        switch http.statusCode {
        case 200:
            return try JSONDecoder().decode(DigestListResponse.self, from: data)
        case 429:
            throw PhishingNewsError.rateLimited
        default:
            throw parseAPIError(data: data) ?? Self.httpError(http.statusCode)
        }
    }

    private func fetchDigest(from url: URL) async throws -> DailyDigest {
        let (data, http) = try await dataAndResponse(for: url)
        switch http.statusCode {
        case 200:
            return try JSONDecoder().decode(DailyDigest.self, from: data)
        case 404:
            throw PhishingNewsError.notFound
        case 429:
            throw PhishingNewsError.rateLimited
        default:
            throw parseAPIError(data: data) ?? Self.httpError(http.statusCode)
        }
    }

    /// Uses dataTask so 4xx/5xx return (data, response). Adds Accept: application/json. Avoids URLError(.badServerResponse) (-1011).
    private func dataAndResponse(for url: URL) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await withCheckedThrowingContinuation { continuation in
            Self.session.dataTask(with: request) { data, response, error in
                if let error = error as NSError? {
                    if error.domain == NSURLErrorDomain && error.code == -1011 {
                        continuation.resume(throwing: Self.httpError(0, system: "The server’s response could not be read. Try again or pick a date from the menu."))
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                guard let data = data, let http = response as? HTTPURLResponse else {
                    continuation.resume(throwing: Self.httpError(0, system: "Invalid response from server."))
                    return
                }
                continuation.resume(returning: (data, http))
            }.resume()
        }
    }

    private static func httpError(_ statusCode: Int, system: String? = nil) -> Error {
        let msg = system ?? (statusCode > 0 ? "Server returned HTTP \(statusCode)." : "Invalid response from server.")
        return NSError(domain: "PhishingNewsService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
    }

    private func parseAPIError(data: Data) -> (any Error)? {
        guard let body = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
              let msg = body.detail ?? body.error, !msg.isEmpty else { return nil }
        return NSError(domain: "PhishingNewsService", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}

// MARK: - String HTML stripping
/// Removes HTML tags and decodes common entities so RSS content (e.g. Cofense, INKY) displays as plain text.
extension String {
    var strippingHTML: String {
        let s = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return self }
        let withoutTags = s.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        let collapsed = withoutTags.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return collapsed
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
    }
}
