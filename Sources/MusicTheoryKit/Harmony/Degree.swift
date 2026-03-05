// Package: MusicTheoryKit
// File: Degree.swift
// Path: Sources/MusicTheoryKit/Harmony/Degree.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - Degree

extension MusicTheoryKit.Harmony {
    /// Represent a one-based scale degree inside a tonal context.
    ///
    /// `Degree` models harmonic position independently from any particular key or chord spelling.
    /// Its stored value must be greater than zero.
    public struct Degree: RawRepresentable, Sendable {
        /// Store the one-based scale-degree value.
        public let rawValue: Int

        /// Create a scale degree from a one-based integer value.
        ///
        /// - Parameter rawValue: The one-based scale-degree value.
        ///
        /// - Returns: `nil` when `rawValue` is less than `1`.
        public init?(rawValue: Int) {
            guard rawValue >= 1 else {
                return nil
            }

            self.rawValue = rawValue
        }

        /// Return the zero-based index that corresponds to the degree.
        public var zeroBasedIndex: Int {
            rawValue - 1
        }

        /// Return the uppercase Roman-numeral spelling for the degree when available.
        ///
        /// Degrees beyond seven fall back to `Degree <n>` because standard Roman-numeral
        /// harmonic notation is typically centered on seven scale positions.
        public var romanNumeral: String {
            Self.romanNumerals[rawValue] ?? "Degree \(rawValue)"
        }

        /// Return the harmonic function of the degree in a given key when a conventional mapping is available.
        ///
        /// This first-pass mapping supports major and minor-key families. Modal keys currently return `nil`
        /// rather than pretending to have a single common-practice functional interpretation.
        ///
        /// - Parameter key: The tonal context in which to interpret the degree.
        /// - Returns: The harmonic function of the degree, or `nil` when the key does not use a supported mapping.
        public func harmonicFunction(in key: MusicTheoryKit.Harmony.Key) -> HarmonicFunction? {
            switch key.scaleKind {
            case .major:
                return Self.majorFunctions[self]
            case .naturalMinor, .harmonicMinor, .melodicMinor, .aeolian:
                return Self.minorFunctions[self]
            case .dorian, .phrygian, .lydian, .mixolydian, .locrian:
                return nil
            }
        }
    }
}

// MARK: - HarmonicFunction

extension MusicTheoryKit.Harmony.Degree {
    /// Describe the harmonic role a degree plays within a tonal context.
    public enum HarmonicFunction: String, Sendable, Codable, Hashable, CustomStringConvertible {
        /// The degree belongs to the tonic function family.
        case tonic

        /// The degree belongs to the predominant function family.
        case predominant

        /// The degree belongs to the dominant function family.
        case dominant

        /// Return a human-readable description of the harmonic function.
        public var description: String {
            switch self {
            case .tonic:
                return "Tonic"
            case .predominant:
                return "Predominant"
            case .dominant:
                return "Dominant"
            }
        }
    }
}

// MARK: - Degree constants

extension MusicTheoryKit.Harmony.Degree {
    /// Return the tonic degree.
    public static let I = Self(rawValue: 1)!

    /// Return the supertonic degree.
    public static let II = Self(rawValue: 2)!

    /// Return the mediant degree.
    public static let III = Self(rawValue: 3)!

    /// Return the subdominant degree.
    public static let IV = Self(rawValue: 4)!

    /// Return the dominant degree.
    public static let V = Self(rawValue: 5)!

    /// Return the submediant degree.
    public static let VI = Self(rawValue: 6)!

    /// Return the leading-tone degree.
    public static let VII = Self(rawValue: 7)!
}

// MARK: - Degree collection

extension MusicTheoryKit.Harmony.Degree: CaseIterable {
    /// Return the seven conventional diatonic degrees in ascending order.
    public static let allCases: [Self] = [.I, .II, .III, .IV, .V, .VI, .VII]
}

// MARK: - Degree conformances

extension MusicTheoryKit.Harmony.Degree: Codable, Comparable, Hashable, CustomStringConvertible {
    /// Compare degrees by their one-based numeric value.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand degree.
    ///   - rhs: The right-hand degree.
    /// - Returns: `true` when `lhs` precedes `rhs`.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Return a human-readable description of the degree.
    public var description: String {
        romanNumeral
    }

    /// Return the uppercase Roman-numeral spellings for conventional diatonic degrees.
    private static let romanNumerals: [Int: String] = [
        1: "I",
        2: "II",
        3: "III",
        4: "IV",
        5: "V",
        6: "VI",
        7: "VII",
    ]

    /// Return common-practice harmonic functions for major keys.
    private static let majorFunctions: [Self: HarmonicFunction] = [
        .I: .tonic,
        .II: .predominant,
        .III: .tonic,
        .IV: .predominant,
        .V: .dominant,
        .VI: .tonic,
        .VII: .dominant,
    ]

    /// Return common-practice harmonic functions for minor-key families.
    private static let minorFunctions: [Self: HarmonicFunction] = [
        .I: .tonic,
        .II: .predominant,
        .III: .tonic,
        .IV: .predominant,
        .V: .dominant,
        .VI: .tonic,
        .VII: .dominant,
    ]
}
