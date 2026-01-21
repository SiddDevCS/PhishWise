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
        let (data, response) = try await Self.session.data(from: url)

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
