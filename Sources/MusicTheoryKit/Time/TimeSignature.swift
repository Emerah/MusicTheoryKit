// Package: MusicTheoryKit
// File: TimeSignature.swift
// Path: Sources/MusicTheoryKit/Time/TimeSignature.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - TimeSignature

extension MusicTheoryKit.Time {
    /// Represent a notated time signature as a numerator and denominator.
    ///
    /// `TimeSignature` models meter in denominator-note beats. The denominator must be a power of two
    /// so it can describe a conventional note value such as quarter notes or eighth notes.
    public struct TimeSignature: Sendable {
        /// Store the number of beats in each measure.
        public let numerator: Int

        /// Store the note value that receives one beat.
        public let denominator: Int

        /// Create a time signature from a numerator and denominator.
        ///
        /// - Parameters:
        ///   - numerator: The number of beats in each measure.
        ///   - denominator: The note value that receives one beat.
        ///
        /// - Returns: `nil` when `numerator` is not greater than zero, `denominator` is not greater than zero,
        ///   or `denominator` is not a power of two.
        public init?(numerator: Int, denominator: Int) {
            guard numerator > 0, Self.isPowerOfTwo(denominator) else {
                return nil
            }

            self.numerator = numerator
            self.denominator = denominator
        }

        /// Return the duration of a measure in local denominator-note beats.
        public var beatCount: Double {
            Double(numerator)
        }

        /// Return whether the meter is compound.
        ///
        /// Compound meters are currently defined as meters whose numerators are divisible by `3`
        /// and greater than `3`, such as `6/8` or `12/8`.
        public var isCompound: Bool {
            numerator > 3 && numerator.isMultiple(of: 3)
        }

        /// Return the whole-beat positions that carry metric accents within the measure.
        ///
        /// The first beat is always included. Compound meters accent every three denominator-note beats
        /// after the downbeat. Simple even meters accent the midpoint beat as a secondary accent.
        public var accentedBeats: [Double] {
            var beats = [0.0]

            if isCompound {
                beats.append(contentsOf: stride(from: 3, to: numerator, by: 3).map(Double.init))
                return beats
            }

            guard numerator >= 4, numerator.isMultiple(of: 2) else {
                return beats
            }

            beats.append(Double(numerator / 2))
            return beats
        }

        /// Return the metrical strength of a beat position when it falls on a whole beat.
        ///
        /// - Parameter beat: The local denominator-note beat position to analyze.
        /// - Returns: The metrical strength of `beat`, or `nil` when `beat` is not a whole beat or falls outside the measure.
        public func beatStrength(at beat: Double) -> MusicTheoryKit.Time.Measure.BeatStrength? {
            guard (0..<beatCount).contains(beat), beat.rounded(.towardZero) == beat else {
                return nil
            }

            if beat == 0 {
                return .strong
            }

            if accentedBeats.dropFirst().contains(beat) {
                return .medium
            }

            return .weak
        }

        /// Return whether an integer is a power of two.
        ///
        /// - Parameter value: The integer to validate.
        /// - Returns: `true` when `value` is a positive power of two.
        private static func isPowerOfTwo(_ value: Int) -> Bool {
            value > 0 && (value & (value - 1)) == 0
        }
    }
}

// MARK: - TimeSignature conformances

extension MusicTheoryKit.Time.TimeSignature: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the time signature.
    public var description: String {
        "\(numerator)/\(denominator)"
    }
}
