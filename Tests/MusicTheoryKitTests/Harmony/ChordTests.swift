// Package: MusicTheoryKit
// File: ChordTests.swift
// Path: Tests/MusicTheoryKitTests/Harmony/ChordTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - Chord tests

struct ChordTests {
    /// Verify that a chord derives its pitch classes from its root and quality.
    @Test
    func derivesPitchClassesFromQuality() {
        let chord = MusicTheoryKit.Harmony.Chord(root: .C, quality: .major)

        #expect(chord.intervals == [.unison, .majorThird, .perfectFifth])
        #expect(chord.pitchClasses == [.C, .E, .G])
        #expect(chord.toneCount == 3)
    }

    /// Verify that built-in constructors choose the expected chord qualities.
    @Test
    func buildsPresetChords() {
        let minor = MusicTheoryKit.Harmony.Chord.minor(root: .A)
        let dominantSeventh = MusicTheoryKit.Harmony.Chord.dominantSeventh(root: .G)
        let majorSeventh = MusicTheoryKit.Harmony.Chord.majorSeventh(root: .F)

        #expect(minor.quality == .minor)
        #expect(minor.pitchClasses == [.A, .C, .E])
        #expect(dominantSeventh.pitchClasses == [.G, .B, .D, .F])
        #expect(majorSeventh.pitchClasses == [.F, .A, .C, .E])
    }

    /// Verify that membership queries are derived from the resolved chord tones.
    @Test
    func checksMembership() {
        let chord = MusicTheoryKit.Harmony.Chord.minorSeventh(root: .D)

        #expect(chord.contains(.F))
        #expect(chord.contains(.C))
        #expect(chord.contains(.FSharp) == false)
    }

    /// Verify that transposition preserves quality while changing the root.
    @Test
    func transposesToNewRoot() {
        let original = MusicTheoryKit.Harmony.Chord.major(root: .C)
        let transposed = original.transposed(to: .E)

        #expect(transposed.root == .E)
        #expect(transposed.quality == .major)
        #expect(transposed.pitchClasses == [.E, .GSharp, .B])
    }

    /// Verify that chords expose bass-aware inversion analysis.
    @Test
    func analyzesInversionsAndSlashBass() {
        let firstInversion = MusicTheoryKit.Harmony.Chord(root: .C, quality: .major, bass: .E)
        let slashChord = MusicTheoryKit.Harmony.Chord(root: .C, quality: .major, bass: .D)

        #expect(firstInversion.bassPitchClass == .E)
        #expect(firstInversion.inversion == .first)
        #expect(firstInversion.isInverted)
        #expect(slashChord.inversion == .slash)
        #expect(slashChord.isInverted == false)
    }

    /// Verify that transposition preserves slash structure relative to the root.
    @Test
    func preservesBassWhenTransposed() {
        let original = MusicTheoryKit.Harmony.Chord(root: .C, quality: .major, bass: .E)
        let transposed = original.transposed(to: .D)

        #expect(transposed.root == .D)
        #expect(transposed.bass == .FSharp)
        #expect(transposed.description == "D Major/F#")
    }

    /// Verify that descriptions expose readable root and quality names.
    @Test
    func describesChord() {
        let chord = MusicTheoryKit.Harmony.Chord(root: .B, quality: .halfDiminishedSeventh)
        let slashChord = MusicTheoryKit.Harmony.Chord(root: .C, quality: .major, bass: .E)

        #expect(chord.description == "B Half-Diminished Seventh")
        #expect(slashChord.description == "C Major/E")
    }

    /// Verify that chords resolve compound extensions and altered tones through the quality formula.
    @Test
    func resolvesExtendedAndAlteredChordTones() {
        let ninthChord = MusicTheoryKit.Harmony.Chord(root: .C, quality: .dominantNinth)
        let alteredChord = MusicTheoryKit.Harmony.Chord(root: .G, quality: .dominantSharpEleventh)

        #expect(ninthChord.pitchClasses == [.C, .E, .G, .ASharp, .D])
        #expect(alteredChord.pitchClasses == [.G, .B, .D, .F, .A, .CSharp])
    }

    /// Verify that chords can be spelled from explicit root and bass note names.
    @Test
    func spellsChordNoteNames() {
        let bFlatMinorSeventh = MusicTheoryKit.Harmony.Chord(root: .ASharp, quality: .minorSeventh)
        let gSharpSharpEleventh = MusicTheoryKit.Harmony.Chord(root: .GSharp, quality: .dominantSharpEleventh)
        let slashChord = MusicTheoryKit.Harmony.Chord(root: .C, quality: .major, bass: .E)
        let sharpEleventh = MusicTheoryKit.Harmony.Chord(root: .G, quality: .dominantSharpEleventh)

        #expect(bFlatMinorSeventh.noteNames(root: .BFlat) == [.BFlat, .DFlat, .F, .AFlat])
        #expect(sharpEleventh.noteNames(root: .G) == [.G, .B, .D, .F, .A, .CSharp])
        #expect(slashChord.noteNames(root: .C, bassNoteName: .E) == [.C, .E, .G, .E])
        #expect(gSharpSharpEleventh.noteNames(root: .GSharp) == nil)
    }
}
