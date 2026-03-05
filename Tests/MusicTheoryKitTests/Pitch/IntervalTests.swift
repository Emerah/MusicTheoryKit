// Package: MusicTheoryKit
// File: IntervalTests.swift
// Path: Tests/MusicTheoryKitTests/Pitch/IntervalTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - Interval tests

struct IntervalTests {
    /// Verify that pitch-class intervals are measured as ascending wrapped distances.
    @Test
    func initializesFromPitchClasses() {
        let interval = MusicTheoryKit.Pitch.Interval(from: .B, to: .D)

        #expect(interval == .minorThird)
        #expect(interval.rawValue == 3)
    }

    /// Verify that pitch intervals preserve signed absolute semitone distance.
    @Test
    func initializesFromPitches() {
        let lower = MusicTheoryKit.Pitch.Pitch(pitchClass: .C, octave: 4)
        let upper = MusicTheoryKit.Pitch.Pitch(pitchClass: .G, octave: 5)
        let interval = MusicTheoryKit.Pitch.Interval(from: lower, to: upper)

        #expect(interval.rawValue == 19)
    }

    /// Verify that intervals transpose pitch classes and pitches through their existing APIs.
    @Test
    func appliesToPitchClassesAndPitches() {
        let pitchClass = MusicTheoryKit.Pitch.Interval.majorThird.applied(to: .C)
        let pitch = MusicTheoryKit.Pitch.Interval.perfectFifth.applied(
            to: .init(pitchClass: .D, octave: 4)
        )

        #expect(pitchClass == .E)
        #expect(pitch == .init(pitchClass: .A, octave: 4))
    }

    /// Verify that interval inversion returns the complementary interval class within an octave.
    @Test
    func invertsIntervalClasses() {
        #expect(MusicTheoryKit.Pitch.Interval.majorThird.inverted == .minorSixth)
        #expect(MusicTheoryKit.Pitch.Interval.perfectFourth.inverted == .perfectFifth)
        #expect(MusicTheoryKit.Pitch.Interval.octave.inverted == .unison)
    }

    /// Verify that interval arithmetic combines semitone counts directly.
    @Test
    func combinesIntervals() {
        let combined = MusicTheoryKit.Pitch.Interval.minorThird + .perfectFifth
        let difference = MusicTheoryKit.Pitch.Interval.octave - .majorThird

        #expect(combined == .minorSeventh)
        #expect(difference == .minorSixth)
        #expect(MusicTheoryKit.Pitch.Interval.tritone.description == "Tritone")
    }

    /// Verify that interval decomposition exposes simple-form and octave information.
    @Test
    func decomposesCompoundIntervals() {
        let interval = MusicTheoryKit.Pitch.Interval(rawValue: 19)

        #expect(interval.magnitude == 19)
        #expect(interval.simpleInterval == .perfectFifth)
        #expect(interval.octaveSpan == 1)
        #expect(interval.isCompound)
    }

    /// Verify that interval descriptions cover compound and descending forms.
    @Test
    func describesCompoundAndDescendingIntervals() {
        #expect(MusicTheoryKit.Pitch.Interval(rawValue: 14).description == "Major Ninth")
        #expect(MusicTheoryKit.Pitch.Interval(rawValue: 19).description == "Perfect Twelfth")
        #expect(MusicTheoryKit.Pitch.Interval(rawValue: -3).description == "Descending Minor Third")
        #expect(MusicTheoryKit.Pitch.Interval(rawValue: 24).description == "Double Octave")
    }
}
