//
//  PIParser.swift
//  PodcastIndexMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Parses Podcast Index JSON responses into the library's models.
///
/// The API returns a `status`, a `count`, and either a `feed`/`feeds` payload or
/// an `items` payload depending on the endpoint. This handles both singular and
/// plural shapes and is defensive about the loosely-typed values the API uses
/// (e.g. `explicit` arrives as a bool on some endpoints and `0`/`1` on others).
enum PIParser {

    // MARK: - Feeds

    /// Parses a list endpoint (`feeds`).
    static func feeds(from data: Data) throws(PodcastIndexMetadataError) -> [PodcastFeed] {
        let root = try object(from: data)
        let array = (root["feeds"] as? [[String: Any]]) ?? []
        return array.map(parseFeed)
    }

    /// Parses a single-feed endpoint (`feed`), which may itself be an array of one.
    static func feed(from data: Data) throws(PodcastIndexMetadataError) -> PodcastFeed {
        let root = try object(from: data)
        if let dict = root["feed"] as? [String: Any] {
            return parseFeed(dict)
        }
        if let array = root["feed"] as? [[String: Any]], let first = array.first {
            return parseFeed(first)
        }
        throw .notFound
    }

    private static func parseFeed(_ dict: [String: Any]) -> PodcastFeed {
        PodcastFeed(
            id: int(dict["id"]) ?? 0,
            title: string(dict["title"]) ?? "",
            url: string(dict["url"]) ?? "",
            website: string(dict["link"]),
            description: string(dict["description"]) ?? "",
            author: string(dict["author"]),
            ownerName: string(dict["ownerName"]),
            imageURL: string(dict["artwork"]) ?? string(dict["image"]),
            language: string(dict["language"]),
            categories: categories(dict["categories"]),
            episodeCount: int(dict["episodeCount"]),
            itunesID: int(dict["itunesId"]),
            isExplicit: bool(dict["explicit"]),
            lastUpdated: date(dict["lastUpdateTime"])
        )
    }

    // MARK: - Episodes

    /// Parses an episodes endpoint (`items`).
    static func episodes(from data: Data) throws(PodcastIndexMetadataError) -> [PodcastEpisode] {
        let root = try object(from: data)
        let array = (root["items"] as? [[String: Any]]) ?? []
        return array.map(parseEpisode)
    }

    private static func parseEpisode(_ dict: [String: Any]) -> PodcastEpisode {
        PodcastEpisode(
            id: int(dict["id"]) ?? 0,
            title: string(dict["title"]) ?? "",
            link: string(dict["link"]),
            description: string(dict["description"]) ?? "",
            guid: string(dict["guid"]),
            datePublished: date(dict["datePublished"]),
            enclosureURL: string(dict["enclosureUrl"]),
            enclosureType: string(dict["enclosureType"]),
            enclosureLength: int(dict["enclosureLength"]),
            durationInSeconds: int(dict["duration"]),
            episode: int(dict["episode"]),
            season: int(dict["season"]),
            episodeType: string(dict["episodeType"]),
            imageURL: nonEmpty(string(dict["image"])) ?? string(dict["feedImage"]),
            feedID: int(dict["feedId"]),
            feedTitle: string(dict["feedTitle"])
        )
    }

    // MARK: - Value helpers

    private static func object(from data: Data) throws(PodcastIndexMetadataError) -> [String: Any] {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            throw .parsingError("Response was not a JSON object")
        }
        return json
    }

    private static func string(_ value: Any?) -> String? {
        (value as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    private static func nonEmpty(_ value: String?) -> String? {
        value.flatMap { $0.isEmpty ? nil : $0 }
    }

    private static func int(_ value: Any?) -> Int? {
        if let i = value as? Int { return i }
        if let n = value as? NSNumber { return n.intValue }
        if let s = value as? String { return Int(s) }
        return nil
    }

    private static func bool(_ value: Any?) -> Bool? {
        if let b = value as? Bool { return b }
        if let i = int(value) { return i != 0 }
        return nil
    }

    /// Podcast Index dates are Unix timestamps (seconds).
    private static func date(_ value: Any?) -> Date? {
        guard let seconds = int(value), seconds > 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(seconds))
    }

    /// `categories` is a `{ "9": "Business", "77": "Marketing" }` map; keep the
    /// labels in a stable order.
    private static func categories(_ value: Any?) -> [String] {
        guard let map = value as? [String: Any] else { return [] }
        return map.keys.sorted { (Int($0) ?? 0) < (Int($1) ?? 0) }
            .compactMap { string(map[$0]) }
    }
}
