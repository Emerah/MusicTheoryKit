// Package: MusicTheoryKit
// File: ChordProgression.swift
// Path: Sources/MusicTheoryKit/Harmony/ChordProgression.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - ChordProgression

extension MusicTheoryKit.Harmony {
    /// Represent a diatonic chord progression as a key plus an ordered list of scale degrees.
    ///
    /// `ChordProgression` derives concrete chords from its key and degrees instead of storing
    /// a second copy of the resolved chords. Chords are currently built as diatonic triads.
    public struct ChordProgression: Sendable {
        /// Store the key that defines the progression's harmonic context.
        public let key: MusicTheoryKit.Harmony.Key

        /// Store the ordered harmonic degrees of the progression.
        public let degrees: [MusicTheoryKit.Harmony.Degree]

        /// Create a chord progression from a key and degree sequence.
        ///
        /// - Parameters:
        ///   - key: The key that defines the harmonic context.
        ///   - degrees: The ordered scale degrees of the progression.
        ///
        /// - Returns: `nil` when any degree exceeds the number of degrees available in the key's scale.
        public init?(key: MusicTheoryKit.Harmony.Key, degrees: [MusicTheoryKit.Harmony.Degree]) {
            guard Self.isValid(degrees, in: key) else {
                return nil
            }

            self.init(validatedKey: key, degrees: degrees)
        }

        /// Create a progression after its degree sequence has already been validated.
        ///
        /// - Parameters:
        ///   - validatedKey: The key that defines the harmonic context.
        ///   - degrees: A valid ordered scale-degree sequence.
        private init(validatedKey: MusicTheoryKit.Harmony.Key, degrees: [MusicTheoryKit.Harmony.Degree]) {
            key = validatedKey
            self.degrees = degrees
        }

        /// Return the concrete diatonic chords implied by the progression.
        public var chords: [MusicTheoryKit.Harmony.Chord] {
            degrees.compactMap(chord(for:))
        }

        /// Return the harmonic functions implied by the progression's degrees in its key.
        public var harmonicFunctions: [MusicTheoryKit.Harmony.Degree.HarmonicFunction?] {
            degrees.map { $0.harmonicFunction(in: key) }
        }

        /// Return the cadence detected at the end of the progression when a supported pattern is present.
        public var cadence: Cadence? {
            guard degrees.count >= 2 else {
                return nil
            }

            let penultimate = degrees[degrees.count - 2]
            let ultimate = degrees[degrees.count - 1]

            if isAuthenticCadence(from: penultimate, to: ultimate) {
                return .authentic
            }

            if isPlagalCadence(from: penultimate, to: ultimate) {
                return .plagal
            }

            if isDeceptiveCadence(from: penultimate, to: ultimate) {
                return .deceptive
            }

            if isHalfCadence(from: penultimate, to: ultimate) {
                return .half
            }

            return nil
        }

        /// Return whether the progression contains the given degree.
        ///
        /// - Parameter degree: The degree to test.
        /// - Returns: `true` when the degree appears in the progression.
        public func contains(_ degree: MusicTheoryKit.Harmony.Degree) -> Bool {
            degrees.contains(degree)
        }

        /// Return whether the progression ends with the requested cadence type.
        ///
        /// - Parameter cadence: The cadence type to test.
        /// - Returns: `true` when the detected cadence matches the requested cadence.
        public func endsWithCadence(_ cadence: Cadence) -> Bool {
            self.cadence == cadence
        }

        /// Return the diatonic triad for a degree in the progression's key.
        ///
        /// - Parameter degree: The degree to resolve.
        /// - Returns: The derived diatonic triad, or `nil` when the degree is outside the key's scale.
        public func chord(for degree: MusicTheoryKit.Harmony.Degree) -> MusicTheoryKit.Harmony.Chord? {
            let pitchClasses = key.pitchClasses

            guard degree.zeroBasedIndex < pitchClasses.count else {
                return nil
            }

            let root = pitchClasses[degree.zeroBasedIndex]
            let third = pitchClasses[wrappedIndex(from: degree.zeroBasedIndex, offset: 2, count: pitchClasses.count)]
            let fifth = pitchClasses[wrappedIndex(from: degree.zeroBasedIndex, offset: 4, count: pitchClasses.count)]

            let intervals: [MusicTheoryKit.Pitch.Interval] = [
                .unison,
                .init(from: root, to: third),
                .init(from: root, to: fifth),
            ]

            guard let quality = MusicTheoryKit.Harmony.ChordQuality(intervals: intervals) else {
                return nil
            }

            return .init(root: root, quality: quality)
        }

