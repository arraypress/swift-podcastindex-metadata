//
//  PodcastFeed.swift
//  PodcastIndexMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A podcast show as indexed by Podcast Index.
///
/// Hand ``url`` (the RSS feed URL) to a feed parser to pull the full episode
/// list, or use ``PodcastIndexMetadata/episodes(feedID:max:configuration:)``.
public struct PodcastFeed: Sendable, Codable, Identifiable {

    /// The Podcast Index feed ID.
    public let id: Int

    /// The show title.
    public let title: String

    /// The RSS feed URL.
    public let url: String

    /// The show's website, when provided.
    public let website: String?

    /// The show description.
    public let description: String

    /// The show author.
    public let author: String?

    /// The owner name (podcast:owner / itunes:owner), when provided.
    public let ownerName: String?

    /// The show artwork URL.
    public let imageURL: String?

    /// The primary language (e.g. `"en-us"`).
    public let language: String?

    /// Category labels.
    public let categories: [String]

    /// The number of episodes indexed, when known.
    public let episodeCount: Int?

    /// The iTunes/Apple Podcasts collection ID, when known.
    public let itunesID: Int?

    /// Whether the show is flagged explicit.
    public let isExplicit: Bool?

    /// When the feed was last updated.
    public let lastUpdated: Date?

    public init(
        id: Int,
        title: String,
        url: String,
        website: String? = nil,
        description: String = "",
        author: String? = nil,
        ownerName: String? = nil,
        imageURL: String? = nil,
        language: String? = nil,
        categories: [String] = [],
        episodeCount: Int? = nil,
        itunesID: Int? = nil,
        isExplicit: Bool? = nil,
        lastUpdated: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.website = website
        self.description = description
        self.author = author
        self.ownerName = ownerName
        self.imageURL = imageURL
        self.language = language
        self.categories = categories
        self.episodeCount = episodeCount
        self.itunesID = itunesID
        self.isExplicit = isExplicit
        self.lastUpdated = lastUpdated
    }
}
