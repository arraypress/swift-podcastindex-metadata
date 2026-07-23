//
//  PodcastIndexMetadataTests.swift
//  PodcastIndexMetadata
//
//  Created by David Sherlock on 2026.
//

import XCTest
@testable import PodcastIndexMetadata

final class PodcastIndexMetadataTests: XCTestCase {

    // MARK: - Auth signature

    func testSHA1Signature() {
        // SHA-1("abc") is a well-known vector.
        XCTAssertEqual(PodcastIndexMetadata.sha1Hex("abc"), "a9993e364706816aba3e25717850c26c9cd0d89d")
        // Empty string vector.
        XCTAssertEqual(PodcastIndexMetadata.sha1Hex(""), "da39a3ee5e6b4b0d3255bfef95601890afd80709")
    }

    func testMissingCredentialsThrows() async {
        do {
            _ = try await PodcastIndexMetadata.search("swift", configuration: .init())
            XCTFail("Expected missingCredentials")
        } catch {
            XCTAssertEqual(error as? PodcastIndexMetadataError, .missingCredentials)
        }
    }

    // MARK: - Feed parsing

    func testParseFeeds() throws {
        let json = """
        {"status":"true","feeds":[
          {"id":920666,"title":"Machine Learning Street Talk","url":"https://anchor.fm/s/…/podcast/rss",
           "link":"https://mlst.ai","description":"AI research discussions.","author":"Tim Scarfe",
           "ownerName":"MLST","artwork":"https://cdn/artwork.jpg","image":"https://cdn/img.jpg",
           "language":"en","categories":{"9":"Technology","102":"Science"},"episodeCount":210,
           "itunesId":1510472996,"explicit":false,"lastUpdateTime":1782550805}
        ],"count":1}
        """
        let feeds = try PIParser.feeds(from: Data(json.utf8))
        XCTAssertEqual(feeds.count, 1)
        let f = try XCTUnwrap(feeds.first)
        XCTAssertEqual(f.id, 920666)
        XCTAssertEqual(f.title, "Machine Learning Street Talk")
        XCTAssertEqual(f.website, "https://mlst.ai")
        XCTAssertEqual(f.author, "Tim Scarfe")
        XCTAssertEqual(f.imageURL, "https://cdn/artwork.jpg")   // artwork preferred over image
        XCTAssertEqual(f.categories, ["Technology", "Science"]) // sorted by numeric key
        XCTAssertEqual(f.episodeCount, 210)
        XCTAssertEqual(f.itunesID, 1510472996)
        XCTAssertEqual(f.isExplicit, false)
        XCTAssertNotNil(f.lastUpdated)
    }

    func testParseSingleFeed() throws {
        let json = #"{"status":"true","feed":{"id":1,"title":"Solo","url":"https://x/rss","description":"","explicit":1}}"#
        let f = try PIParser.feed(from: Data(json.utf8))
        XCTAssertEqual(f.id, 1)
        XCTAssertEqual(f.isExplicit, true)   // 1 → true
    }

    // MARK: - Episode parsing

    func testParseEpisodes() throws {
        let json = """
        {"status":"true","items":[
          {"id":123,"title":"On AI Agents","link":"https://x/ep","description":"<p>Great ep</p>",
           "guid":"abc-123","datePublished":1782550805,"enclosureUrl":"https://x/ep.mp3",
           "enclosureType":"audio/mpeg","enclosureLength":42000000,"duration":3723,
           "episode":12,"season":2,"episodeType":"full","image":"https://x/ep.jpg",
           "feedId":920666,"feedTitle":"MLST"}
        ],"count":1}
        """
        let eps = try PIParser.episodes(from: Data(json.utf8))
        let e = try XCTUnwrap(eps.first)
        XCTAssertEqual(e.id, 123)
        XCTAssertEqual(e.title, "On AI Agents")
        XCTAssertEqual(e.durationInSeconds, 3723)
        XCTAssertEqual(e.formattedDuration, "1:02:03")
        XCTAssertEqual(e.episode, 12)
        XCTAssertEqual(e.season, 2)
        XCTAssertEqual(e.enclosureURL, "https://x/ep.mp3")
        XCTAssertEqual(e.feedID, 920666)
        XCTAssertNotNil(e.datePublished)
    }

    func testEmptyPayloads() throws {
        XCTAssertEqual(try PIParser.feeds(from: Data(#"{"feeds":[]}"#.utf8)).count, 0)
        XCTAssertEqual(try PIParser.episodes(from: Data(#"{"items":[]}"#.utf8)).count, 0)
    }
}