        /// Return a copy of the progression transposed to a new tonic while preserving key kind and degrees.
        ///
        /// - Parameter tonic: The tonic pitch class for the transposed progression.
        /// - Returns: A progression with the same key kind and degrees built on the new tonic.
        public func transposed(to tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
            Self(validatedKey: key.transposed(to: tonic), degrees: degrees)
        }

        /// Return whether a degree sequence is valid for a given key.
        ///
        /// - Parameters:
        ///   - degrees: The degree sequence to validate.
        ///   - key: The key whose scale bounds the sequence.
        /// - Returns: `true` when every degree is available in the key's scale.
        private static func isValid(_ degrees: [MusicTheoryKit.Harmony.Degree], in key: MusicTheoryKit.Harmony.Key) -> Bool {
            degrees.allSatisfy { $0.rawValue <= key.scale.degreeCount }
        }

        /// Return a wrapped scale index for tertian chord construction.
        ///
        /// - Parameters:
        ///   - index: The starting scale index.
        ///   - offset: The number of scale steps to advance.
        ///   - count: The number of degrees in the scale.
        /// - Returns: A valid wrapped scale index.
        private func wrappedIndex(from index: Int, offset: Int, count: Int) -> Int {
            (index + offset) % count
        }

        /// Return whether the tail of the progression forms an authentic cadence.
        ///
        /// - Parameters:
        ///   - penultimate: The penultimate degree.
        ///   - ultimate: The final degree.
        /// - Returns: `true` when the tail resolves dominant to tonic.
        private func isAuthenticCadence(from penultimate: MusicTheoryKit.Harmony.Degree, to ultimate: MusicTheoryKit.Harmony.Degree) -> Bool {
            penultimate.harmonicFunction(in: key) == .dominant && ultimate == .I
        }

        /// Return whether the tail of the progression forms a plagal cadence.
        ///
        /// - Parameters:
        ///   - penultimate: The penultimate degree.
        ///   - ultimate: The final degree.
        /// - Returns: `true` when the tail resolves IV to I.
        private func isPlagalCadence(from penultimate: MusicTheoryKit.Harmony.Degree, to ultimate: MusicTheoryKit.Harmony.Degree) -> Bool {
            penultimate == .IV && ultimate == .I
        }

        /// Return whether the tail of the progression forms a deceptive cadence.
        ///
        /// - Parameters:
        ///   - penultimate: The penultimate degree.
        ///   - ultimate: The final degree.
        /// - Returns: `true` when the tail resolves dominant to VI.
        private func isDeceptiveCadence(from penultimate: MusicTheoryKit.Harmony.Degree, to ultimate: MusicTheoryKit.Harmony.Degree) -> Bool {
            penultimate.harmonicFunction(in: key) == .dominant && ultimate == .VI
        }

        /// Return whether the tail of the progression forms a half cadence.
        ///
        /// - Parameters:
        ///   - penultimate: The penultimate degree.
        ///   - ultimate: The final degree.
        /// - Returns: `true` when the progression ends on dominant without matching a stronger cadence type.
        private func isHalfCadence(from penultimate: MusicTheoryKit.Harmony.Degree, to ultimate: MusicTheoryKit.Harmony.Degree) -> Bool {
            ultimate.harmonicFunction(in: key) == .dominant
        }
    }
}

// MARK: - Cadence

extension MusicTheoryKit.Harmony.ChordProgression {
    /// Describe the cadence detected at the end of a progression.
    public enum Cadence: String, Sendable, Codable, Hashable, CustomStringConvertible {
        /// Dominant resolves to tonic.
        case authentic

        /// Progression ends on dominant.
        case half

        /// Subdominant resolves to tonic.
        case plagal

        /// Dominant resolves deceptively to the submediant.
        case deceptive

        /// Return a human-readable description of the cadence.
        public var description: String {
            switch self {
            case .authentic:
                return "Authentic Cadence"
            case .half:
                return "Half Cadence"
            case .plagal:
                return "Plagal Cadence"
            case .deceptive:
                return "Deceptive Cadence"
            }
        }
    }
}

// MARK: - ChordProgression conformances

extension MusicTheoryKit.Harmony.ChordProgression: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the progression.
    public var description: String {
        let symbols = degrees.map(\.description).joined(separator: " - ")
        return "\(key): \(symbols)"
    }
}
