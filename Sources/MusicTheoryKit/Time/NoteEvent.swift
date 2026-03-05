// Package: MusicTheoryKit
// File: NoteEvent.swift
// Path: Sources/MusicTheoryKit/Time/NoteEvent.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

// MARK: - NoteEvent

extension MusicTheoryKit.Time {
    /// Represent a pitched musical event with a beat-based onset and duration.
    ///
    /// `NoteEvent` models a note inside a timeline measured in beats. Its onset must be non-negative,
    /// its duration must be greater than zero, and its velocity must stay within the MIDI range `0...127`.
    public struct NoteEvent: Sendable {
        /// Store the concrete pitch played by the event.
        public let pitch: MusicTheoryKit.Pitch.Pitch

        /// Store the event onset measured in beats from the start of the containing timeline.
        public let startBeat: Double

        /// Store the event duration measured in beats.
        public let duration: Double

        /// Store the MIDI-style velocity of the event.
        public let velocity: Int

        /// Create a note event from a pitch, onset, duration, and velocity.
        ///
        /// - Parameters:
        ///   - pitch: The concrete pitch played by the event.
        ///   - startBeat: The onset measured in beats from the start of the containing timeline.
        ///   - duration: The duration measured in beats.
        ///   - velocity: The MIDI-style performance intensity in the range `0...127`.
        ///
        /// - Returns: `nil` when `startBeat` is negative, `duration` is not greater than zero, or `velocity` is outside `0...127`.
        public init?(
            pitch: MusicTheoryKit.Pitch.Pitch,
            startBeat: Double,
            duration: Double,
            velocity: Int = 64
        ) {
            guard startBeat >= 0, duration > 0, Self.isValidVelocity(velocity) else {
                return nil
            }

            self.pitch = pitch
            self.startBeat = startBeat
            self.duration = duration
            self.velocity = velocity
        }

        /// Return the beat at which the event ends.
        public var endBeat: Double {
            startBeat + duration
        }

        /// Return whether the event is active at the given beat.
        ///
        /// The start beat is inclusive and the end beat is exclusive.
        ///
        /// - Parameter beat: The beat position to test.
        /// - Returns: `true` when the event spans the given beat.
        public func contains(beat: Double) -> Bool {
            beat >= startBeat && beat < endBeat
        }

        /// Return a copy of the event shifted by the given number of beats.
        ///
        /// - Parameter beats: The signed beat offset to apply.
        /// - Returns: A shifted note event, or `nil` when the new onset would be negative.
        public func shifted(by beats: Double) -> Self? {
            Self(pitch: pitch, startBeat: startBeat + beats, duration: duration, velocity: velocity)
        }

        /// Return a copy of the event transposed by the given interval.
        ///
        /// - Parameter interval: The interval used to transpose the event pitch.
        /// - Returns: A new note event with the same timing and a transposed pitch.
        public func transposed(by interval: MusicTheoryKit.Pitch.Interval) -> Self {
            Self(
                pitch: interval.applied(to: pitch),
                startBeat: startBeat,
                duration: duration,
                velocity: velocity
            )!
        }

        /// Return whether a velocity value is inside the supported MIDI range.
        ///
        /// - Parameter velocity: The velocity value to validate.
        /// - Returns: `true` when `velocity` is in the range `0...127`.
        private static func isValidVelocity(_ velocity: Int) -> Bool {
            (0...127).contains(velocity)
        }
    }
}

// MARK: - NoteEvent conformances

extension MusicTheoryKit.Time.NoteEvent: Codable, Hashable, CustomStringConvertible {
    /// Return a human-readable description of the note event.
    public var description: String {
        "\(pitch) @ \(startBeat) for \(duration) velocity \(velocity)"
    }
}
