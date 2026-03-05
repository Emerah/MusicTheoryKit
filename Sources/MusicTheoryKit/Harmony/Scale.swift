// Package: MusicTheoryKit
// File: Scale.swift
// Path: Sources/MusicTheoryKit/Harmony/Scale.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - Scale

extension MusicTheoryKit.Harmony {
    /// Represent a scale as a tonic plus an ordered interval pattern within one octave.
    ///
    /// `Scale` stores intervals relative to its tonic. The interval pattern must begin with unison,
    /// remain strictly ascending, and stay within a single octave without repeating the octave itself.
    public struct Scale: Sendable {
        /// Store the tonic that anchors the scale.
        public let tonic: MusicTheoryKit.Pitch.PitchClass

        /// Store the ordered interval pattern measured from the tonic.
        public let intervals: [MusicTheoryKit.Pitch.Interval]

        /// Create a scale from a tonic and interval pattern.
        ///
        /// - Parameters:
        ///   - tonic: The tonic pitch class of the scale.
        ///   - intervals: The ordered interval pattern relative to the tonic.
        ///
        /// - Returns: `nil` when the interval pattern is empty, does not begin with unison,
        ///   is not strictly ascending, or extends beyond a single octave.
        public init?(tonic: MusicTheoryKit.Pitch.PitchClass, intervals: [MusicTheoryKit.Pitch.Interval]) {
            guard Self.isValid(intervals) else {
                return nil
            }

            self.init(validatedTonic: tonic, intervals: intervals)
        }

        /// Create a scale after its interval pattern has already been validated.
        ///
        /// - Parameters:
        ///   - validatedTonic: The tonic pitch class of the scale.
        ///   - intervals: A valid ordered interval pattern relative to the tonic.
        private init(validatedTonic: MusicTheoryKit.Pitch.PitchClass, intervals: [MusicTheoryKit.Pitch.Interval]) {
            tonic = validatedTonic
            self.intervals = intervals
        }

        /// Return the number of degrees in the scale.
        public var degreeCount: Int {
            intervals.count
        }

        /// Return the diatonic degrees supported by the scale.
        ///
        /// Degrees are generated from the scale's interval count, so pentatonic and hexatonic scales
        /// expose fewer available degrees than diatonic seven-note scales.
        public var degrees: [MusicTheoryKit.Harmony.Degree] {
            (1 ... degreeCount).compactMap(MusicTheoryKit.Harmony.Degree.init(rawValue:))
        }

        /// Return the ordered pitch classes produced by the tonic and interval pattern.
        public var pitchClasses: [MusicTheoryKit.Pitch.PitchClass] {
            intervals.map { $0.applied(to: tonic) }
        }

        /// Return the ordered chromatic step pattern of the scale, including the closing step to the octave.
        ///
        /// For example, a major scale returns `[2, 2, 1, 2, 2, 2, 1]`.
        public var stepPattern: [Int] {
            let upperBound = MusicTheoryKit.Pitch.PitchClass.chromaticCardinality
            let semitoneValues = intervals.map(\.rawValue) + [upperBound]

            return zip(semitoneValues, semitoneValues.dropFirst()).map { nextPair in
                nextPair.1 - nextPair.0
            }
        }

        /// Return the interval associated with the given degree.
        ///
        /// - Parameter degree: The scale degree to resolve.
        /// - Returns: The interval stored at the requested degree, or `nil` when the degree is not present.
        public func interval(at degree: MusicTheoryKit.Harmony.Degree) -> MusicTheoryKit.Pitch.Interval? {
            guard degree.zeroBasedIndex < intervals.count else {
                return nil
            }

            return intervals[degree.zeroBasedIndex]
        }

        /// Return the pitch class associated with the given degree.
        ///
        /// - Parameter degree: The scale degree to resolve.
        /// - Returns: The pitch class at the requested degree, or `nil` when the degree is not present.
        public func pitchClass(at degree: MusicTheoryKit.Harmony.Degree) -> MusicTheoryKit.Pitch.PitchClass? {
            guard let interval = interval(at: degree) else {
                return nil
            }

            return interval.applied(to: tonic)
        }

        /// Return the ordered degree-to-pitch-class mapping for the scale.
        public var degreePitchClasses: [(degree: MusicTheoryKit.Harmony.Degree, pitchClass: MusicTheoryKit.Pitch.PitchClass)] {
            degrees.compactMap { degree in
                guard let pitchClass = pitchClass(at: degree) else {
                    return nil
                }

                return (degree, pitchClass)
            }
        }

