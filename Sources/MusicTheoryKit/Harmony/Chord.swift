// Package: MusicTheoryKit
// File: Chord.swift
// Path: Sources/MusicTheoryKit/Harmony/Chord.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah


// MARK: - Chord

extension MusicTheoryKit.Harmony {
    /// Represent a chord as a root pitch class, chord quality, and optional bass pitch class.
    ///
    /// `Chord` derives its chord tones from the root and quality formula rather than storing
    /// a second copy of the resolved pitch classes. When a bass pitch class is present, the chord
    /// can represent inversions and slash-chord spellings.
    public struct Chord: Sendable {
        /// Store the root pitch class of the chord.
        public let root: MusicTheoryKit.Pitch.PitchClass

        /// Store the quality that defines the chord formula.
        public let quality: MusicTheoryKit.Harmony.ChordQuality

        /// Store the optional explicit bass pitch class of the chord.
        public let bass: MusicTheoryKit.Pitch.PitchClass?

        /// Create a chord from a root pitch class, quality, and optional bass pitch class.
        ///
        /// - Parameters:
        ///   - root: The root pitch class of the chord.
        ///   - quality: The quality formula that defines the chord.
        ///   - bass: The optional explicit bass pitch class of the chord.
        public init(
            root: MusicTheoryKit.Pitch.PitchClass,
            quality: MusicTheoryKit.Harmony.ChordQuality,
            bass: MusicTheoryKit.Pitch.PitchClass? = nil
        ) {
            self.root = root
            self.quality = quality
            self.bass = bass
        }

        /// Return the ordered intervals measured from the root.
        public var intervals: [MusicTheoryKit.Pitch.Interval] {
            quality.intervals
        }

        /// Return the ordered pitch classes produced by the root and quality.
        public var pitchClasses: [MusicTheoryKit.Pitch.PitchClass] {
            quality.intervals.map { $0.applied(to: root) }
        }

        /// Return the ordered spelled note names of the chord for a given root spelling.
        ///
        /// Chord tones are spelled according to their implied diatonic function within the chord formula.
        /// The method returns `nil` when the requested spelling would require unsupported double accidentals
        /// or when a provided bass spelling does not match the chord's stored bass pitch class.
        ///
        /// - Parameters:
        ///   - rootNoteName: The spelled root note name to use when naming the chord tones.
        ///   - bassNoteName: The optional explicit bass spelling to use for slash chords.
        /// - Returns: The ordered chord tone note names plus the optional bass note spelling.
        public func noteNames(
            rootNoteName: MusicTheoryKit.Pitch.NoteName,
            bassNoteName: MusicTheoryKit.Pitch.NoteName? = nil
        ) -> [MusicTheoryKit.Pitch.NoteName]? {
            guard rootNoteName.pitchClass == root else {
                return nil
            }

            let spelledTones = zip(intervals.indices, zip(intervals, pitchClasses)).compactMap {
                index, pair in
                rootNoteName.noteName(
                    atDegree: degreeNumber(for: pair.0, toneIndex: index),
                    matching: pair.1
                )
            }

            guard spelledTones.count == intervals.count else {
                return nil
            }

            guard let bass else {
                return spelledTones
            }

            if let bassNoteName {
                guard bassNoteName.pitchClass == bass else {
                    return nil
                }

                return spelledTones + [bassNoteName]
            }

            return spelledTones + [MusicTheoryKit.Pitch.NoteName(pitchClass: bass, preferSharps: true)]
        }

        /// Return the sounding bass pitch class of the chord.
        public var bassPitchClass: MusicTheoryKit.Pitch.PitchClass {
            bass ?? root
        }

        /// Return the number of distinct chord tones in the chord.
        public var toneCount: Int {
            quality.toneCount
        }

        /// Return whether the chord spells an alternate bass different from its root.
        public var hasAlternateBass: Bool {
            bass.map { $0 != root } ?? false
        }

        /// Return whether the chord is in a true inversion.
        ///
        /// Non-chord slash basses do not count as inversions.
        public var isInverted: Bool {
            switch inversion {
            case .first, .second, .third, .fourth, .fifth:
                return true
            case .rootPosition, .slash:
                return false
            }
        }

        /// Return the inversion state of the chord.
        public var inversion: Inversion {
            guard let bass else {
                return .rootPosition
            }

            guard let index = pitchClasses.firstIndex(of: bass) else {
                return .slash
            }

            switch index {
            case 0: return .rootPosition
            case 1: return .first
            case 2: return .second
            case 3: return .third
            case 4: return .fourth
            case 5: return .fifth
            default: return .slash
            }
        }

        /// Return whether the chord contains the given pitch class.
        ///
        /// - Parameter pitchClass: The pitch class to test.
        /// - Returns: `true` when the pitch class belongs to the chord.
        public func contains(_ pitchClass: MusicTheoryKit.Pitch.PitchClass) -> Bool {
            pitchClasses.contains(pitchClass) || bass == pitchClass
        }

