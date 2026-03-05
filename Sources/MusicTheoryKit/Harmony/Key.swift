// Package: MusicTheoryKit
// File: Key.swift
// Path: Sources/MusicTheoryKit/Harmony/Key.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - Key

extension MusicTheoryKit.Harmony {
    /// Represent a musical key as a tonic plus a scale classification.
    ///
    /// `Key` models tonal context rather than a bare pitch collection. Its backing scale is always
    /// derived from the tonic and key kind, which keeps the key definition internally consistent.
    public struct Key: Sendable {
        /// Store the tonic that anchors the key.
        public let tonic: MusicTheoryKit.Pitch.PitchClass

        /// Store the spelled tonic used for notation-aware metadata.
        public let tonicNoteName: MusicTheoryKit.Pitch.NoteName

        /// Store the scale classification that defines the key's tonal collection.
        public let scaleKind: ScaleKind

        /// Create a key from a chromatic tonic and scale classification.
        ///
        /// - Parameters:
        ///   - tonic: The tonic pitch class of the key.
        ///   - scaleKind: The scale classification that defines the key.
        public init(tonic: MusicTheoryKit.Pitch.PitchClass, scaleKind: ScaleKind) {
            self.init(
                tonic: tonic,
                tonicNoteName: .init(pitchClass: tonic, preferSharps: true),
                scaleKind: scaleKind
            )
        }

        /// Create a key from a spelled tonic and scale classification.
        ///
        /// - Parameters:
        ///   - noteName: The spelled tonic of the key.
        ///   - scaleKind: The scale classification that defines the key.
        public init(noteName: MusicTheoryKit.Pitch.NoteName, scaleKind: ScaleKind) {
            self.init(tonic: noteName.pitchClass, tonicNoteName: noteName, scaleKind: scaleKind)
        }

        /// Create a key from fully validated tonic representations.
        ///
        /// - Parameters:
        ///   - tonic: The tonic pitch class of the key.
        ///   - tonicNoteName: The spelled tonic of the key.
        ///   - scaleKind: The scale classification that defines the key.
        private init(
            tonic: MusicTheoryKit.Pitch.PitchClass,
            tonicNoteName: MusicTheoryKit.Pitch.NoteName,
            scaleKind: ScaleKind
        ) {
            self.tonic = tonic
            self.tonicNoteName = tonicNoteName
            self.scaleKind = scaleKind
        }

        /// Return the scale implied by the key's tonic and scale classification.
        public var scale: MusicTheoryKit.Harmony.Scale {
            scaleKind.scale(tonic: tonic)
        }

        /// Return the ordered pitch classes that belong to the key.
        public var pitchClasses: [MusicTheoryKit.Pitch.PitchClass] {
            scale.pitchClasses
        }

        /// Return whether the key contains the given pitch class.
        ///
        /// - Parameter pitchClass: The pitch class to test.
        /// - Returns: `true` when the pitch class belongs to the key.
        public func contains(_ pitchClass: MusicTheoryKit.Pitch.PitchClass) -> Bool {
            scale.contains(pitchClass)
        }

        /// Return the key-signature metadata for this key when it has a conventional signature.
        ///
        /// Keys whose spelled tonic would require more than seven sharps or flats return `nil`,
        /// because they fall outside the conventional key-signature system supported here.
        public var keySignature: KeySignature? {
            let signedAccidentalCount = tonicNoteName.circleOfFifthsIndex + scaleKind.keySignatureOffset

            guard (-7...7).contains(signedAccidentalCount) else {
                return nil
            }

            return .init(signedAccidentalCount: signedAccidentalCount)
        }

        /// Return a copy of the key with the same scale classification and a different tonic.
        ///
        /// - Parameter tonic: The tonic pitch class for the transposed key.
        /// - Returns: A key with the same scale classification and the new tonic.
        public func transposed(to tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
            Self(tonic: tonic, scaleKind: scaleKind)
        }

        /// Return a copy of the key with the same scale classification and a different spelled tonic.
        ///
        /// - Parameter noteName: The spelled tonic for the transposed key.
        /// - Returns: A key with the same scale classification and the new spelled tonic.
        public func transposed(toSpelledTonic noteName: MusicTheoryKit.Pitch.NoteName) -> Self {
            Self(noteName: noteName, scaleKind: scaleKind)
        }

        /// Return the relative major key when the current key belongs to a diatonic major-mode family.
        ///
        /// - Returns: The relative major key that shares the same pitch collection, or `nil` when no diatonic
        ///   relative-major relationship is defined for the current scale classification.
        public var relativeMajor: Self? {
            switch scaleKind {
            case .major:
                return self
            case .naturalMinor, .harmonicMinor, .melodicMinor, .aeolian:
                return transposedKey(
                    semitones: 3,
                    degreeNumber: 3,
                    scaleKind: .major
                )
            case .dorian:
                return transposedKey(
                    semitones: -2,
                    degreeNumber: 7,
                    scaleKind: .major
                )
            case .phrygian:
                return transposedKey(
                    semitones: -4,
                    degreeNumber: 6,
                    scaleKind: .major
                )
            case .lydian:
                return transposedKey(
                    semitones: -5,
                    degreeNumber: 5,
                    scaleKind: .major
                )
            case .mixolydian:
                return transposedKey(
                    semitones: -7,
                    degreeNumber: 4,
                    scaleKind: .major
                )
            case .locrian:
                return transposedKey(
                    semitones: -1,
                    degreeNumber: 2,
                    scaleKind: .major
                )
            }
        }