        /// Return the ordered spelled note names of the scale for a given tonic spelling.
        ///
        /// The spelling follows diatonic degree order from the provided tonic and fails when any note would
        /// require an accidental outside the current `NoteName` model.
        ///
        /// - Parameter tonicNoteName: The spelled tonic to use when naming the scale.
        /// - Returns: The ordered scale note names, or `nil` when the spelling cannot be represented.
        public func noteNames(
            tonicNoteName: MusicTheoryKit.Pitch.NoteName
        ) -> [MusicTheoryKit.Pitch.NoteName]? {
            guard tonicNoteName.pitchClass == tonic else {
                return nil
            }

            var noteNames: [MusicTheoryKit.Pitch.NoteName] = []

            for (degree, pitchClass) in degreePitchClasses {
                guard let noteName = tonicNoteName.noteName(atDegree: degree.rawValue, matching: pitchClass) else {
                    return nil
                }

                noteNames.append(noteName)
            }

            return noteNames
        }

        /// Return whether the scale contains the given pitch class.
        ///
        /// - Parameter pitchClass: The pitch class to test.
        /// - Returns: `true` when the scale contains the pitch class.
        public func contains(_ pitchClass: MusicTheoryKit.Pitch.PitchClass) -> Bool {
            pitchClasses.contains(pitchClass)
        }

        /// Return whether the scale contains the given degree.
        ///
        /// - Parameter degree: The degree to test.
        /// - Returns: `true` when the degree exists in the scale.
        public func contains(_ degree: MusicTheoryKit.Harmony.Degree) -> Bool {
            degree.zeroBasedIndex < degreeCount
        }

        /// Return a copy of the scale with the same interval pattern and a different tonic.
        ///
        /// - Parameter tonic: The tonic pitch class for the transposed scale.
        /// - Returns: A scale with the same interval pattern anchored at the new tonic.
        public func transposed(to tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
            Self(validatedTonic: tonic, intervals: intervals)
        }

        /// Derive the mode that begins on the given degree of the scale.
        ///
        /// The resulting scale rotates the pitch collection so that the requested degree becomes the new tonic,
        /// and all intervals are re-normalized relative to that tonic.
        ///
        /// - Parameter degree: The degree that should become the tonic of the derived mode.
        /// - Returns: A derived mode of the scale, or `nil` when the degree is not present.
        public func mode(startingOn degree: MusicTheoryKit.Harmony.Degree) -> Self? {
            guard degree.zeroBasedIndex < intervals.count else {
                return nil
            }

            let modeTonic = pitchClasses[degree.zeroBasedIndex]
            let pivot = intervals[degree.zeroBasedIndex]
            let rotatedIntervals = rotate(intervals, soFirstIndexIs: degree.zeroBasedIndex).map {
                MusicTheoryKit.Pitch.Interval(rawValue: normalize($0.rawValue - pivot.rawValue))
            }

            return Self(tonic: modeTonic, intervals: rotatedIntervals)
        }

        /// Return all modes derivable from the scale in ascending degree order.
        public var modes: [Self] {
            degrees.compactMap { mode(startingOn: $0) }
        }

        /// Return whether another scale has the same interval pattern relative to its tonic.
        ///
        /// This comparison ignores tonic and checks only the stored interval structure.
        ///
        /// - Parameter other: The scale to compare.
        /// - Returns: `true` when both scales have the same interval pattern.
        public func hasSamePattern(as other: Self) -> Bool {
            intervals == other.intervals
        }

        /// Return whether another scale is a mode of the same pitch collection.
        ///
        /// This comparison ignores tonic and checks whether the scales share the same cyclic step pattern.
        ///
        /// - Parameter other: The scale to compare.
        /// - Returns: `true` when both scales are modal rotations of the same pattern.
        public func isMode(of other: Self) -> Bool {
            guard stepPattern.count == other.stepPattern.count else {
                return false
            }

            let doubledPattern = other.stepPattern + other.stepPattern

            for startIndex in other.stepPattern.indices {
                let endIndex = startIndex + stepPattern.count
                let candidate = Array(doubledPattern[startIndex ..< endIndex])

                if candidate == stepPattern {
                    return true
                }
            }

            return false
        }

        /// Return the chromatic step-by-step difference from another scale pattern.
        ///
        /// Positive values indicate larger steps in `self`, and negative values indicate larger steps in `other`.
        ///
        /// - Parameter other: The scale to compare.
        /// - Returns: A per-step difference array when both scales have the same number of steps, otherwise `nil`.
        public func stepPatternDifference(from other: Self) -> [Int]? {
            guard stepPattern.count == other.stepPattern.count else {
                return nil
            }

            return zip(stepPattern, other.stepPattern).map(-)
        }

