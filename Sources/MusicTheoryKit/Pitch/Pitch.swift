// Package: MusicTheoryKit
// File: Pitch.swift
// Path: Sources/MusicTheoryKit/Pitch/Pitch.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Foundation

// MARK: - Pitch

extension MusicTheoryKit.Pitch {
    /// Represent a concrete pitch as a pitch class plus octave.
    ///
    /// `Pitch` models an octave-aware note identity using twelve-tone equal temperament.
    /// Its absolute position is measured from `C0`, whose chromatic index is `0`.
    public struct Pitch: Sendable {
        /// Store the pitch class component of the pitch.
        public let pitchClass: MusicTheoryKit.Pitch.PitchClass

        /// Store the octave component of the pitch.
        public let octave: Int

        /// Create a pitch from a pitch class and octave.
        ///
        /// - Parameters:
        ///   - pitchClass: The chromatic class of the pitch.
        ///   - octave: The octave containing the pitch class.
        public init(pitchClass: MusicTheoryKit.Pitch.PitchClass, octave: Int) {
            self.pitchClass = pitchClass
            self.octave = octave
        }

        /// Create a pitch from an absolute chromatic index measured from `C0`.
        ///
        /// - Parameter chromaticIndex: The signed chromatic index to resolve into pitch class and octave.
        public init(chromaticIndex: Int) {
            let pitchClass = MusicTheoryKit.Pitch.PitchClass(rawValue: chromaticIndex)
            let octave = Self.resolveOctave(from: chromaticIndex, pitchClass: pitchClass)

            self.init(pitchClass: pitchClass, octave: octave)
        }

        /// Create a pitch from a standard MIDI note number.
        ///
        /// MIDI note number `0` maps to `C-1`, and `60` maps to `C4`.
        ///
        /// - Parameter midiNoteNumber: The MIDI note number to convert.
        ///
        /// - Returns: `nil` when the note number falls outside the standard MIDI range `0...127`.
        public init?(midiNoteNumber: Int) {
            guard Self.midiNoteNumberRange.contains(midiNoteNumber) else {
                return nil
            }

            self.init(chromaticIndex: midiNoteNumber - Self.midiNoteNumberOffset)
        }

        /// Return the absolute chromatic index measured from `C0`.
        public var chromaticIndex: Int {
            (octave * MusicTheoryKit.Pitch.PitchClass.chromaticCardinality) + pitchClass.rawValue
        }

        /// Return the standard MIDI note number for the pitch when it falls inside `0...127`.
        public var midiNoteNumber: Int? {
            let noteNumber = chromaticIndex + Self.midiNoteNumberOffset
            return Self.midiNoteNumberRange.contains(noteNumber) ? noteNumber : nil
        }

        /// Return a new pitch transposed by the given number of semitones.
        ///
        /// - Parameter semitones: The signed semitone offset to apply.
        /// - Returns: A new pitch resolved from the transposed chromatic index.
        public func transposed(by semitones: Int) -> Self {
            Self(chromaticIndex: chromaticIndex + semitones)
        }

        /// Return the equal-tempered frequency of the pitch.
        ///
        /// The calculation uses `A4` as the tuning reference and assumes twelve-tone equal temperament.
        ///
        /// - Parameter referenceA4: The reference frequency for `A4` in hertz.
        /// - Returns: The equal-tempered frequency of the pitch in hertz.
        public func frequency(referenceA4: Double = 440) -> Double {
            referenceA4 * pow(2, Double(chromaticIndex - Self.a4ChromaticIndex) / Double(Self.semitonesPerOctave))
        }

        /// Return the signed chromatic distance to another pitch.
        ///
        /// - Parameter other: The destination pitch.
        /// - Returns: A signed semitone distance where positive values move upward.
        public func distance(to other: Self) -> Int {
            other.chromaticIndex - chromaticIndex
        }

        /// Resolve the nearest equal-tempered pitch for a frequency.
        ///
        /// The conversion uses `A4` as the tuning reference and rounds to the nearest chromatic pitch.
        ///
        /// - Parameters:
        ///   - frequency: The source frequency in hertz.
        ///   - referenceA4: The reference frequency for `A4` in hertz.
        /// - Returns: The nearest equal-tempered pitch, or `nil` when either frequency is not greater than zero.
        public static func fromFrequency(_ frequency: Double, referenceA4: Double = 440) -> Self? {
            guard frequency > 0, referenceA4 > 0 else {
                return nil
            }

            let semitoneOffset = 12 * log2(frequency / referenceA4)
            let chromaticIndex = Int(semitoneOffset.rounded()) + a4ChromaticIndex

            return Self(chromaticIndex: chromaticIndex)
        }

        /// Resolve the octave component that corresponds to a chromatic index and normalized pitch class.
        ///
        /// - Parameters:
        ///   - chromaticIndex: The signed chromatic index measured from `C0`.
        ///   - pitchClass: The normalized pitch class resolved from the same index.
        /// - Returns: The octave containing the resolved pitch class.
        private static func resolveOctave(from chromaticIndex: Int, pitchClass: MusicTheoryKit.Pitch.PitchClass) -> Int {
            (chromaticIndex - pitchClass.rawValue) / MusicTheoryKit.Pitch.PitchClass.chromaticCardinality
        }

        /// Return the chromatic index of `A4`, the standard tuning reference pitch.
        private static let a4ChromaticIndex = 57

        /// Return the chromatic offset between `C0` and MIDI note number `0`.
        private static let midiNoteNumberOffset = 12

        /// Return the number of semitones in one octave.
        private static let semitonesPerOctave = 12

        /// Return the standard MIDI note-number range.
        private static let midiNoteNumberRange = 0 ... 127
    }
}

// MARK: - Pitch conformances

extension MusicTheoryKit.Pitch.Pitch: Comparable, CustomStringConvertible, Hashable, Codable {
    /// Compare pitches by absolute chromatic position.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand pitch.
    ///   - rhs: The right-hand pitch.
    /// - Returns: `true` when `lhs` sounds lower than `rhs`.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.chromaticIndex < rhs.chromaticIndex
    }

    /// Return a sharp-based textual representation of the pitch.
    public var description: String {
        "\(pitchClass)\(octave)"
    }
}

// MARK: - Pitch operators

extension MusicTheoryKit.Pitch.Pitch {
    /// Transpose a pitch upward or downward by a semitone offset.
    ///
    /// - Parameters:
    ///   - lhs: The source pitch.
    ///   - rhs: The signed semitone offset.
    /// - Returns: A transposed pitch.
    public static func + (lhs: Self, rhs: Int) -> Self {
        lhs.transposed(by: rhs)
    }

    /// Measure the signed chromatic distance between two pitches.
    ///
    /// - Parameters:
    ///   - lhs: The source pitch.
    ///   - rhs: The destination pitch.
    /// - Returns: A signed semitone distance from `rhs` to `lhs`.
    public static func - (lhs: Self, rhs: Self) -> Int {
        rhs.distance(to: lhs)
    }
}
