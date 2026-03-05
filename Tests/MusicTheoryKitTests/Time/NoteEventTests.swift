// Package: MusicTheoryKit
// File: NoteEventTests.swift
// Path: Tests/MusicTheoryKitTests/Time/NoteEventTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - NoteEvent tests

struct NoteEventTests {
    /// Verify that note events validate onset, duration, and velocity on creation.
    @Test
    func validatesEventInvariants() {
        let pitch = MusicTheoryKit.Pitch.Pitch(pitchClass: .C, octave: 4)

        #expect(MusicTheoryKit.Time.NoteEvent(pitch: pitch, startBeat: -1, duration: 1) == nil)
        #expect(MusicTheoryKit.Time.NoteEvent(pitch: pitch, startBeat: 0, duration: 0) == nil)
        #expect(MusicTheoryKit.Time.NoteEvent(pitch: pitch, startBeat: 0, duration: 1, velocity: -1) == nil)
        #expect(MusicTheoryKit.Time.NoteEvent(pitch: pitch, startBeat: 0, duration: 1, velocity: 128) == nil)
        #expect(MusicTheoryKit.Time.NoteEvent(pitch: pitch, startBeat: 0, duration: 1) != nil)
        #expect(MusicTheoryKit.Time.NoteEvent(pitch: pitch, startBeat: 0, duration: 1, velocity: 96)?.velocity == 96)
    }

    /// Verify that the end beat is derived from onset and duration.
    @Test
    func computesEndBeat() {
        let event = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .E, octave: 4),
            startBeat: 1.5,
            duration: 0.5
        )

        #expect(event?.endBeat == 2.0)
    }

    /// Verify that beat containment uses an inclusive start and exclusive end.
    @Test
    func checksBeatContainment() {
        let event = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .G, octave: 4),
            startBeat: 2,
            duration: 1
        )!

        #expect(event.contains(beat: 2))
        #expect(event.contains(beat: 2.5))
        #expect(event.contains(beat: 3) == false)
    }

    /// Verify that shifting preserves timing metadata and pitch while moving the onset.
    @Test
    func shiftsInTime() {
        let event = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .A, octave: 4),
            startBeat: 3,
            duration: 2,
            velocity: 88
        )!

        let shiftedForward = event.shifted(by: 1.5)
        let shiftedBackwardPastZero = event.shifted(by: -4)

        #expect(shiftedForward?.startBeat == 4.5)
        #expect(shiftedForward?.duration == 2)
        #expect(shiftedForward?.velocity == 88)
        #expect(shiftedBackwardPastZero == nil)
    }

    /// Verify that transposition preserves timing metadata while changing pitch.
    @Test
    func transposesPitch() {
        let event = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .C, octave: 4),
            startBeat: 0,
            duration: 1,
            velocity: 72
        )!

        let transposed = event.transposed(by: .perfectFifth)

        #expect(transposed.pitch == .init(pitchClass: .G, octave: 4))
        #expect(transposed.startBeat == event.startBeat)
        #expect(transposed.duration == event.duration)
        #expect(transposed.velocity == event.velocity)
    }
}