        /// Return whether an interval pattern forms a valid scale definition.
        ///
        /// - Parameter intervals: The ordered interval pattern to validate.
        /// - Returns: `true` when the pattern begins with unison, is strictly ascending,
        ///   and each interval class remains within one octave.
        private static func isValid(_ intervals: [MusicTheoryKit.Pitch.Interval]) -> Bool {
            guard let first = intervals.first, first == .unison else {
                return false
            }

            let upperBound = MusicTheoryKit.Pitch.PitchClass.chromaticCardinality
            var previousValue = -1

            for interval in intervals {
                let value = interval.rawValue

                guard value >= 0, value < upperBound, value > previousValue else {
                    return false
                }

                previousValue = value
            }

            return true
        }

        /// Rotate a collection so the requested index becomes the first element.
        ///
        /// - Parameters:
        ///   - values: The values to rotate.
        ///   - firstIndex: The index that should become the first element.
        /// - Returns: A rotated copy of the collection.
        private func rotate<T>(_ values: [T], soFirstIndexIs firstIndex: Int) -> [T] {
            Array(values[firstIndex...] + values[..<firstIndex])
        }

        /// Normalize an interval value into one octave.
        ///
        /// - Parameter value: The interval value to normalize.
        /// - Returns: A wrapped interval value in the range `0...11`.
        private func normalize(_ value: Int) -> Int {
            let cardinality = MusicTheoryKit.Pitch.PitchClass.chromaticCardinality
            let remainder = value % cardinality
            return remainder >= 0 ? remainder : remainder + cardinality
        }
    }
}

// MARK: - Scale presets

extension MusicTheoryKit.Harmony.Scale {
    /// Create a major scale for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the major scale.
    /// - Returns: A major scale built on the given tonic.
    public static func major(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .majorSixth, .majorSeventh]
        )
    }

    /// Create a natural minor scale for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the natural minor scale.
    /// - Returns: A natural minor scale built on the given tonic.
    public static func naturalMinor(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .minorSeventh]
        )
    }

    /// Create a harmonic minor scale for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the harmonic minor scale.
    /// - Returns: A harmonic minor scale built on the given tonic.
    public static func harmonicMinor(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .majorSeventh]
        )
    }

    /// Create a melodic minor scale for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the melodic minor scale.
    /// - Returns: A melodic minor scale built on the given tonic.
    public static func melodicMinor(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .majorSixth, .majorSeventh]
        )
    }

    /// Create a major pentatonic scale for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the major pentatonic scale.
    /// - Returns: A major pentatonic scale built on the given tonic.
    public static func majorPentatonic(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .majorSecond, .majorThird, .perfectFifth, .majorSixth]
        )
    }

    /// Create a minor pentatonic scale for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the minor pentatonic scale.
    /// - Returns: A minor pentatonic scale built on the given tonic.
    public static func minorPentatonic(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .minorThird, .perfectFourth, .perfectFifth, .minorSeventh]
        )
    }

    /// Create a blues scale for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the blues scale.
    /// - Returns: A blues scale built on the given tonic.
    public static func blues(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .minorThird, .perfectFourth, .tritone, .perfectFifth, .minorSeventh]
        )
    }

    /// Create a Dorian mode for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the Dorian mode.
    /// - Returns: A Dorian mode built on the given tonic.
    public static func dorian(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .majorSixth, .minorSeventh]
        )
    }

    /// Create a Phrygian mode for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the Phrygian mode.
    /// - Returns: A Phrygian mode built on the given tonic.
    public static func phrygian(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .minorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .minorSeventh]
        )
    }

    /// Create a Lydian mode for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the Lydian mode.
    /// - Returns: A Lydian mode built on the given tonic.
    public static func lydian(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .majorSecond, .majorThird, .tritone, .perfectFifth, .majorSixth, .majorSeventh]
        )
    }

    /// Create a Mixolydian mode for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the Mixolydian mode.
    /// - Returns: A Mixolydian mode built on the given tonic.
    public static func mixolydian(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .majorSixth, .minorSeventh]
        )
    }

    /// Create an Aeolian mode for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the Aeolian mode.
    /// - Returns: An Aeolian mode built on the given tonic.
    public static func aeolian(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        naturalMinor(tonic: tonic)
    }

    /// Create a Locrian mode for the given tonic.
    ///
    /// - Parameter tonic: The tonic pitch class of the Locrian mode.
    /// - Returns: A Locrian mode built on the given tonic.
    public static func locrian(tonic: MusicTheoryKit.Pitch.PitchClass) -> Self {
        Self(
            validatedTonic: tonic,
            intervals: [.unison, .minorSecond, .minorThird, .perfectFourth, .tritone, .minorSixth, .minorSeventh]
        )
    }
}

// MARK: - Scale conformances

extension MusicTheoryKit.Harmony.Scale: Hashable, Codable, CustomStringConvertible {
    /// Return a human-readable description of the scale.
    public var description: String {
        let spellings = pitchClasses.map(\.description).joined(separator: ", ")
        return "\(tonic) [\(spellings)]"
    }
}
