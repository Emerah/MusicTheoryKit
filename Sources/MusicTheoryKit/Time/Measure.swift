// Package: MusicTheoryKit
// File: Measure.swift
// Path: Sources/MusicTheoryKit/Time/Measure.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - Measure

extension MusicTheoryKit.Time {
    /// Represent a measure as a bounded beat span containing local note events.
    ///
    /// `Measure` stores events in local beat coordinates starting at `0`. Its meter is described by a
    /// ``MusicTheoryKit/Time/TimeSignature``, and every event must fit entirely within the measure.
    public struct Measure: Sendable {
        /// Store the one-based measure number.
        public let number: Int

        /// Store the notated meter of the measure.
        public let timeSignature: MusicTheoryKit.Time.TimeSignature

        /// Store the note events contained in the measure, sorted by onset.
        public let events: [MusicTheoryKit.Time.NoteEvent]

        /// Create a measure from a measure number, time signature, and note events.
        ///
        /// - Parameters:
        ///   - number: The one-based measure number.
        ///   - timeSignature: The notated meter of the measure.
        ///   - events: The note events contained in the measure.
        ///
        /// - Returns: `nil` when `number` is less than `1`
        ///   or any event extends outside the measure.
        public init?(
            number: Int,
            timeSignature: MusicTheoryKit.Time.TimeSignature,
            events: [MusicTheoryKit.Time.NoteEvent] = []
        ) {
            guard number >= 1 else {
                return nil
            }

            let sortedEvents = events.sorted {
                if $0.startBeat == $1.startBeat {
                    return $0.pitch < $1.pitch
                }

                return $0.startBeat < $1.startBeat
            }

            guard sortedEvents.allSatisfy({ $0.endBeat <= timeSignature.beatCount }) else {
                return nil
            }

            self.number = number
            self.timeSignature = timeSignature
            self.events = sortedEvents
        }

        /// Create a quarter-note-based measure from a measure number, beat count, and note events.
        ///
        /// This convenience initializer maps an integer `beatCount` to a `n/4` time signature so existing
        /// quarter-note-based call sites can migrate incrementally to explicit meter.
        ///
        /// - Parameters:
        ///   - number: The one-based measure number.
        ///   - beatCount: The number of quarter-note beats in the measure.
        ///   - events: The note events contained in the measure.
        ///
        /// - Returns: `nil` when `beatCount` is not a positive whole number or the resulting measure is invalid.
        public init?(number: Int, beatCount: Double, events: [MusicTheoryKit.Time.NoteEvent] = []) {
            guard beatCount > 0, beatCount.rounded(.towardZero) == beatCount else {
                return nil
            }

            guard let timeSignature = MusicTheoryKit.Time.TimeSignature(
                numerator: Int(beatCount),
                denominator: 4
            ) else {
                return nil
            }

            self.init(number: number, timeSignature: timeSignature, events: events)
        }

        /// Return the duration of the measure in local denominator-note beats.
        public var beatCount: Double {
            timeSignature.beatCount
        }

        /// Return the local end beat of the measure.
        public var endBeat: Double {
            beatCount
        }

        /// Return the whole-beat downbeats and secondary strong beats in the measure.
        ///
        /// The returned beats are derived from the measure's ``timeSignature`` rather than from a generic
        /// beat-count heuristic.
        public var strongBeats: [Double] {
            timeSignature.accentedBeats
        }

        /// Return whether the measure contains the given local beat position.
        ///
        /// The start beat is inclusive and the end beat is exclusive.
        ///
        /// - Parameter beat: The local beat position to test.
        /// - Returns: `true` when the beat lies within the measure bounds.
        public func contains(beat: Double) -> Bool {
            beat >= 0 && beat < beatCount
        }

        /// Return the metrical strength of a local beat position when it falls on a whole beat in the measure.
        ///
        /// - Parameter beat: The local beat position to analyze.
        /// - Returns: The metrical strength of the beat, or `nil` when the beat is outside the measure or not whole.
        public func beatStrength(at beat: Double) -> BeatStrength? {
            guard contains(beat: beat) else {
                return nil
            }

            return timeSignature.beatStrength(at: beat)
        }

        /// Return whether a local beat position is the measure's downbeat.
        ///
        /// - Parameter beat: The local beat position to test.
        /// - Returns: `true` when `beat` is the measure's first whole beat.
        public func isDownbeat(_ beat: Double) -> Bool {
            beatStrength(at: beat) == .strong
        }

        /// Return the events active at the given local beat.
        ///
        /// - Parameter beat: The local beat position to test.
        /// - Returns: The events spanning the given beat.
        public func events(at beat: Double) -> [MusicTheoryKit.Time.NoteEvent] {
            events.filter { $0.contains(beat: beat) }
        }

        /// Return a copy of the measure with an appended event.
        ///
        /// - Parameter event: The note event to append.
        /// - Returns: A new measure containing the event, or `nil` when the event would exceed the measure bounds.
        public func appending(_ event: MusicTheoryKit.Time.NoteEvent) -> Self? {
            Self(number: number, timeSignature: timeSignature, events: events + [event])
        }
    }
}

// MARK: - BeatStrength

extension MusicTheoryKit.Time.Measure {
    /// Describe the metrical strength of a whole beat within a measure.
    public enum BeatStrength: String, Sendable, Codable, Hashable, CustomStringConvertible {
        /// The strongest beat in the measure.
        case strong

        /// A secondary accent beat within the measure.
        case medium

        /// An unaccented beat.
        case weak

        /// Return a human-readable description of the beat strength.
        public var description: String {
            switch self {
            case .strong:
                return "Strong"
            case .medium:
                return "Medium"
            case .weak:
                return "Weak"
            }
        }
    }
}

// MARK: - Measure conformances

extension MusicTheoryKit.Time.Measure: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the measure.
    public var description: String {
        "Measure \(number) (\(timeSignature), \(events.count) events)"
    }
}
