// Package: MusicTheoryKit
// File: TimeSignatureTests.swift
// Path: Tests/MusicTheoryKitTests/Time/TimeSignatureTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - TimeSignature tests

struct TimeSignatureTests {
    /// Verify that time signatures require a positive numerator and a power-of-two denominator.
    @Test
    func validatesMeterComponents() {
        #expect(MusicTheoryKit.Time.TimeSignature(numerator: 0, denominator: 4) == nil)
        #expect(MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 0) == nil)
        #expect(MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 3) == nil)
        #expect(MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 4) != nil)
    }

    /// Verify that common and compound meters expose their expected accented beats.
    @Test
    func derivesAccentedBeats() {
        let fourFour = MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 4)!
        let sixEight = MusicTheoryKit.Time.TimeSignature(numerator: 6, denominator: 8)!
        let threeFour = MusicTheoryKit.Time.TimeSignature(numerator: 3, denominator: 4)!

        #expect(fourFour.beatCount == 4)
        #expect(fourFour.accentedBeats == [0, 2])
        #expect(sixEight.isCompound)
        #expect(sixEight.accentedBeats == [0, 3])
        #expect(threeFour.accentedBeats == [0])
    }

    /// Verify that beat-strength analysis is derived from the time signature.
    @Test
    func analyzesBeatStrength() {
        let nineEight = MusicTheoryKit.Time.TimeSignature(numerator: 9, denominator: 8)!

        #expect(nineEight.beatStrength(at: 0) == .strong)
        #expect(nineEight.beatStrength(at: 3) == .medium)
        #expect(nineEight.beatStrength(at: 6) == .medium)
        #expect(nineEight.beatStrength(at: 1) == .weak)
        #expect(nineEight.beatStrength(at: 1.5) == nil)
        #expect(nineEight.description == "9/8")
    }
}
