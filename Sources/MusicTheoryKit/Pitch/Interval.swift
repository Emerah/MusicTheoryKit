// Package: MusicTheoryKit
// File: Interval.swift
// Path: Sources/MusicTheoryKit/Pitch/Interval.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - Interval

extension MusicTheoryKit.Pitch {
    /// Represent a chromatic interval measured in semitones.
    ///
    /// `Interval` is a lightweight value type that stores a signed semitone distance.
    /// Use it to measure the relationship between concrete pitches or to transpose pitches and pitch classes.
    public struct Interval: RawRepresentable, Sendable {
        /// Store the signed semitone distance of the interval.
        public let rawValue: Int

        /// Create an interval from a signed semitone distance.
        ///
        /// - Parameter rawValue: The number of semitones in the interval.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Create the ascending interval from one pitch class to another.
        ///
        /// - Parameters:
        ///   - lower: The source pitch class.
        ///   - upper: The destination pitch class.
        public init(from lower: MusicTheoryKit.Pitch.PitchClass, to upper: MusicTheoryKit.Pitch.PitchClass) {
            self.init(rawValue: lower.distance(to: upper))
        }

        /// Create the signed interval from one concrete pitch to another.
        ///
        /// - Parameters:
        ///   - lower: The source pitch.
        ///   - upper: The destination pitch.
        public init(from lower: MusicTheoryKit.Pitch.Pitch, to upper: MusicTheoryKit.Pitch.Pitch) {
            self.init(rawValue: lower.distance(to: upper))
        }

        /// Return the interval class normalized into one octave.
        ///
        /// - Returns: The wrapped semitone distance in the range `0...11`.
        public var intervalClass: Int {
            let cardinality = MusicTheoryKit.Pitch.PitchClass.chromaticCardinality
            let remainder = rawValue % cardinality
            return remainder >= 0 ? remainder : remainder + cardinality
        }

        /// Return the absolute semitone size of the interval.
        public var magnitude: Int {
            abs(rawValue)
        }

        /// Return the simple interval obtained by removing full octaves from the interval magnitude.
        ///
        /// Octave-equivalent intervals reduce to unison in this representation.
        public var simpleInterval: Self {
            Self(rawValue: magnitude % MusicTheoryKit.Pitch.PitchClass.chromaticCardinality)
        }

        /// Return the number of complete octaves contained in the interval magnitude.
        public var octaveSpan: Int {
            magnitude / MusicTheoryKit.Pitch.PitchClass.chromaticCardinality
        }

        /// Return whether the interval extends beyond a single octave in magnitude.
        public var isCompound: Bool {
            magnitude > MusicTheoryKit.Pitch.PitchClass.chromaticCardinality
        }

        /// Return the inversion of the interval class within one octave.
        ///
        /// Intervals that are octave-equivalent to unison invert to unison.
        public var inverted: Self {
            guard intervalClass != 0 else {
                return .unison
            }

            return Self(rawValue: MusicTheoryKit.Pitch.PitchClass.chromaticCardinality - intervalClass)
        }

        /// Apply the interval to a pitch class.
        ///
        /// - Parameter pitchClass: The source pitch class.
        /// - Returns: The transposed pitch class.
        public func applied(to pitchClass: MusicTheoryKit.Pitch.PitchClass) -> MusicTheoryKit.Pitch.PitchClass {
            pitchClass.transposed(by: rawValue)
        }

        /// Apply the interval to a concrete pitch.
        ///
        /// - Parameter pitch: The source pitch.
        /// - Returns: The transposed pitch.
        public func applied(to pitch: MusicTheoryKit.Pitch.Pitch) -> MusicTheoryKit.Pitch.Pitch {
            pitch.transposed(by: rawValue)
        }
    }
}

// MARK: - Interval constants

extension MusicTheoryKit.Pitch.Interval {
    /// Return a unison interval.
    public static let unison = Self(rawValue: 0)

    /// Return a minor second interval.
    public static let minorSecond = Self(rawValue: 1)

    /// Return a major second interval.
    public static let majorSecond = Self(rawValue: 2)

    /// Return a minor third interval.
    public static let minorThird = Self(rawValue: 3)

    /// Return a major third interval.
    public static let majorThird = Self(rawValue: 4)

    /// Return a perfect fourth interval.
    public static let perfectFourth = Self(rawValue: 5)

    /// Return a tritone interval.
    public static let tritone = Self(rawValue: 6)

    /// Return a perfect fifth interval.
    public static let perfectFifth = Self(rawValue: 7)

    /// Return a minor sixth interval.
    public static let minorSixth = Self(rawValue: 8)

    /// Return a major sixth interval.
    public static let majorSixth = Self(rawValue: 9)

