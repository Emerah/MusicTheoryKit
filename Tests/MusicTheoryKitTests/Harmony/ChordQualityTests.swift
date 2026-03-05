// Package: MusicTheoryKit
// File: ChordQualityTests.swift
// Path: Tests/MusicTheoryKitTests/Harmony/ChordQualityTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - ChordQuality tests

struct ChordQualityTests {
    /// Verify that built-in triad qualities expose the expected interval formulas.
    @Test
    func buildsTriadQualities() {
        #expect(MusicTheoryKit.Harmony.ChordQuality.major.intervals == [.unison, .majorThird, .perfectFifth])
        #expect(MusicTheoryKit.Harmony.ChordQuality.minor.intervals == [.unison, .minorThird, .perfectFifth])
        #expect(MusicTheoryKit.Harmony.ChordQuality.diminished.intervals == [.unison, .minorThird, .tritone])
    }

    /// Verify that built-in seventh qualities expose the expected interval formulas.
    @Test
    func buildsSeventhQualities() {
        #expect(MusicTheoryKit.Harmony.ChordQuality.dominantSeventh.intervals == [.unison, .majorThird, .perfectFifth, .minorSeventh])
        #expect(MusicTheoryKit.Harmony.ChordQuality.majorSeventh.intervals == [.unison, .majorThird, .perfectFifth, .majorSeventh])
        #expect(MusicTheoryKit.Harmony.ChordQuality.halfDiminishedSeventh.intervals == [.unison, .minorThird, .tritone, .minorSeventh])
    }

    /// Verify that built-in extended and altered qualities expose the expected formulas.
    @Test
    func buildsExtendedAndAlteredQualities() {
        #expect(MusicTheoryKit.Harmony.ChordQuality.dominantNinth.intervals == [.unison, .majorThird, .perfectFifth, .minorSeventh, .init(rawValue: 14)])
        #expect(MusicTheoryKit.Harmony.ChordQuality.dominantFlatNinth.intervals == [.unison, .majorThird, .perfectFifth, .minorSeventh, .init(rawValue: 13)])
        #expect(MusicTheoryKit.Harmony.ChordQuality.dominantSharpEleventh.intervals == [.unison, .majorThird, .perfectFifth, .minorSeventh, .init(rawValue: 14), .init(rawValue: 18)])
    }

    /// Verify that malformed interval formulas are rejected.
    @Test
    func rejectsInvalidIntervalFormulas() {
        let missingUnison = MusicTheoryKit.Harmony.ChordQuality(intervals: [.majorThird, .perfectFifth])
        let duplicate = MusicTheoryKit.Harmony.ChordQuality(intervals: [.unison, .majorThird, .majorThird])
        let includesOctave = MusicTheoryKit.Harmony.ChordQuality(intervals: [.unison, .perfectFifth, .octave])
        let duplicatePitchClassAcrossOctave = MusicTheoryKit.Harmony.ChordQuality(intervals: [.unison, .perfectFifth, .init(rawValue: 19)])

        #expect(missingUnison == nil)
        #expect(duplicate == nil)
        #expect(includesOctave == nil)
        #expect(duplicatePitchClassAcrossOctave == nil)
    }

    /// Verify that interval membership and tone count are derived from the formula.
    @Test
    func exposesFormulaQueries() {
        let quality = MusicTheoryKit.Harmony.ChordQuality.dominantSharpEleventh

        #expect(quality.toneCount == 6)
        #expect(quality.contains(.minorSeventh))
        #expect(quality.extensionIntervals == [.init(rawValue: 14), .init(rawValue: 18)])
        #expect(quality.alterationIntervals == [.init(rawValue: 18)])
    }

    /// Verify that extensions and alterations can be added incrementally.
    @Test
    func addsExtensionsAndAlterations() {
        let dominantSeventh = MusicTheoryKit.Harmony.ChordQuality.dominantSeventh
        let extended = dominantSeventh.addingExtension(.init(rawValue: 14))
        let altered = extended?.addingAlteration(.init(rawValue: 18))

        #expect(extended == .dominantNinth)
        #expect(altered == .dominantSharpEleventh)
        #expect(dominantSeventh.addingExtension(.octave) == nil)
        #expect(dominantSeventh.addingAlteration(.majorSecond) == nil)
    }

    /// Verify that descriptions use meaningful names for known qualities.
    @Test
    func describesKnownQualities() {
        #expect(MusicTheoryKit.Harmony.ChordQuality.augmented.description == "Augmented")
        #expect(MusicTheoryKit.Harmony.ChordQuality.dominantSeventh.description == "Dominant Seventh")
        #expect(MusicTheoryKit.Harmony.ChordQuality.dominantFlatNinth.description == "Dominant Flat Ninth")
    }
}
