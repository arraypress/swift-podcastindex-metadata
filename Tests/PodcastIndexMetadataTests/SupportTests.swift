//
//  SupportTests.swift
//
//  The duration rule pinned directly.
//

import XCTest
@testable import PodcastIndexMetadata

final class SupportTests: XCTestCase {

    func testDurationFormatting() {
        XCTAssertEqual(Formatting.duration(seconds: 727), "12:07")
        XCTAssertEqual(Formatting.duration(seconds: 3723), "1:02:03")
    }
}
