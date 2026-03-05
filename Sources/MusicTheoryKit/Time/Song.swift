// Package: MusicTheoryKit
// File: Song.swift
// Path: Sources/MusicTheoryKit/Time/Song.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Foundation

// MARK: - Song

extension MusicTheoryKit.Time {
    /// Represent a song as an ordered collection of measures plus optional global context.
    ///
    /// `Song` keeps its structure intentionally simple: it stores ordered measures, optional key context,
    /// optional labeled sections, and an optional tempo in beats per minute. Measure numbers must be contiguous
    /// starting at `1`, and sections must reference valid, non-overlapping measure spans.
    public struct Song: Sendable {
        /// Store the song title.
        public let title: String

        /// Store the ordered measures that make up the song.
        public let measures: [MusicTheoryKit.Time.Measure]

        /// Store the optional global key context of the song.
        public let key: MusicTheoryKit.Harmony.Key?

        /// Store the optional labeled sections that describe the song's larger form.
        public let sections: [Section]

        /// Store the optional global tempo in beats per minute.
        public let tempoBPM: Double?

        /// Create a song from a title, ordered measures, optional sections, and optional global context.
        ///
        /// - Parameters:
        ///   - title: The song title.
        ///   - measures: The ordered measures that make up the song.
        ///   - sections: The optional labeled sections that describe the song's form.
        ///   - key: The optional global key context of the song.
        ///   - tempoBPM: The optional global tempo in beats per minute.
        ///
        /// - Returns: `nil` when the title is empty after trimming, the measure numbering is not contiguous
        ///   starting at `1`, the sections are invalid for the current measure collection, or `tempoBPM`
        ///   is present but not greater than zero.
        public init?(
            title: String,
            measures: [MusicTheoryKit.Time.Measure],
            sections: [Section] = [],
            key: MusicTheoryKit.Harmony.Key? = nil,
            tempoBPM: Double? = nil
        ) {
            let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

            guard normalizedTitle.isEmpty == false else {
                return nil
            }

            guard tempoBPM.map({ $0 > 0 }) ?? true else {
                return nil
            }

            guard Self.hasContiguousMeasureNumbers(measures) else {
                return nil
            }

            guard Self.hasValidSections(sections, measureCount: measures.count) else {
                return nil
            }

            self.title = normalizedTitle
            self.measures = measures
            self.sections = sections.sorted { lhs, rhs in
                if lhs.startMeasureNumber == rhs.startMeasureNumber {
                    return lhs.endMeasureNumber < rhs.endMeasureNumber
                }

                return lhs.startMeasureNumber < rhs.startMeasureNumber
            }
            self.key = key
            self.tempoBPM = tempoBPM
        }

        /// Return the number of measures in the song.
        public var measureCount: Int {
            measures.count
        }

        /// Return the total number of beats across all measures.
        public var totalBeatCount: Double {
            measures.reduce(into: 0) { partialResult, measure in
                partialResult += measure.beatCount
            }
        }

        /// Return all note events flattened into song-global beat positions.
        public var flattenedNoteEvents: [NoteEvent] {
            var elapsedBeats = 0.0
            var flattenedEvents: [NoteEvent] = []

            for measure in measures {
                for event in measure.events {
                    flattenedEvents.append(
                        NoteEvent(
                            pitch: event.pitch,
                            startBeat: elapsedBeats + event.startBeat,
                            duration: event.duration,
                            velocity: event.velocity
                        )!
                    )
                }

                elapsedBeats += measure.beatCount
            }

            return flattenedEvents
        }

        /// Return the measure with the given one-based number.
        ///
        /// - Parameter number: The one-based measure number to look up.
        /// - Returns: The matching measure, or `nil` when the number is not present.
        public func measure(number: Int) -> MusicTheoryKit.Time.Measure? {
            measures.first { $0.number == number }
        }

        /// Return the section that contains the given one-based measure number.
        ///
        /// - Parameter measureNumber: The one-based measure number to look up.
        /// - Returns: The matching section, or `nil` when the measure is unlabeled.
        public func section(containingMeasureNumber measureNumber: Int) -> Section? {
            sections.first {
                measureNumber >= $0.startMeasureNumber && measureNumber <= $0.endMeasureNumber
            }
        }

        /// Return all sections of a given form kind.
        ///
        /// - Parameter kind: The section kind to filter.
        /// - Returns: The sections whose kind matches `kind`.
        public func sections(of kind: Section.Kind) -> [Section] {
            sections.filter { $0.kind == kind }
        }

