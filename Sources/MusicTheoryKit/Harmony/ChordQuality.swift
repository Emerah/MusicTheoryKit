// Package: MusicTheoryKit
// File: ChordQuality.swift
// Path: Sources/MusicTheoryKit/Harmony/ChordQuality.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - ChordQuality

extension MusicTheoryKit.Harmony {
    /// Represent a chord quality as an ordered interval formula from the root.
    ///
    /// `ChordQuality` stores the harmonic structure of a chord independently from any particular root.
    /// Its interval formula must begin with unison, remain strictly ascending, and represent distinct chord tones.
    public struct ChordQuality: Sendable {
        /// Store the ordered interval formula measured from the root.
        public let intervals: [MusicTheoryKit.Pitch.Interval]

        /// Create a chord quality from an interval formula.
        ///
        /// - Parameter intervals: The ordered interval formula relative to the chord root.
        ///
        /// - Returns: `nil` when the interval formula is empty, does not begin with unison,
        ///   is not strictly ascending, or repeats a pitch class already represented in the formula.
        public init?(intervals: [MusicTheoryKit.Pitch.Interval]) {
            guard Self.isValid(intervals) else {
                return nil
            }

            self.init(validatedIntervals: intervals)
        }

        /// Create a chord quality from a validated interval formula.
        ///
        /// - Parameter validatedIntervals: A valid ordered interval formula relative to the root.
        private init(validatedIntervals: [MusicTheoryKit.Pitch.Interval]) {
            intervals = validatedIntervals
        }

        /// Return the number of distinct chord tones in the quality.
        public var toneCount: Int {
            intervals.count
        }

        /// Return the compound intervals that function as extensions or added tensions.
        public var extensionIntervals: [MusicTheoryKit.Pitch.Interval] {
            intervals.filter { $0.rawValue > MusicTheoryKit.Pitch.PitchClass.chromaticCardinality }
        }

        /// Return the altered intervals present in the quality.
        ///
        /// Altered intervals are currently recognized chromatically as flattened or sharpened fifths and tensions.
        public var alterationIntervals: [MusicTheoryKit.Pitch.Interval] {
            intervals.filter(Self.isAlterationInterval)
        }

        /// Return whether the quality contains the given interval.
        ///
        /// - Parameter interval: The interval to test.
        /// - Returns: `true` when the interval is part of the chord formula.
        public func contains(_ interval: MusicTheoryKit.Pitch.Interval) -> Bool {
            intervals.contains(interval)
        }

        /// Return a copy of the quality with an added extension.
        ///
        /// The interval is inserted into the formula in ascending order.
        ///
        /// - Parameter interval: The extension interval to add.
        /// - Returns: A new chord quality containing the extension, or `nil` when the interval is not a valid extension
        ///   or would duplicate an existing chord tone.
        public func addingExtension(_ interval: MusicTheoryKit.Pitch.Interval) -> Self? {
            guard Self.isExtensionInterval(interval) else {
                return nil
            }

            return adding(interval)
        }

        /// Return a copy of the quality with an added alteration.
        ///
        /// The interval is inserted into the formula in ascending order.
        ///
        /// - Parameter interval: The altered interval to add.
        /// - Returns: A new chord quality containing the alteration, or `nil` when the interval is not a recognized
        ///   alteration or would duplicate an existing chord tone.
        public func addingAlteration(_ interval: MusicTheoryKit.Pitch.Interval) -> Self? {
            guard Self.isAlterationInterval(interval) else {
                return nil
            }

            return adding(interval)
        }

        /// Return whether an interval formula forms a valid chord quality.
        ///
        /// - Parameter intervals: The ordered interval formula to validate.
        /// - Returns: `true` when the formula begins with unison, is strictly ascending,
        ///   and each interval resolves to a distinct non-octave chord tone.
        private static func isValid(_ intervals: [MusicTheoryKit.Pitch.Interval]) -> Bool {
            guard let first = intervals.first, first == .unison else {
                return false
            }

            var previousValue = -1
            var intervalClasses = Set<Int>()

            for interval in intervals {
                let value = interval.rawValue
                let intervalClass = interval.intervalClass

                guard value >= 0, value > previousValue else {
                    return false
                }

                if value > 0 {
                    guard intervalClass != 0, intervalClasses.insert(intervalClass).inserted else {
                        return false
                    }
                } else {
                    guard interval == .unison else {
                        return false
                    }
                }

                previousValue = value
            }

            return true
        }

        /// Return whether an interval is a valid added extension.
        ///
        /// - Parameter interval: The interval to inspect.
        /// - Returns: `true` when the interval is a compound non-octave interval.
        private static func isExtensionInterval(_ interval: MusicTheoryKit.Pitch.Interval) -> Bool {
            interval.rawValue > MusicTheoryKit.Pitch.PitchClass.chromaticCardinality && interval.intervalClass != 0
        }

