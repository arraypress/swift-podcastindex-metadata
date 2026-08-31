//
//  Formatting.swift
//  PodcastIndexMetadata
//
//  Created by David Sherlock on 2026.
//
//  Durations as the strings a caller shows. A pure function, so the
//  rule is pinned by a test that constructs no model.
//

import Foundation

/// Presentation formatting for derived, human-readable strings.
enum Formatting {

    /// Seconds as `"M:SS"`, growing to `"H:MM:SS"` past an hour.
    static func duration(seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }
}