        /// Return a copy of the song with an appended measure.
        ///
        /// - Parameter measure: The measure to append.
        /// - Returns: A new song containing the appended measure, or `nil` when numbering would become invalid.
        public func appending(_ measure: MusicTheoryKit.Time.Measure) -> Self? {
            Self(title: title, measures: measures + [measure], sections: sections, key: key, tempoBPM: tempoBPM)
        }

        /// Return whether the measure numbering is contiguous starting at `1`.
        ///
        /// - Parameter measures: The measures to validate.
        /// - Returns: `true` when the measures are numbered `1...count` in order.
        private static func hasContiguousMeasureNumbers(_ measures: [MusicTheoryKit.Time.Measure]) -> Bool {
            for (expectedOffset, measure) in measures.enumerated() {
                let expectedNumber = expectedOffset + 1

                guard measure.number == expectedNumber else {
                    return false
                }
            }

            return true
        }

        /// Return whether a section list is valid for a song with the given measure count.
        ///
        /// - Parameters:
        ///   - sections: The sections to validate.
        ///   - measureCount: The number of measures available in the song.
        /// - Returns: `true` when every section references a valid measure range and no two sections overlap.
        private static func hasValidSections(_ sections: [Section], measureCount: Int) -> Bool {
            let sortedSections = sections.sorted { lhs, rhs in
                if lhs.startMeasureNumber == rhs.startMeasureNumber {
                    return lhs.endMeasureNumber < rhs.endMeasureNumber
                }

                return lhs.startMeasureNumber < rhs.startMeasureNumber
            }

            for (index, section) in sortedSections.enumerated() {
                guard section.startMeasureNumber >= 1, section.endMeasureNumber <= measureCount else {
                    return false
                }

                guard index == 0 || sortedSections[index - 1].endMeasureNumber < section.startMeasureNumber else {
                    return false
                }
            }

            return true
        }
    }
}

// MARK: - Section

extension MusicTheoryKit.Time.Song {
    /// Represent a labeled span of measures within a song's larger form.
    public struct Section: Sendable, Codable, Hashable {
        /// Store the form label of the section.
        public let kind: Kind

        /// Store the first measure number covered by the section.
        public let startMeasureNumber: Int

        /// Store the last measure number covered by the section.
        public let endMeasureNumber: Int

        /// Create a song section from a form kind and inclusive measure range.
        ///
        /// - Parameters:
        ///   - kind: The form label of the section.
        ///   - startMeasureNumber: The first measure number covered by the section.
        ///   - endMeasureNumber: The last measure number covered by the section.
        ///
        /// - Returns: `nil` when the range is empty or starts before measure `1`.
        public init?(kind: Kind, startMeasureNumber: Int, endMeasureNumber: Int) {
            guard startMeasureNumber >= 1, endMeasureNumber >= startMeasureNumber else {
                return nil
            }

            self.kind = kind
            self.startMeasureNumber = startMeasureNumber
            self.endMeasureNumber = endMeasureNumber
        }
    }
}

// MARK: - Section Kind

extension MusicTheoryKit.Time.Song.Section {
    /// Describe a common large-scale form label in a song.
    public enum Kind: String, Sendable, Codable, Hashable, CaseIterable, CustomStringConvertible {
        /// An introductory section.
        case intro

        /// A verse section.
        case verse

        /// A pre-chorus section.
        case preChorus

        /// A chorus section.
        case chorus

        /// A bridge section.
        case bridge

        /// A solo section.
        case solo

        /// An interlude section.
        case interlude

        /// A turnaround section.
        case turnaround

        /// An ending section.
        case outro

        /// Return a human-readable description of the section kind.
        public var description: String {
            switch self {
            case .intro:
                return "Intro"
            case .verse:
                return "Verse"
            case .preChorus:
                return "Pre-Chorus"
            case .chorus:
                return "Chorus"
            case .bridge:
                return "Bridge"
            case .solo:
                return "Solo"
            case .interlude:
                return "Interlude"
            case .turnaround:
                return "Turnaround"
            case .outro:
                return "Outro"
            }
        }
    }
}

// MARK: - Song conformances

extension MusicTheoryKit.Time.Song: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the song.
    public var description: String {
        "\(title) (\(measureCount) measures)"
    }
}
