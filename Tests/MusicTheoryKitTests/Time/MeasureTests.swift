// Package: MusicTheoryKit
// File: MeasureTests.swift
// Path: Tests/MusicTheoryKitTests/Time/MeasureTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - Measure tests

struct MeasureTests {
    /// Verify that measure construction validates measure bounds and numbering.
    @Test
    func validatesMeasureInvariants() {
        let fourFour = MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 4)!
        let validEvent = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .C, octave: 4),
            startBeat: 0,
            duration: 1
        )!
        let overflowingEvent = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .D, octave: 4),
            startBeat: 3.5,
            duration: 1
        )!

        #expect(MusicTheoryKit.Time.Measure(number: 0, timeSignature: fourFour) == nil)
        #expect(MusicTheoryKit.Time.Measure(number: 1, beatCount: 0) == nil)
        #expect(MusicTheoryKit.Time.Measure(number: 1, beatCount: 3.5) == nil)
        #expect(MusicTheoryKit.Time.Measure(number: 1, timeSignature: fourFour, events: [overflowingEvent]) == nil)
        #expect(MusicTheoryKit.Time.Measure(number: 1, timeSignature: fourFour, events: [validEvent]) != nil)
    }

    /// Verify that events are stored in stable onset order.
    @Test
    func sortsEventsByOnset() {
        let fourFour = MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 4)!
        let lateEvent = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .G, octave: 4),
            startBeat: 2,
            duration: 1
        )!
        let earlyEvent = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .C, octave: 4),
            startBeat: 0,
            duration: 1
        )!

        let measure = MusicTheoryKit.Time.Measure(number: 2, timeSignature: fourFour, events: [lateEvent, earlyEvent])

        #expect(measure?.events == [earlyEvent, lateEvent])
        #expect(measure?.endBeat == 4)
    }

    /// Verify that beat queries respect local measure bounds.
    @Test
    func checksBeatContainment() {
        let measure = MusicTheoryKit.Time.Measure(
            number: 3,
            timeSignature: .init(numerator: 3, denominator: 4)!
        )!

        #expect(measure.contains(beat: 0))
        #expect(measure.contains(beat: 2.999))
        #expect(measure.contains(beat: 3) == false)
        #expect(measure.contains(beat: -0.1) == false)
    }

    /// Verify that active events can be queried by local beat.
    @Test
    func findsEventsAtBeat() {
        let fourFour = MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 4)!
        let first = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .E, octave: 4),
            startBeat: 0,
            duration: 2
        )!
        let second = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .G, octave: 4),
            startBeat: 1,
            duration: 1
        )!
        let measure = MusicTheoryKit.Time.Measure(number: 1, timeSignature: fourFour, events: [first, second])!

        #expect(measure.events(at: 0.5) == [first])
        #expect(measure.events(at: 1.5) == [first, second])
        #expect(measure.events(at: 3) == [])
    }

    /// Verify that appending preserves validation and sorted order.
    @Test
    func appendsEventsWithinBounds() {
        let fourFour = MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 4)!
        let first = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .C, octave: 4),
            startBeat: 1,
            duration: 1
        )!
        let second = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .A, octave: 4),
            startBeat: 0,
            duration: 0.5
        )!
        let overflowing = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .B, octave: 4),
            startBeat: 3.5,
            duration: 1
        )!

        let measure = MusicTheoryKit.Time.Measure(number: 4, timeSignature: fourFour, events: [first])!

        #expect(measure.appending(second)?.events == [second, first])
        #expect(measure.appending(overflowing) == nil)
    }

    /// Verify that beat-strength analysis follows the explicit time signature, including compound meter.
    @Test
    func analyzesBeatStrength() {
        let fourFour = MusicTheoryKit.Time.Measure(
            number: 1,
            timeSignature: .init(numerator: 4, denominator: 4)!
        )!
        let threeFour = MusicTheoryKit.Time.Measure(
            number: 2,
            timeSignature: .init(numerator: 3, denominator: 4)!
        )!
        let sixEight = MusicTheoryKit.Time.Measure(
            number: 3,
            timeSignature: .init(numerator: 6, denominator: 8)!
        )!

        #expect(fourFour.strongBeats == [0, 2])
        #expect(fourFour.beatStrength(at: 0) == .strong)
        #expect(fourFour.beatStrength(at: 2) == .medium)
        #expect(fourFour.beatStrength(at: 1) == .weak)
        #expect(fourFour.beatStrength(at: 1.5) == nil)
        #expect(fourFour.isDownbeat(0))
        #expect(fourFour.isDownbeat(2) == false)

        #expect(threeFour.strongBeats == [0])
        #expect(threeFour.beatStrength(at: 1) == .weak)
        #expect(sixEight.strongBeats == [0, 3])
        #expect(sixEight.beatStrength(at: 3) == .medium)
        #expect(MusicTheoryKit.Time.Measure.BeatStrength.medium.description == "Medium")
    }
}
