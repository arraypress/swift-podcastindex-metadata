//
//  PodcastEpisode+Formatted.swift
//  PodcastIndexMetadata
//
//  Created by David Sherlock on 2026.
//
//  The episode's one display string, delegating into Support. The
//  negative-duration guard is the episode's own rule and stays stated.
//

import Foundation

extension PodcastEpisode {

    /// A human-readable duration like `"1:02:03"` or `"12:07"`, or `nil`.
    public var formattedDuration: String? {
        guard let total = durationInSeconds, total >= 0 else { return nil }
        return Formatting.duration(seconds: total)
    }
}
