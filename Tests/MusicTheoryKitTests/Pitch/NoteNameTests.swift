// Package: MusicTheoryKit
// File: NoteNameTests.swift
// Path: Tests/MusicTheoryKitTests/Pitch/NoteNameTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - NoteName tests

struct NoteNameTests {
    /// Verify that note names preserve spelling while mapping to pitch classes.
    @Test
    func mapsToPitchClasses() {
        #expect(MusicTheoryKit.Pitch.NoteName.CSharp.pitchClass == .CSharp)
        #expect(MusicTheoryKit.Pitch.NoteName.DFlat.pitchClass == .CSharp)
        #expect(MusicTheoryKit.Pitch.NoteName.CFlat.pitchClass == .B)
        #expect(MusicTheoryKit.Pitch.NoteName.BSharp.pitchClass == .C)
    }

    /// Verify that note names can be derived from pitch classes with a spelling preference.
    @Test
    func spellsPitchClassesByPreference() {
        let sharp = MusicTheoryKit.Pitch.NoteName(pitchClass: .CSharp, preferSharps: true)
        let flat = MusicTheoryKit.Pitch.NoteName(pitchClass: .CSharp, preferSharps: false)

        #expect(sharp == .CSharp)
        #expect(flat == .DFlat)
        #expect(sharp.description == "C#")
        #expect(flat.description == "Db")
    }

    /// Verify that note names expose circle-of-fifths positions for key spelling.
    @Test
    func exposesCircleOfFifthsIndex() {
        #expect(MusicTheoryKit.Pitch.NoteName.C.circleOfFifthsIndex == 0)
        #expect(MusicTheoryKit.Pitch.NoteName.FSharp.circleOfFifthsIndex == 6)
        #expect(MusicTheoryKit.Pitch.NoteName.DFlat.circleOfFifthsIndex == -5)
    }

    /// Verify that diatonic letter advancement wraps safely for negative and positive steps.
    @Test
    func advancesLettersWithWrapping() {
        #expect(MusicTheoryKit.Pitch.NoteName.Letter.C.advanced(by: -1) == .B)
        #expect(MusicTheoryKit.Pitch.NoteName.Letter.C.advanced(by: -8) == .B)
        #expect(MusicTheoryKit.Pitch.NoteName.Letter.F.advanced(by: 9) == .A)
    }
}
