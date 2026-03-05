// Package: MusicTheoryKit
// File: PitchClass.swift
// Path: Sources/MusicTheoryKit/Pitch/PitchClass.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - PitchClass

extension MusicTheoryKit.Pitch {
    /// Represent a pitch class in twelve-tone equal temperament.
    ///
    /// `PitchClass` stores a chromatic position normalized to the closed range `0...11`,
    /// where `0` maps to C and `11` maps to B.
    public struct PitchClass: RawRepresentable, Sendable {
        /// Store the normalized chromatic position for the pitch class.
        public let rawValue: Int

        /// Create a pitch class from an arbitrary semitone value.
        ///
        /// - Parameter rawValue: The semitone value to normalize into `0...11`.
        public init(rawValue: Int) {
            self.rawValue = Self.normalize(rawValue)
        }

        /// Return the ascending chromatic distance to another pitch class.
        ///
        /// - Parameter other: The destination pitch class.
        /// - Returns: A normalized semitone distance in the range `0...11`.
        public func distance(to other: Self) -> Int {
            Self.normalize(other.rawValue - rawValue)
        }

        /// Return a new pitch class transposed by the given number of semitones.
        ///
        /// - Parameter semitones: The signed semitone offset to apply.
        /// - Returns: A normalized transposed pitch class.
        public func transposed(by semitones: Int) -> Self {
            Self(rawValue: rawValue + semitones)
        }

        /// Normalize an arbitrary semitone value into the closed range `0...11`.
        ///
        /// - Parameter value: The semitone value to normalize.
        /// - Returns: A wrapped semitone value suitable for ``PitchClass/rawValue``.
        private static func normalize(_ value: Int) -> Int {
            let cardinality = chromaticCardinality
            let remainder = value % cardinality
            return remainder >= 0 ? remainder : remainder + cardinality
        }
    }
}

// MARK: - PitchClass constants

extension MusicTheoryKit.Pitch.PitchClass {
    /// Return the number of distinct pitch classes in the chromatic collection.
    public static let chromaticCardinality = 12

    /// Return pitch class C.
    public static let C = Self(rawValue: 0)

    /// Return pitch class C-sharp.
    public static let CSharp = Self(rawValue: 1)

    /// Return pitch class D.
    public static let D = Self(rawValue: 2)

    /// Return pitch class D-sharp.
    public static let DSharp = Self(rawValue: 3)

    /// Return pitch class E.
    public static let E = Self(rawValue: 4)

    /// Return pitch class F.
    public static let F = Self(rawValue: 5)

    /// Return pitch class F-sharp.
    public static let FSharp = Self(rawValue: 6)

    /// Return pitch class G.
    public static let G = Self(rawValue: 7)

    /// Return pitch class G-sharp.
    public static let GSharp = Self(rawValue: 8)

    /// Return pitch class A.
    public static let A = Self(rawValue: 9)

    /// Return pitch class A-sharp.
    public static let ASharp = Self(rawValue: 10)

    /// Return pitch class B.
    public static let B = Self(rawValue: 11)
}

// MARK: - PitchClass collection

extension MusicTheoryKit.Pitch.PitchClass: CaseIterable {
    /// Return every pitch class in ascending chromatic order from C through B.
    public static let allCases: [Self] = [
        .C,
        .CSharp,
        .D,
        .DSharp,
        .E,
        .F,
        .FSharp,
        .G,
        .GSharp,
        .A,
        .ASharp,
        .B,
    ]
}

// MARK: - PitchClass conformances

extension MusicTheoryKit.Pitch.PitchClass: Comparable, CustomStringConvertible, Hashable, Codable {
    /// Compare pitch classes by their normalized chromatic position.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand pitch class.
    ///   - rhs: The right-hand pitch class.
    /// - Returns: `true` when `lhs` sorts before `rhs`.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Return the sharp-based textual spelling of the pitch class.
    public var sharpSpelling: String {
        Self.sharpSpellings[rawValue]
    }

    /// Return the flat-based textual spelling of the pitch class.
    public var flatSpelling: String {
        Self.flatSpellings[rawValue]
    }

    /// Return a textual spelling of the pitch class using the requested accidental preference.
    ///
    /// - Parameter preferSharps: When `true`, prefer sharp spellings. Otherwise prefer flat spellings.
    /// - Returns: The pitch-class spelling that matches the requested accidental preference.
    public func spelling(preferSharps: Bool) -> String {
        preferSharps ? sharpSpelling : flatSpelling
    }

    /// Return a sharp-based textual representation of the pitch class.
    public var description: String {
        sharpSpelling
    }

    /// Return the default sharp spellings for the chromatic collection.
    private static let sharpSpellings = [
        "C",
        "C#",
        "D",
        "D#",
        "E",
        "F",
        "F#",
        "G",
        "G#",
        "A",
        "A#",
        "B",
    ]

    /// Return the default flat spellings for the chromatic collection.
    private static let flatSpellings = [
        "C",
        "Db",
        "D",
        "Eb",
        "E",
        "F",
        "Gb",
        "G",
        "Ab",
        "A",
        "Bb",
        "B",
    ]
}

// MARK: - PitchClass operators

extension MusicTheoryKit.Pitch.PitchClass {
    /// Transpose a pitch class upward or downward by a semitone offset.
    ///
    /// - Parameters:
    ///   - lhs: The source pitch class.
    ///   - rhs: The signed semitone offset.
    /// - Returns: A normalized transposed pitch class.
    public static func + (lhs: Self, rhs: Int) -> Self {
        lhs.transposed(by: rhs)
    }

    /// Measure the ascending chromatic distance from one pitch class to another.
    ///
    /// - Parameters:
    ///   - lhs: The source pitch class.
    ///   - rhs: The destination pitch class.
    /// - Returns: A normalized semitone distance in the range `0...11`.
    public static func - (lhs: Self, rhs: Self) -> Int {
        rhs.distance(to: lhs)
    }
}
