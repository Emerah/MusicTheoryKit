// Package: MusicTheoryKit
// File: PitchTests.swift
// Path: Tests/MusicTheoryKitTests/Pitch/PitchTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - Pitch tests

struct PitchTests {
    /// Verify that equal-tempered frequencies are derived from the pitch and tuning reference.
    @Test
    func computesFrequency() {
        let a4 = MusicTheoryKit.Pitch.Pitch(pitchClass: .A, octave: 4)
        let c4 = MusicTheoryKit.Pitch.Pitch(pitchClass: .C, octave: 4)

        #expect(abs(a4.frequency() - 440) < 0.0001)
        #expect(abs(c4.frequency() - 261.625565) < 0.001)
    }

    /// Verify that a pitch stores its pitch class and octave verbatim.
    @Test
    func initializesFromPitchClassAndOctave() {
        let pitch = MusicTheoryKit.Pitch.Pitch(pitchClass: .C, octave: 4)

        #expect(pitch.pitchClass == .C)
        #expect(pitch.octave == 4)
        #expect(pitch.chromaticIndex == 48)
    }

    /// Verify that an absolute chromatic index resolves into pitch class and octave.
    @Test
    func initializesFromChromaticIndex() {
        let middleC = MusicTheoryKit.Pitch.Pitch(chromaticIndex: 48)
        let lowB = MusicTheoryKit.Pitch.Pitch(chromaticIndex: -1)

        #expect(middleC.pitchClass == .C)
        #expect(middleC.octave == 4)
        #expect(lowB.pitchClass == .B)
        #expect(lowB.octave == -1)
    }

    /// Verify that pitch transposition preserves the absolute chromatic distance.
    @Test
    func transposesAcrossOctaves() {
        let source = MusicTheoryKit.Pitch.Pitch(pitchClass: .B, octave: 3)

        #expect(source.transposed(by: 1) == .init(pitchClass: .C, octave: 4))
        #expect((source + 2) == .init(pitchClass: .CSharp, octave: 4))
        #expect(source.transposed(by: -12) == .init(pitchClass: .B, octave: 2))
    }

    /// Verify that pitch distance is signed and based on absolute chromatic position.
    @Test
    func measuresSignedDistance() {
        let lowC = MusicTheoryKit.Pitch.Pitch(pitchClass: .C, octave: 4)
        let highG = MusicTheoryKit.Pitch.Pitch(pitchClass: .G, octave: 4)

        #expect(lowC.distance(to: highG) == 7)
        #expect(highG.distance(to: lowC) == -7)
        #expect((highG - lowC) == 7)
    }

    /// Verify that ordering follows absolute chromatic position.
    @Test
    func comparesByChromaticIndex() {
        let lower = MusicTheoryKit.Pitch.Pitch(pitchClass: .ASharp, octave: 3)
        let higher = MusicTheoryKit.Pitch.Pitch(pitchClass: .C, octave: 4)

        #expect(lower < higher)
        #expect(lower.description == "A#3")
        #expect(higher.description == "C4")
    }

    /// Verify that MIDI note numbers resolve into the expected pitches.
    @Test
    func initializesFromMIDINoteNumber() {
        let middleC = MusicTheoryKit.Pitch.Pitch(midiNoteNumber: 60)
        let lowestMIDI = MusicTheoryKit.Pitch.Pitch(midiNoteNumber: 0)

        #expect(middleC == .init(pitchClass: .C, octave: 4))
        #expect(lowestMIDI == .init(pitchClass: .C, octave: -1))
        #expect(MusicTheoryKit.Pitch.Pitch(midiNoteNumber: -1) == nil)
        #expect(MusicTheoryKit.Pitch.Pitch(midiNoteNumber: 128) == nil)
    }

    /// Verify that pitches expose MIDI note numbers when they fall inside the standard range.
    @Test
    func exposesMIDINoteNumber() {
        let middleC = MusicTheoryKit.Pitch.Pitch(pitchClass: .C, octave: 4)
        let highestMIDI = MusicTheoryKit.Pitch.Pitch(pitchClass: .G, octave: 9)
        let belowMIDIRange = MusicTheoryKit.Pitch.Pitch(pitchClass: .B, octave: -2)

        #expect(middleC.midiNoteNumber == 60)
        #expect(highestMIDI.midiNoteNumber == 127)
        #expect(belowMIDIRange.midiNoteNumber == nil)
    }

    /// Verify that frequencies resolve to the nearest equal-tempered pitch.
    @Test
    func initializesFromFrequency() {
        let exactA4 = MusicTheoryKit.Pitch.Pitch.fromFrequency(440)
        let nearC5 = MusicTheoryKit.Pitch.Pitch.fromFrequency(520)

        #expect(exactA4 == .init(pitchClass: .A, octave: 4))
        #expect(nearC5 == .init(pitchClass: .C, octave: 5))
        #expect(MusicTheoryKit.Pitch.Pitch.fromFrequency(0) == nil)
        #expect(MusicTheoryKit.Pitch.Pitch.fromFrequency(-10) == nil)
    }
}
