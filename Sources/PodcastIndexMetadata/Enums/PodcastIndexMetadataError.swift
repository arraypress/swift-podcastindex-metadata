//
//  PodcastIndexMetadataError.swift
//  PodcastIndexMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Errors that can occur when calling the Podcast Index API.
///
/// ```swift
/// do {
///     let shows = try await PodcastIndexMetadata.search("swift")
/// } catch PodcastIndexMetadataError.missingCredentials {
///     print("Set an API key and secret")
/// } catch {
///     print(error.localizedDescription)
/// }
/// ```
public enum PodcastIndexMetadataError: Error, LocalizedError, Equatable, Sendable {

    /// No API key/secret was provided (via ``PodcastIndexMetadata/Configuration``
    /// or the `PODCAST_INDEX_KEY` / `PODCAST_INDEX_SECRET` environment variables).
    case missingCredentials

    /// The API rejected the credentials (HTTP 401).
    case unauthorized

    /// Podcast Index is rate-limiting requests (HTTP 429).
    case rateLimited

    /// The requested podcast or episode was not found.
    case notFound

    /// A network request failed.
    case networkError(String)

    /// Failed to parse the response data.
    case parsingError(String)

    public var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Missing Podcast Index credentials. Provide an apiKey and apiSecret (or set PODCAST_INDEX_KEY / PODCAST_INDEX_SECRET)."
        case .unauthorized:
            return "Podcast Index rejected the credentials (401). Check your API key and secret."
        case .rateLimited:
            return "Podcast Index is rate-limiting requests. Try again later."
        case .notFound:
            return "The requested podcast or episode was not found."
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}
