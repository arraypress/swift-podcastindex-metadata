# Swift Podcast Index Metadata

A dependency-free Swift package for **searching and discovering podcasts** through the [Podcast Index](https://podcastindex.org) API. This is the discovery front-door RSS can't provide: find shows and episodes by topic, list what's trending, and resolve a feed by URL, iTunes ID, or Podcast Index ID — then hand the feed URL to your feed parser to pull episodes.

Podcast Index is free, but every request is signed with an API key + secret. Get one at [api.podcastindex.org](https://api.podcastindex.org).

## Features

- 🔎 **Search** — find shows by term or title; find episodes mentioning a person
- 🔥 **Trending & recent** — trending shows and the newest episodes across the index
- 🔗 **Resolve** — look up a podcast by feed URL, feed ID, or iTunes collection ID
- 🎧 **Episodes** — list episodes for any show (with duration, enclosure URL, artwork)
- 🔐 **Signed requests** — handles the SHA-1 auth scheme for you (via CryptoKit, no dependencies)
- 📦 **Sendable & Codable** models

## Requirements

- macOS 13.0+ / iOS 16.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 6.0+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-podcastindex-metadata.git", from: "1.0.0")
]
```

## Usage

```swift
import PodcastIndexMetadata

let config = PodcastIndexMetadata.Configuration(apiKey: "…", apiSecret: "…")
// …or set PODCAST_INDEX_KEY / PODCAST_INDEX_SECRET and use `.default`.

// Find shows by topic
let shows = try await PodcastIndexMetadata.search("artificial intelligence", configuration: config)
for show in shows {
    print(show.title, "—", show.episodeCount ?? 0, "episodes")
    print(show.url)   // RSS feed URL
}

// Latest episodes for a show
let episodes = try await PodcastIndexMetadata.episodes(feedID: shows[0].id, configuration: config)
print(episodes.first?.title ?? "", episodes.first?.formattedDuration ?? "")

// Trending shows / recent episodes across the whole index
let trending = try await PodcastIndexMetadata.trending(configuration: config)
let recent   = try await PodcastIndexMetadata.recentEpisodes(configuration: config)

// Resolve a known feed
let show = try await PodcastIndexMetadata.podcast(itunesID: 1510472996, configuration: config)
```

### Pairs with

- **swift-podcast-metadata** — resolve Apple Podcasts / Spotify *URLs* to a show
- **swift-feed-kit** — parse a resolved feed URL into full episode data

Discover here → resolve → parse. Same house, three doors.

## Models

| Type | Description |
|------|-------------|
| `PodcastFeed` | `id`, `title`, `url`, `website`, `description`, `author`, `ownerName`, `imageURL`, `language`, `categories`, `episodeCount`, `itunesID`, `isExplicit`, `lastUpdated` |
| `PodcastEpisode` | `id`, `title`, `link`, `description`, `guid`, `datePublished`, `enclosureURL`/`Type`/`Length`, `durationInSeconds` (+ `formattedDuration`), `episode`, `season`, `episodeType`, `imageURL`, `feedID`, `feedTitle` |
| `Configuration` | `apiKey`, `apiSecret`, `userAgent`; `.default` reads the environment |
| `PodcastIndexMetadataError` | Typed errors with `errorDescription` |

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