        /// Return a copy of the chord with the same quality and a different root.
        ///
        /// - Parameter root: The root pitch class for the transposed chord.
        /// - Returns: A chord with the same quality built on the new root.
        public func transposed(to root: MusicTheoryKit.Pitch.PitchClass) -> Self {
            let semitoneOffset = root - self.root
            let transposedBass = bass?.transposed(by: semitoneOffset)
            return Self(root: root, quality: quality, bass: transposedBass)
        }

        /// Return a copy of the chord with an explicit bass pitch class.
        ///
        /// - Parameter bass: The bass pitch class to assign.
        /// - Returns: A chord with the same root and quality, spelled over the given bass.
        public func withBass(_ bass: MusicTheoryKit.Pitch.PitchClass?) -> Self {
            Self(root: root, quality: quality, bass: bass)
        }

        /// Return the preferred diatonic degree number for a chord tone interval at a given formula position.
        ///
        /// - Parameters:
        ///   - interval: The interval to classify.
        ///   - toneIndex: The zero-based index of the chord tone in the ordered formula.
        /// - Returns: The preferred degree number for spelling the chord tone.
        private func degreeNumber(for interval: MusicTheoryKit.Pitch.Interval, toneIndex: Int) -> Int {
            switch toneIndex {
            case 0:
                return 1
            case 1:
                if interval.rawValue <= 2 {
                    return 2
                }

                if interval.rawValue <= 4 {
                    return 3
                }

                return 4
            case 2:
                return interval.rawValue <= 8 ? 5 : 7
            case 3:
                return interval.rawValue <= 11 ? 7 : 9
            case 4:
                return interval.rawValue <= 17 ? 9 : 11
            case 5:
                return interval.rawValue <= 21 ? 11 : 13
            default:
                return 13
            }
        }
    }
}

// MARK: - Inversion

extension MusicTheoryKit.Harmony.Chord {
    /// Describe the inversion state of a chord.
    public enum Inversion: String, Sendable, Codable, Hashable, CustomStringConvertible {
        /// The root is in the bass.
        case rootPosition

        /// The third is in the bass.
        case first

        /// The fifth is in the bass.
        case second

        /// The seventh is in the bass.
        case third

        /// The ninth or equivalent higher chord tone is in the bass.
        case fourth

        /// The eleventh, thirteenth, or equivalent higher chord tone is in the bass.
        case fifth

        /// The bass is not one of the chord's stored chord tones.
        case slash

        /// Return a human-readable description of the inversion.
        public var description: String {
            switch self {
            case .rootPosition:
                return "Root Position"
            case .first:
                return "First Inversion"
            case .second:
                return "Second Inversion"
            case .third:
                return "Third Inversion"
            case .fourth:
                return "Fourth Inversion"
            case .fifth:
                return "Fifth Inversion"
            case .slash:
                return "Slash Chord"
            }
        }
    }
}

// MARK: - Chord presets

extension MusicTheoryKit.Harmony.Chord {
    /// Create a major chord on the given root.
    ///
    /// - Parameter root: The root pitch class of the chord.
    /// - Returns: A major chord built on the given root.
    public static func major(root: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(root: root, quality: .major)
    }

    /// Create a minor chord on the given root.
    ///
    /// - Parameter root: The root pitch class of the chord.
    /// - Returns: A minor chord built on the given root.
    public static func minor(root: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(root: root, quality: .minor)
    }

    /// Create a diminished chord on the given root.
    ///
    /// - Parameter root: The root pitch class of the chord.
    /// - Returns: A diminished chord built on the given root.
    public static func diminished(root: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(root: root, quality: .diminished)
    }

    /// Create an augmented chord on the given root.
    ///
    /// - Parameter root: The root pitch class of the chord.
    /// - Returns: An augmented chord built on the given root.
    public static func augmented(root: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(root: root, quality: .augmented)
    }

    /// Create a dominant seventh chord on the given root.
    ///
    /// - Parameter root: The root pitch class of the chord.
    /// - Returns: A dominant seventh chord built on the given root.
    public static func dominantSeventh(root: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(root: root, quality: .dominantSeventh)
    }

    /// Create a major seventh chord on the given root.
    ///
    /// - Parameter root: The root pitch class of the chord.
    /// - Returns: A major seventh chord built on the given root.
    public static func majorSeventh(root: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(root: root, quality: .majorSeventh)
    }

    /// Create a minor seventh chord on the given root.
    ///
    /// - Parameter root: The root pitch class of the chord.
    /// - Returns: A minor seventh chord built on the given root.
    public static func minorSeventh(root: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(root: root, quality: .minorSeventh)
    }
}

// MARK: - Chord conformances

extension MusicTheoryKit.Harmony.Chord: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the chord.
    public var description: String {
        guard hasAlternateBass else {
            return "\(root) \(quality)"
        }

        return "\(root) \(quality)/\(bassPitchClass)"
    }
}