        /// Return the relative natural minor key when the current key belongs to a major/minor key family.
        ///
        /// - Returns: The relative natural minor key, or `nil` when the current scale classification does not
        ///   define a conventional relative-minor relationship.
        public var relativeNaturalMinor: Self? {
            switch scaleKind {
            case .major:
                return transposedKey(
                    semitones: 9,
                    degreeNumber: 6,
                    scaleKind: .naturalMinor
                )
            case .naturalMinor, .harmonicMinor, .melodicMinor, .aeolian:
                return .init(noteName: tonicNoteName, scaleKind: .naturalMinor)
            default:
                return nil
            }
        }

        /// Return the parallel major key when the current key has a conventional major/minor pairing.
        ///
        /// - Returns: The parallel major key, or `nil` when the current scale classification is modal.
        public var parallelMajor: Self? {
            switch scaleKind {
            case .major:
                return self
            case .naturalMinor, .harmonicMinor, .melodicMinor, .aeolian:
                return .init(noteName: tonicNoteName, scaleKind: .major)
            default:
                return nil
            }
        }

        /// Return the parallel natural minor key when the current key has a conventional major/minor pairing.
        ///
        /// - Returns: The parallel natural minor key, or `nil` when the current scale classification is modal.
        public var parallelNaturalMinor: Self? {
            switch scaleKind {
            case .major:
                return .init(noteName: tonicNoteName, scaleKind: .naturalMinor)
            case .naturalMinor, .harmonicMinor, .melodicMinor, .aeolian:
                return .init(noteName: tonicNoteName, scaleKind: .naturalMinor)
            default:
                return nil
            }
        }

        /// Return a key transposed from the current tonic while preserving spelling when representable.
        ///
        /// - Parameters:
        ///   - semitones: The chromatic transposition from the current tonic.
        ///   - degreeNumber: The target one-based diatonic degree relative to the current tonic spelling.
        ///   - scaleKind: The scale kind to assign to the derived key.
        /// - Returns: A key with the requested transposition and scale kind.
        private func transposedKey(
            semitones: Int,
            degreeNumber: Int,
            scaleKind: ScaleKind
        ) -> Self {
            let transposedPitchClass = tonic.transposed(by: semitones)

            if let transposedNoteName = tonicNoteName.noteName(
                atDegree: degreeNumber,
                matching: transposedPitchClass
            ) {
                return .init(noteName: transposedNoteName, scaleKind: scaleKind)
            }

            return .init(tonic: transposedPitchClass, scaleKind: scaleKind)
        }
    }
}

// MARK: - ScaleKind

extension MusicTheoryKit.Harmony.Key {
    /// Describe the accidental direction used by a key signature.
    public enum AccidentalType: String, Sendable, Codable, Hashable, CustomStringConvertible {
        /// The signature uses sharps.
        case sharps

        /// The signature uses flats.
        case flats

        /// Return a human-readable description of the accidental direction.
        public var description: String {
            switch self {
            case .sharps:
                return "Sharps"
            case .flats:
                return "Flats"
            }
        }
    }
}

// MARK: - KeySignature

extension MusicTheoryKit.Harmony.Key {
    /// Represent the notational metadata of a conventional key signature.
    public struct KeySignature: Sendable, Codable, Hashable, CustomStringConvertible {
        /// Store the signed accidental count, where positive values add sharps and negative values add flats.
        public let signedAccidentalCount: Int

        /// Create key-signature metadata from a signed accidental count.
        ///
        /// - Parameter signedAccidentalCount: The signed accidental count in the range `-7...7`.
        init(signedAccidentalCount: Int) {
            self.signedAccidentalCount = signedAccidentalCount
        }

        /// Return the absolute number of accidentals in the signature.
        public var accidentalCount: Int {
            abs(signedAccidentalCount)
        }

        /// Return the accidental direction of the signature, or `nil` when the signature is empty.
        public var accidentalType: MusicTheoryKit.Harmony.Key.AccidentalType? {
            if signedAccidentalCount > 0 {
                return .sharps
            }

            if signedAccidentalCount < 0 {
                return .flats
            }

            return nil
        }

        /// Return the affected note letters in key-signature order.
        public var alteredLetters: [MusicTheoryKit.Pitch.NoteName.Letter] {
            switch accidentalType {
            case .sharps:
                return Array(Self.sharpOrder.prefix(accidentalCount))
            case .flats:
                return Array(Self.flatOrder.prefix(accidentalCount))
            case nil:
                return []
            }
        }

