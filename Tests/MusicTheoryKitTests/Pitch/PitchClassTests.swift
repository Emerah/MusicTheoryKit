// Package: MusicTheoryKit
// File: PitchClassTests.swift
// Path: Tests/MusicTheoryKitTests/Pitch/PitchClassTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - PitchClass tests

struct PitchClassTests {
    /// Verify that initialization wraps arbitrary semitone values into the chromatic range.
    @Test
    func normalizesRawValues() {
        #expect(MusicTheoryKit.Pitch.PitchClass(rawValue: -1).rawValue == 11)
        #expect(MusicTheoryKit.Pitch.PitchClass(rawValue: 12).rawValue == 0)
        #expect(MusicTheoryKit.Pitch.PitchClass(rawValue: 25).rawValue == 1)
    }

    /// Verify that the chromatic collection exposes each pitch class in order.
    @Test
    func exposesAllCasesInChromaticOrder() {
        #expect(MusicTheoryKit.Pitch.PitchClass.allCases.count == 12)
        #expect(MusicTheoryKit.Pitch.PitchClass.allCases.first == .C)
        #expect(MusicTheoryKit.Pitch.PitchClass.allCases.last == .B)
    }

    /// Verify that transposition wraps correctly across octave boundaries.
    @Test
    func transposesBySemitones() {
        #expect(MusicTheoryKit.Pitch.PitchClass.C.transposed(by: 7) == .G)
        #expect(MusicTheoryKit.Pitch.PitchClass.B.transposed(by: 1) == .C)
        #expect((MusicTheoryKit.Pitch.PitchClass.D + (-3)) == .B)
    }

    /// Verify that ascending chromatic distance is normalized into one octave.
    @Test
    func measuresAscendingDistance() {
        #expect(MusicTheoryKit.Pitch.PitchClass.C.distance(to: .G) == 7)
        #expect(MusicTheoryKit.Pitch.PitchClass.B.distance(to: .C) == 1)
        #expect((MusicTheoryKit.Pitch.PitchClass.C - .G) == 5)
    }

    /// Verify that pitch classes expose both sharp and flat enharmonic spellings.
    @Test
    func exposesEnharmonicSpellings() {
        #expect(MusicTheoryKit.Pitch.PitchClass.CSharp.sharpSpelling == "C#")
        #expect(MusicTheoryKit.Pitch.PitchClass.CSharp.flatSpelling == "Db")
        #expect(MusicTheoryKit.Pitch.PitchClass.ASharp.spelling(preferSharps: false) == "Bb")
        #expect(MusicTheoryKit.Pitch.PitchClass.F.spelling(preferSharps: true) == "F")
    }
}
