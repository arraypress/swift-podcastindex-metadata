//
//  PodcastIndexMetadata.swift
//  PodcastIndexMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation
import CryptoKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Search and discover podcasts through the [Podcast Index](https://podcastindex.org) API.
///
/// This is the discovery front-door RSS can't provide: find shows and episodes
/// by topic, list what's trending, and resolve a feed by URL, ID, or iTunes ID —
/// then hand the feed URL to your feed parser to pull episodes.
///
/// Podcast Index is free, but every request is signed with an API key + secret.
/// Get one at <https://api.podcastindex.org>, then pass credentials via
/// ``Configuration`` (or set `PODCAST_INDEX_KEY` / `PODCAST_INDEX_SECRET` in the
/// environment and use ``Configuration/default``).
///
/// ## Quick Start
///
/// ```swift
/// import PodcastIndexMetadata
///
/// let config = PodcastIndexMetadata.Configuration(apiKey: "…", apiSecret: "…")
///
/// // Find shows by topic
/// let shows = try await PodcastIndexMetadata.search("artificial intelligence", configuration: config)
/// for show in shows {
///     print(show.title, "—", show.episodeCount ?? 0, "episodes")
/// }
///
/// // Latest episodes for a show
/// let episodes = try await PodcastIndexMetadata.episodes(feedID: shows[0].id, configuration: config)
/// print(episodes.first?.title ?? "", episodes.first?.formattedDuration ?? "")
/// ```
public enum PodcastIndexMetadata {

    // MARK: - Configuration

    /// Credentials and networking options for the Podcast Index API.
    public struct Configuration: Sendable {

        /// The Podcast Index API key.
        public var apiKey: String?

        /// The Podcast Index API secret.
        public var apiSecret: String?

        /// The `User-Agent` sent with every request (required by the API).
        public var userAgent: String

        public init(
            apiKey: String? = nil,
            apiSecret: String? = nil,
            userAgent: String = "PodcastIndexMetadata/1.0"
        ) {
            self.apiKey = apiKey
            self.apiSecret = apiSecret
            self.userAgent = userAgent
        }

        /// Reads credentials from `PODCAST_INDEX_KEY` / `PODCAST_INDEX_SECRET`.
        public static var `default`: Configuration {
            let env = ProcessInfo.processInfo.environment
            return Configuration(
                apiKey: env["PODCAST_INDEX_KEY"],
                apiSecret: env["PODCAST_INDEX_SECRET"]
            )
        }
    }

    private static let base = "https://api.podcastindex.org/api/1.0"

    // MARK: - Search

    /// Searches podcasts by term (title, author, or owner).
    ///
    /// - Parameters:
    ///   - term: The search text.
    ///   - max: Maximum results (default 20).
    ///   - configuration: API credentials.
    /// - Returns: Matching ``PodcastFeed`` shows, most relevant first.
    public static func search(
        _ term: String,
        max: Int = 20,
        configuration: Configuration = .default
    ) async throws -> [PodcastFeed] {
        let data = try await get("/search/byterm", query: ["q": term, "max": String(max)], configuration: configuration)
        return try PIParser.feeds(from: data)
    }

    /// Searches podcasts by title only.
    public static func searchByTitle(
        _ title: String,
        max: Int = 20,
        configuration: Configuration = .default
    ) async throws -> [PodcastFeed] {
        let data = try await get("/search/bytitle", query: ["q": title, "max": String(max)], configuration: configuration)
        return try PIParser.feeds(from: data)
    }

    /// Searches recent episodes that mention a person (host or guest).
    public static func searchEpisodes(
        person: String,
        max: Int = 20,
        configuration: Configuration = .default
    ) async throws -> [PodcastEpisode] {
        let data = try await get("/search/byperson", query: ["q": person, "max": String(max)], configuration: configuration)
        return try PIParser.episodes(from: data)
    }

    // MARK: - Trending & recent

    /// Returns podcasts trending across the index.
    public static func trending(
        max: Int = 20,
        configuration: Configuration = .default
    ) async throws -> [PodcastFeed] {
        let data = try await get("/podcasts/trending", query: ["max": String(max)], configuration: configuration)
        return try PIParser.feeds(from: data)
    }

    /// Returns the most recently published episodes across the whole index.
    public static func recentEpisodes(
        max: Int = 20,
        configuration: Configuration = .default
    ) async throws -> [PodcastEpisode] {
        let data = try await get("/recent/episodes", query: ["max": String(max)], configuration: configuration)
        return try PIParser.episodes(from: data)
    }

    // MARK: - Lookup

    /// Resolves a podcast by its RSS feed URL.
    public static func podcast(
        feedURL: String,
        configuration: Configuration = .default
    ) async throws -> PodcastFeed {
        let data = try await get("/podcasts/byfeedurl", query: ["url": feedURL], configuration: configuration)
        return try PIParser.feed(from: data)
    }

    /// Resolves a podcast by its Podcast Index feed ID.
    public static func podcast(
        feedID: Int,
        configuration: Configuration = .default
    ) async throws -> PodcastFeed {
        let data = try await get("/podcasts/byfeedid", query: ["id": String(feedID)], configuration: configuration)
        return try PIParser.feed(from: data)
    }

    /// Resolves a podcast by its iTunes/Apple Podcasts collection ID.
    public static func podcast(
        itunesID: Int,
        configuration: Configuration = .default
    ) async throws -> PodcastFeed {
        let data = try await get("/podcasts/byitunesid", query: ["id": String(itunesID)], configuration: configuration)
        return try PIParser.feed(from: data)
    }

    // MARK: - Episodes

    /// Returns episodes for a podcast by its Podcast Index feed ID.
    public static func episodes(
        feedID: Int,
        max: Int = 50,
        configuration: Configuration = .default
    ) async throws -> [PodcastEpisode] {
        let data = try await get("/episodes/byfeedid", query: ["id": String(feedID), "max": String(max)], configuration: configuration)
        return try PIParser.episodes(from: data)
    }

    /// Returns episodes for a podcast by its RSS feed URL.
    public static func episodes(
        feedURL: String,
        max: Int = 50,
        configuration: Configuration = .default
    ) async throws -> [PodcastEpisode] {
        let data = try await get("/episodes/byfeedurl", query: ["url": feedURL, "max": String(max)], configuration: configuration)
        return try PIParser.episodes(from: data)
    }

    // MARK: - Networking

    private static func get(
        _ path: String,
        query: [String: String],
        configuration: Configuration
    ) async throws -> Data {
        guard let apiKey = configuration.apiKey, !apiKey.isEmpty,
              let apiSecret = configuration.apiSecret, !apiSecret.isEmpty else {
            throw PodcastIndexMetadataError.missingCredentials
        }

        var components = URLComponents(string: base + path)
        components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components?.url else {
            throw PodcastIndexMetadataError.networkError("Invalid URL")
        }

        // Auth: Authorization = SHA1(apiKey + apiSecret + unixTime); the same
        // timestamp goes in X-Auth-Date.
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let signature = sha1Hex(apiKey + apiSecret + timestamp)

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Auth-Key")
        request.setValue(timestamp, forHTTPHeaderField: "X-Auth-Date")
        request.setValue(signature, forHTTPHeaderField: "Authorization")
        request.setValue(configuration.userAgent, forHTTPHeaderField: "User-Agent")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw PodcastIndexMetadataError.networkError(error.localizedDescription)
        }

        if let http = response as? HTTPURLResponse {
            if http.statusCode == 401 { throw PodcastIndexMetadataError.unauthorized }
            if http.statusCode == 429 { throw PodcastIndexMetadataError.rateLimited }
            if http.statusCode != 200 {
                throw PodcastIndexMetadataError.networkError("HTTP \(http.statusCode)")
            }
        }
        return data
    }

    /// Hex-encoded SHA-1 of `string` (the Podcast Index auth scheme).
    static func sha1Hex(_ string: String) -> String {
        Insecure.SHA1.hash(data: Data(string.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
