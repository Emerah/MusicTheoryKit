// Package: MusicTheoryKit
// File: NoteName.swift
// Path: Sources/MusicTheoryKit/Pitch/NoteName.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - NoteName

extension MusicTheoryKit.Pitch {
    /// Represent a spelled note name as a letter plus an accidental.
    ///
    /// `NoteName` preserves notational identity that would otherwise be lost when reduced to a chromatic
    /// ``MusicTheoryKit/Pitch/PitchClass`` alone. This makes it suitable for key spelling and key-signature metadata.
    public struct NoteName: Sendable {
        /// Store the diatonic letter of the note name.
        public let letter: Letter

        /// Store the accidental applied to the note letter.
        public let accidental: Accidental

        /// Create a note name from a letter and accidental.
        ///
        /// - Parameters:
        ///   - letter: The diatonic letter of the note name.
        ///   - accidental: The accidental applied to the letter. Defaults to `.natural`.
        public init(letter: Letter, accidental: Accidental = .natural) {
            self.letter = letter
            self.accidental = accidental
        }

        /// Create a spelled note name for a pitch class using the requested accidental preference.
        ///
        /// - Parameters:
        ///   - pitchClass: The pitch class to spell.
        ///   - preferSharps: When `true`, choose a sharp-based spelling for chromatic tones. Otherwise choose a flat-based spelling.
        public init(pitchClass: MusicTheoryKit.Pitch.PitchClass, preferSharps: Bool) {
            self = preferSharps ? Self.sharpSpellings[pitchClass.rawValue] : Self.flatSpellings[pitchClass.rawValue]
        }

        /// Return the chromatic pitch class implied by the note spelling.
        public var pitchClass: MusicTheoryKit.Pitch.PitchClass {
            .init(rawValue: letter.naturalPitchClass.rawValue + accidental.chromaticOffset)
        }

        /// Return the note's position on the circle of fifths.
        ///
        /// Positive values add sharps and negative values add flats. Values outside `-7...7`
        /// describe theoretical signatures beyond the conventional seven-accidental system.
        public var circleOfFifthsIndex: Int {
            letter.circleOfFifthsIndex + accidental.circleOfFifthsOffset
        }

        /// Return a spelled note name at a given diatonic distance that matches the requested pitch class.
        ///
        /// This helper preserves the intended letter progression of scales and chords while resolving the
        /// accidental needed to hit the target chromatic pitch class.
        ///
        /// - Parameters:
        ///   - degreeNumber: The one-based diatonic degree number relative to `self`.
        ///   - pitchClass: The target chromatic pitch class to match.
        /// - Returns: A spelled note name for the requested degree, or `nil` when the spelling would require
        ///   an accidental outside the supported single-flat to single-sharp range.
        public func noteName(
            atDegree degreeNumber: Int,
            matching pitchClass: MusicTheoryKit.Pitch.PitchClass
        ) -> Self? {
            guard degreeNumber >= 1 else {
                return nil
            }

            let targetLetter = letter.advanced(by: degreeNumber - 1)
            let naturalPitchClass = targetLetter.naturalPitchClass
            let semitoneOffset = Self.normalizeSemitoneOffset(pitchClass.rawValue - naturalPitchClass.rawValue)

            guard let accidental = Accidental(chromaticOffset: semitoneOffset) else {
                return nil
            }

            return .init(letter: targetLetter, accidental: accidental)
        }

        /// Normalize a semitone offset into the supported accidental range when possible.
        ///
        /// - Parameter value: The signed semitone offset to normalize.
        /// - Returns: A normalized offset in the range `-1...1` when available, otherwise the original wrapped value.
        private static func normalizeSemitoneOffset(_ value: Int) -> Int {
            let wrappedValue = ((value % 12) + 12) % 12

            switch wrappedValue {
            case 0:
                return 0
            case 1:
                return 1
            case 11:
                return -1
            default:
                return wrappedValue
            }
        }
    }
}

// MARK: - NoteName constants

extension MusicTheoryKit.Pitch.NoteName {
    /// Return note name C natural.
    public static let C = Self(letter: .C)

    /// Return note name C-sharp.
    public static let CSharp = Self(letter: .C, accidental: .sharp)

    /// Return note name D-flat.
    public static let DFlat = Self(letter: .D, accidental: .flat)

    /// Return note name D natural.
    public static let D = Self(letter: .D)

    /// Return note name D-sharp.
    public static let DSharp = Self(letter: .D, accidental: .sharp)

    /// Return note name E-flat.
    public static let EFlat = Self(letter: .E, accidental: .flat)

    /// Return note name E natural.
    public static let E = Self(letter: .E)

    /// Return note name F natural.
    public static let F = Self(letter: .F)

    /// Return note name F-sharp.
    public static let FSharp = Self(letter: .F, accidental: .sharp)

