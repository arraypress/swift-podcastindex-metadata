//
//  PodcastEpisode.swift
//  PodcastIndexMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A single podcast episode as indexed by Podcast Index.
public struct PodcastEpisode: Sendable, Codable, Identifiable {

    /// The Podcast Index episode ID.
    public let id: Int

    /// The episode title.
    public let title: String

    /// A link to the episode page, when provided.
    public let link: String?

    /// The episode description (may contain HTML).
    public let description: String

    /// The episode GUID from the feed.
    public let guid: String?

    /// When the episode was published.
    public let datePublished: Date?

    /// The direct audio/video file URL.
    public let enclosureURL: String?

    /// The audio MIME type (e.g. `"audio/mpeg"`).
    public let enclosureType: String?

    /// The audio file size in bytes, when known.
    public let enclosureLength: Int?

    /// The episode duration in seconds, when known.
    public let durationInSeconds: Int?

    /// The episode number, when provided.
    public let episode: Int?

    /// The season number, when provided.
    public let season: Int?

    /// The episode type: `"full"`, `"trailer"`, or `"bonus"`.
    public let episodeType: String?

    /// Episode artwork URL, when provided.
    public let imageURL: String?

    /// The owning show's Podcast Index feed ID.
    public let feedID: Int?

    /// The owning show's title.
    public let feedTitle: String?

    public init(
        id: Int,
        title: String,
        link: String? = nil,
        description: String = "",
        guid: String? = nil,
        datePublished: Date? = nil,
        enclosureURL: String? = nil,
        enclosureType: String? = nil,
        enclosureLength: Int? = nil,
        durationInSeconds: Int? = nil,
        episode: Int? = nil,
        season: Int? = nil,
        episodeType: String? = nil,
        imageURL: String? = nil,
        feedID: Int? = nil,
        feedTitle: String? = nil
    ) {
        self.id = id
        self.title = title
        self.link = link
        self.description = description
        self.guid = guid
        self.datePublished = datePublished
        self.enclosureURL = enclosureURL
        self.enclosureType = enclosureType
        self.enclosureLength = enclosureLength
        self.durationInSeconds = durationInSeconds
        self.episode = episode
        self.season = season
        self.episodeType = episodeType
        self.imageURL = imageURL
        self.feedID = feedID
        self.feedTitle = feedTitle
    }

}