        /// Return a human-readable description of the key signature.
        public var description: String {
            guard let accidentalType else {
                return "No Accidentals"
            }

            let accidentalLabel: String

            switch accidentalType {
            case .sharps:
                accidentalLabel = accidentalCount == 1 ? "sharp" : "sharps"
            case .flats:
                accidentalLabel = accidentalCount == 1 ? "flat" : "flats"
            }

            return "\(accidentalCount) \(accidentalLabel)"
        }

        /// Return the order in which sharps appear in conventional key signatures.
        private static let sharpOrder: [MusicTheoryKit.Pitch.NoteName.Letter] = [.F, .C, .G, .D, .A, .E, .B]

        /// Return the order in which flats appear in conventional key signatures.
        private static let flatOrder: [MusicTheoryKit.Pitch.NoteName.Letter] = [.B, .E, .A, .D, .G, .C, .F]
    }
}

// MARK: - ScaleKind

extension MusicTheoryKit.Harmony.Key {
    /// Describe the supported scale classifications for a key.
    public enum ScaleKind: String, Sendable, CaseIterable {
        /// Represent a major key.
        case major

        /// Represent a natural minor key.
        case naturalMinor

        /// Represent a harmonic minor key.
        case harmonicMinor

        /// Represent a melodic minor key.
        case melodicMinor

        /// Represent a Dorian key.
        case dorian

        /// Represent a Phrygian key.
        case phrygian

        /// Represent a Lydian key.
        case lydian

        /// Represent a Mixolydian key.
        case mixolydian

        /// Represent an Aeolian key.
        case aeolian

        /// Represent a Locrian key.
        case locrian

        /// Return the backing scale for this scale classification and tonic.
        ///
        /// - Parameter tonic: The tonic pitch class of the key.
        /// - Returns: The scale implied by this scale classification.
        public func scale(tonic: MusicTheoryKit.Pitch.PitchClass) -> MusicTheoryKit.Harmony.Scale {
            switch self {
            case .major:
                return .major(tonic: tonic)
            case .naturalMinor:
                return .naturalMinor(tonic: tonic)
            case .harmonicMinor:
                return .harmonicMinor(tonic: tonic)
            case .melodicMinor:
                return .melodicMinor(tonic: tonic)
            case .dorian:
                return .dorian(tonic: tonic)
            case .phrygian:
                return .phrygian(tonic: tonic)
            case .lydian:
                return .lydian(tonic: tonic)
            case .mixolydian:
                return .mixolydian(tonic: tonic)
            case .aeolian:
                return .aeolian(tonic: tonic)
            case .locrian:
                return .locrian(tonic: tonic)
            }
        }

        /// Return the circle-of-fifths offset needed to derive the key signature for this mode.
        public var keySignatureOffset: Int {
            switch self {
            case .major:
                return 0
            case .naturalMinor, .harmonicMinor, .melodicMinor, .aeolian:
                return -3
            case .dorian:
                return -2
            case .phrygian:
                return -4
            case .lydian:
                return 1
            case .mixolydian:
                return -1
            case .locrian:
                return -5
            }
        }
    }
}

// MARK: - Key presets

extension MusicTheoryKit.Harmony.Key {
    /// Create a major key for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the key.
    /// - Returns: A major key built on the given tonic.
    public static func major(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(tonic: tonic, scaleKind: .major)
    }

    /// Create a natural minor key for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the key.
    /// - Returns: A natural minor key built on the given tonic.
    public static func naturalMinor(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(tonic: tonic, scaleKind: .naturalMinor)
    }

    /// Create a harmonic minor key for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the key.
    /// - Returns: A harmonic minor key built on the given tonic.
    public static func harmonicMinor(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(tonic: tonic, scaleKind: .harmonicMinor)
    }

    /// Create a melodic minor key for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the key.
    /// - Returns: A melodic minor key built on the given tonic.
    public static func melodicMinor(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(tonic: tonic, scaleKind: .melodicMinor)
    }

}

// MARK: - ScaleKind conformances

extension MusicTheoryKit.Harmony.Key.ScaleKind: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the scale classification.
    public var description: String {
        switch self {
        case .major:
            return "Major"
        case .naturalMinor:
            return "Natural Minor"
        case .harmonicMinor:
            return "Harmonic Minor"
        case .melodicMinor:
            return "Melodic Minor"
        case .dorian:
            return "Dorian"
        case .phrygian:
            return "Phrygian"
        case .lydian:
            return "Lydian"
        case .mixolydian:
            return "Mixolydian"
        case .aeolian:
            return "Aeolian"
        case .locrian:
            return "Locrian"
        }
    }
}

// MARK: - Key conformances

extension MusicTheoryKit.Harmony.Key: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the key.
    public var description: String {
        "\(tonicNoteName) \(scaleKind)"
    }
}