    /// Return a minor seventh interval.
    public static let minorSeventh = Self(rawValue: 10)

    /// Return a major seventh interval.
    public static let majorSeventh = Self(rawValue: 11)

    /// Return an octave interval.
    public static let octave = Self(rawValue: 12)
}

// MARK: - Interval conformances

extension MusicTheoryKit.Pitch.Interval: Comparable, CustomStringConvertible, Hashable, Codable {
    /// Compare intervals by their raw semitone distance.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand interval.
    ///   - rhs: The right-hand interval.
    /// - Returns: `true` when `lhs` contains fewer semitones than `rhs`.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Return a human-readable description of the interval.
    public var description: String {
        let absoluteName = Self.name(forMagnitude: magnitude)

        guard rawValue < 0 else {
            return absoluteName
        }

        return "Descending \(absoluteName)"
    }

    /// Return a human-readable interval name for an absolute semitone magnitude.
    ///
    /// This naming is chromatic and octave-aware. It does not attempt to preserve enharmonic spelling.
    ///
    /// - Parameter magnitude: The absolute semitone size of the interval.
    /// - Returns: A readable interval name derived from the semitone count.
    private static func name(forMagnitude magnitude: Int) -> String {
        guard magnitude > 0 else {
            return "Unison"
        }

        if magnitude == 12 {
            return "Octave"
        }

        if magnitude < 12 {
            return simpleNames[magnitude]
        }

        let simpleSemitoneCount = magnitude % MusicTheoryKit.Pitch.PitchClass.chromaticCardinality
        let octaveSpan = magnitude / MusicTheoryKit.Pitch.PitchClass.chromaticCardinality

        if simpleSemitoneCount == 0 {
            return octaveSpan == 2 ? "Double Octave" : "\(octaveSpan) Octaves"
        }

        if simpleSemitoneCount == 6 {
            return "Compound Tritone"
        }

        guard let degreeNumber = compoundDegreeNumbers[simpleSemitoneCount] else {
            return "\(magnitude) semitones"
        }

        let quality = compoundQualities[simpleSemitoneCount] ?? simpleNames[simpleSemitoneCount]
        return "\(quality) \(ordinalName(for: degreeNumber + (octaveSpan * 7)))"
    }

    /// Return the human-readable ordinal name for a diatonic interval number.
    ///
    /// - Parameter degreeNumber: The interval number to render.
    /// - Returns: The ordinal interval name for the supplied degree number.
    private static func ordinalName(for degreeNumber: Int) -> String {
        switch degreeNumber {
        case 1: return "Unison"
        case 2: return "Second"
        case 3: return "Third"
        case 4: return "Fourth"
        case 5: return "Fifth"
        case 6: return "Sixth"
        case 7: return "Seventh"
        case 8: return "Octave"
        case 9: return "Ninth"
        case 10: return "Tenth"
        case 11: return "Eleventh"
        case 12: return "Twelfth"
        case 13: return "Thirteenth"
        case 14: return "Fourteenth"
        case 15: return "Fifteenth"
        default: return "\(degreeNumber)th"
        }
    }

    /// Return chromatic simple interval names indexed by semitone count.
    private static let simpleNames = [
        "Unison",
        "Minor Second",
        "Major Second",
        "Minor Third",
        "Major Third",
        "Perfect Fourth",
        "Tritone",
        "Perfect Fifth",
        "Minor Sixth",
        "Major Sixth",
        "Minor Seventh",
        "Major Seventh",
    ]

    /// Return the quality word for compound interval naming indexed by simple semitone count.
    private static let compoundQualities: [Int: String] = [
        1: "Minor",
        2: "Major",
        3: "Minor",
        4: "Major",
        5: "Perfect",
        7: "Perfect",
        8: "Minor",
        9: "Major",
        10: "Minor",
        11: "Major",
    ]

    /// Return the diatonic base number for compound interval naming indexed by simple semitone count.
    private static let compoundDegreeNumbers: [Int: Int] = [
        1: 2,
        2: 2,
        3: 3,
        4: 3,
        5: 4,
        7: 5,
        8: 6,
        9: 6,
        10: 7,
        11: 7,
    ]
}

// MARK: - Interval operators

extension MusicTheoryKit.Pitch.Interval {
    /// Combine two intervals by adding their semitone distances.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand interval.
    ///   - rhs: The right-hand interval.
    /// - Returns: A new interval whose semitone count is the sum of both operands.
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue + rhs.rawValue)
    }

    /// Subtract one interval from another.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand interval.
    ///   - rhs: The right-hand interval.
    /// - Returns: A new interval whose semitone count is the difference of both operands.
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue - rhs.rawValue)
    }
}