        /// Return whether an interval is a recognized alteration.
        ///
        /// - Parameter interval: The interval to inspect.
        /// - Returns: `true` when the interval corresponds chromatically to an altered fifth or tension.
        private static func isAlterationInterval(_ interval: MusicTheoryKit.Pitch.Interval) -> Bool {
            switch interval.intervalClass {
            case 1, 3, 6, 8:
                return interval.rawValue > 0
            default:
                return false
            }
        }

        /// Return a copy of the quality with one additional interval.
        ///
        /// - Parameter interval: The interval to insert.
        /// - Returns: A new chord quality with the interval inserted in ascending order, or `nil` when the result
        ///   would no longer describe a valid distinct-tone chord quality.
        private func adding(_ interval: MusicTheoryKit.Pitch.Interval) -> Self? {
            let updatedIntervals = (intervals + [interval]).sorted { $0.rawValue < $1.rawValue }
            return Self(intervals: updatedIntervals)
        }
    }
}

// MARK: - ChordQuality presets

extension MusicTheoryKit.Harmony.ChordQuality {
    /// Return a major triad quality.
    public static let major = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth])

    /// Return a minor triad quality.
    public static let minor = Self(validatedIntervals: [.unison, .minorThird, .perfectFifth])

    /// Return a diminished triad quality.
    public static let diminished = Self(validatedIntervals: [.unison, .minorThird, .tritone])

    /// Return an augmented triad quality.
    public static let augmented = Self(validatedIntervals: [.unison, .majorThird, .minorSixth])

    /// Return a suspended second triad quality.
    public static let suspendedSecond = Self(validatedIntervals: [.unison, .majorSecond, .perfectFifth])

    /// Return a suspended fourth triad quality.
    public static let suspendedFourth = Self(validatedIntervals: [.unison, .perfectFourth, .perfectFifth])

    /// Return a dominant seventh quality.
    public static let dominantSeventh = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth, .minorSeventh])

    /// Return a major seventh quality.
    public static let majorSeventh = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth, .majorSeventh])

    /// Return a minor seventh quality.
    public static let minorSeventh = Self(validatedIntervals: [.unison, .minorThird, .perfectFifth, .minorSeventh])

    /// Return a half-diminished seventh quality.
    public static let halfDiminishedSeventh = Self(validatedIntervals: [.unison, .minorThird, .tritone, .minorSeventh])

    /// Return a diminished seventh quality.
    public static let diminishedSeventh = Self(validatedIntervals: [.unison, .minorThird, .tritone, .majorSixth])

    /// Return a dominant ninth quality.
    public static let dominantNinth = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth, .minorSeventh, .init(rawValue: 14)])

    /// Return a major ninth quality.
    public static let majorNinth = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth, .majorSeventh, .init(rawValue: 14)])

    /// Return a minor ninth quality.
    public static let minorNinth = Self(validatedIntervals: [.unison, .minorThird, .perfectFifth, .minorSeventh, .init(rawValue: 14)])

    /// Return a dominant flat ninth quality.
    public static let dominantFlatNinth = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth, .minorSeventh, .init(rawValue: 13)])

    /// Return a dominant sharp ninth quality.
    public static let dominantSharpNinth = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth, .minorSeventh, .init(rawValue: 15)])

    /// Return a dominant sharp eleventh quality.
    public static let dominantSharpEleventh = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth, .minorSeventh, .init(rawValue: 14), .init(rawValue: 18)])

    /// Return a dominant flat thirteenth quality.
    public static let dominantFlatThirteenth = Self(validatedIntervals: [.unison, .majorThird, .perfectFifth, .minorSeventh, .init(rawValue: 14), .init(rawValue: 20)])
}

// MARK: - ChordQuality conformances

extension MusicTheoryKit.Harmony.ChordQuality: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the chord quality.
    public var description: String {
        switch self {
        case .major:
            return "Major"
        case .minor:
            return "Minor"
        case .diminished:
            return "Diminished"
        case .augmented:
            return "Augmented"
        case .suspendedSecond:
            return "Suspended Second"
        case .suspendedFourth:
            return "Suspended Fourth"
        case .dominantSeventh:
            return "Dominant Seventh"
        case .majorSeventh:
            return "Major Seventh"
        case .minorSeventh:
            return "Minor Seventh"
        case .dominantNinth:
            return "Dominant Ninth"
        case .majorNinth:
            return "Major Ninth"
        case .minorNinth:
            return "Minor Ninth"
        case .dominantFlatNinth:
            return "Dominant Flat Ninth"
        case .dominantSharpNinth:
            return "Dominant Sharp Ninth"
        case .dominantSharpEleventh:
            return "Dominant Sharp Eleventh"
        case .dominantFlatThirteenth:
            return "Dominant Flat Thirteenth"
        case .halfDiminishedSeventh:
            return "Half-Diminished Seventh"
        case .diminishedSeventh:
            return "Diminished Seventh"
        default:
            let formula = intervals.map(\.description).joined(separator: ", ")
            return "[\(formula)]"
        }
    }
}