    /// Return note name G-flat.
    public static let GFlat = Self(letter: .G, accidental: .flat)

    /// Return note name G natural.
    public static let G = Self(letter: .G)

    /// Return note name G-sharp.
    public static let GSharp = Self(letter: .G, accidental: .sharp)

    /// Return note name A-flat.
    public static let AFlat = Self(letter: .A, accidental: .flat)

    /// Return note name A natural.
    public static let A = Self(letter: .A)

    /// Return note name A-sharp.
    public static let ASharp = Self(letter: .A, accidental: .sharp)

    /// Return note name B-flat.
    public static let BFlat = Self(letter: .B, accidental: .flat)

    /// Return note name B natural.
    public static let B = Self(letter: .B)

    /// Return note name C-flat.
    public static let CFlat = Self(letter: .C, accidental: .flat)

    /// Return note name B-sharp.
    public static let BSharp = Self(letter: .B, accidental: .sharp)
}

// MARK: - Letter

extension MusicTheoryKit.Pitch.NoteName {
    /// Represent the diatonic letter portion of a note name.
    public enum Letter: String, Sendable, CaseIterable, Codable, Hashable, CustomStringConvertible {
        /// The letter C.
        case C

        /// The letter D.
        case D

        /// The letter E.
        case E

        /// The letter F.
        case F

        /// The letter G.
        case G

        /// The letter A.
        case A

        /// The letter B.
        case B

        /// Return the natural pitch class of the letter.
        public var naturalPitchClass: MusicTheoryKit.Pitch.PitchClass {
            switch self {
            case .C:
                return .C
            case .D:
                return .D
            case .E:
                return .E
            case .F:
                return .F
            case .G:
                return .G
            case .A:
                return .A
            case .B:
                return .B
            }
        }

        /// Return the letter's natural circle-of-fifths position.
        public var circleOfFifthsIndex: Int {
            switch self {
            case .C:
                return 0
            case .D:
                return 2
            case .E:
                return 4
            case .F:
                return -1
            case .G:
                return 1
            case .A:
                return 3
            case .B:
                return 5
            }
        }

        /// Return a human-readable description of the note letter.
        public var description: String {
            rawValue
        }

        /// Return the note letter advanced by a given number of diatonic steps.
        ///
        /// - Parameter steps: The number of letter steps to advance.
        /// - Returns: The wrapped diatonic letter after advancing by `steps`.
        public func advanced(by steps: Int) -> Self {
            let letters = Self.allCases
            let currentIndex = letters.firstIndex(of: self)!
            let cardinality = letters.count
            let wrappedIndex = ((currentIndex + steps) % cardinality + cardinality) % cardinality
            return letters[wrappedIndex]
        }
    }
}

// MARK: - Accidental

extension MusicTheoryKit.Pitch.NoteName {
    /// Represent the accidental portion of a note name.
    public enum Accidental: String, Sendable, CaseIterable, Codable, Hashable, CustomStringConvertible {
        /// Lower the letter by one semitone.
        case flat

        /// Leave the letter unaltered.
        case natural

        /// Raise the letter by one semitone.
        case sharp

        /// Return the accidental's chromatic offset in semitones.
        public var chromaticOffset: Int {
            switch self {
            case .flat:
                return -1
            case .natural:
                return 0
            case .sharp:
                return 1
            }
        }

        /// Return the accidental's effect on the circle of fifths.
        public var circleOfFifthsOffset: Int {
            switch self {
            case .flat:
                return -7
            case .natural:
                return 0
            case .sharp:
                return 7
            }
        }

        /// Return a human-readable accidental symbol.
        public var description: String {
            switch self {
            case .flat:
                return "b"
            case .natural:
                return ""
            case .sharp:
                return "#"
            }
        }

        /// Create an accidental from a single-step chromatic offset.
        ///
        /// - Parameter chromaticOffset: The accidental offset to convert.
        /// - Returns: The matching accidental, or `nil` when the offset would require a double accidental.
        public init?(chromaticOffset: Int) {
            switch chromaticOffset {
            case -1:
                self = .flat
            case 0:
                self = .natural
            case 1:
                self = .sharp
            default:
                return nil
            }
        }
    }
}

// MARK: - NoteName conformances

extension MusicTheoryKit.Pitch.NoteName: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the spelled note name.
    public var description: String {
        "\(letter)\(accidental)"
    }

    /// Return the sharp-based default spellings for the chromatic collection.
    private static let sharpSpellings: [Self] = [
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

    /// Return the flat-based default spellings for the chromatic collection.
    private static let flatSpellings: [Self] = [
        .C,
        .DFlat,
        .D,
        .EFlat,
        .E,
        .F,
        .GFlat,
        .G,
        .AFlat,
        .A,
        .BFlat,
        .B,
    ]
}
