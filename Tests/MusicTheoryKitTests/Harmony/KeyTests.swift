// Package: MusicTheoryKit
// File: KeyTests.swift
// Path: Tests/MusicTheoryKitTests/Harmony/KeyTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - Key tests

struct KeyTests {
    /// Verify that a key derives its scale from the tonic and kind.
    @Test
    func derivesScaleFromScaleKind() {
        let key = MusicTheoryKit.Harmony.Key(tonic: .C, scaleKind: .major)

        #expect(key.scale.pitchClasses == [.C, .D, .E, .F, .G, .A, .B])
        #expect(key.pitchClasses == key.scale.pitchClasses)
    }

    /// Verify that canonical constructors pick the expected key kinds.
    @Test
    func buildsPresetKeys() {
        let major = MusicTheoryKit.Harmony.Key.major(tonic: .G)
        let minor = MusicTheoryKit.Harmony.Key.naturalMinor(tonic: .E)
        let harmonicMinor = MusicTheoryKit.Harmony.Key.harmonicMinor(tonic: .A)

        #expect(major.scaleKind == .major)
        #expect(minor.scaleKind == .naturalMinor)
        #expect(harmonicMinor.pitchClasses == [.A, .B, .C, .D, .E, .F, .GSharp])
    }

    /// Verify that membership queries delegate to the derived scale.
    @Test
    func checksMembership() {
        let key = MusicTheoryKit.Harmony.Key(tonic: .D, scaleKind: .mixolydian)

        #expect(key.contains(.C))
        #expect(key.contains(.CSharp) == false)
    }

    /// Verify that transposition preserves key kind while changing tonic.
    @Test
    func transposesToNewTonic() {
        let original = MusicTheoryKit.Harmony.Key(tonic: .C, scaleKind: .dorian)
        let transposed = original.transposed(to: .F)

        #expect(transposed.tonic == .F)
        #expect(transposed.scaleKind == .dorian)
        #expect(transposed.pitchClasses == [.F, .G, .GSharp, .ASharp, .C, .D, .DSharp])
    }

    /// Verify that descriptions expose readable tonic and key-kind names.
    @Test
    func describesKeyAndScaleKind() {
        let key = MusicTheoryKit.Harmony.Key(tonic: .E, scaleKind: .melodicMinor)

        #expect(MusicTheoryKit.Harmony.Key.ScaleKind.locrian.description == "Locrian")
        #expect(key.description == "E Melodic Minor")
    }

    /// Verify that keys expose relative major relationships across diatonic scale families.
    @Test
    func derivesRelativeMajor() {
        let minor = MusicTheoryKit.Harmony.Key.naturalMinor(tonic: .A)
        let dorian = MusicTheoryKit.Harmony.Key(tonic: .D, scaleKind: .dorian)

        #expect(minor.relativeMajor == .major(tonic: .C))
        #expect(dorian.relativeMajor == .major(tonic: .C))
    }

    /// Verify that major and minor keys expose their relative and parallel counterparts.
    @Test
    func derivesRelativeAndParallelMinorRelationships() {
        let cMajor = MusicTheoryKit.Harmony.Key.major(tonic: .C)
        let cMinor = MusicTheoryKit.Harmony.Key.naturalMinor(tonic: .C)

        #expect(cMajor.relativeNaturalMinor == .naturalMinor(tonic: .A))
        #expect(cMinor.relativeNaturalMinor == .naturalMinor(tonic: .C))
        #expect(cMajor.parallelNaturalMinor == .naturalMinor(tonic: .C))
        #expect(cMinor.parallelMajor == .major(tonic: .C))
    }

    /// Verify that relative-key derivation preserves tonic spelling and key-signature metadata.
    @Test
    func preservesSpellingInRelativeRelationships() {
        let dFlatMajor = MusicTheoryKit.Harmony.Key(noteName: .DFlat, scaleKind: .major)
        let bFlatMinor = MusicTheoryKit.Harmony.Key(noteName: .BFlat, scaleKind: .naturalMinor)

        #expect(dFlatMajor.relativeNaturalMinor?.tonicNoteName == .BFlat)
        #expect(dFlatMajor.relativeNaturalMinor?.keySignature?.accidentalType == .flats)
        #expect(dFlatMajor.relativeNaturalMinor?.keySignature?.accidentalCount == 5)
        #expect(bFlatMinor.relativeMajor?.tonicNoteName == .DFlat)
        #expect(bFlatMinor.relativeMajor?.keySignature?.accidentalType == .flats)
        #expect(bFlatMinor.relativeMajor?.keySignature?.accidentalCount == 5)
    }

    /// Verify that modal keys do not pretend to have parallel major/minor mappings.
    @Test
    func limitsParallelRelationshipsToMajorMinorFamilies() {
        let lydian = MusicTheoryKit.Harmony.Key(tonic: .F, scaleKind: .lydian)

        #expect(lydian.parallelMajor == nil)
        #expect(lydian.parallelNaturalMinor == nil)
    }

    /// Verify that keys preserve spelled tonic names when initialized from note names.
    @Test
    func preservesSpelledTonics() {
        let dFlatMajor = MusicTheoryKit.Harmony.Key(noteName: .DFlat, scaleKind: .major)
        let cSharpMajor = MusicTheoryKit.Harmony.Key(noteName: .CSharp, scaleKind: .major)

        #expect(dFlatMajor.tonic == .CSharp)
        #expect(dFlatMajor.tonicNoteName == .DFlat)
        #expect(dFlatMajor.description == "Db Major")
        #expect(cSharpMajor.description == "C# Major")
    }

    /// Verify that key signatures distinguish enharmonic spellings and expose affected letters.
    @Test
    func exposesKeySignatureMetadata() {
        let cMajor = MusicTheoryKit.Harmony.Key.major(tonic: .C)
        let cSharpMajor = MusicTheoryKit.Harmony.Key(noteName: .CSharp, scaleKind: .major)
        let dFlatMajor = MusicTheoryKit.Harmony.Key(noteName: .DFlat, scaleKind: .major)
        let eFlatDorian = MusicTheoryKit.Harmony.Key(noteName: .EFlat, scaleKind: .dorian)

        #expect(cMajor.keySignature?.accidentalCount == 0)
        #expect(cMajor.keySignature?.accidentalType == nil)
        #expect(cSharpMajor.keySignature?.accidentalCount == 7)
        #expect(cSharpMajor.keySignature?.accidentalType == .sharps)
        #expect(
            cSharpMajor.keySignature?.alteredLetters == [
                MusicTheoryKit.Pitch.NoteName.Letter.F,
                .C,
                .G,
                .D,
                .A,
                .E,
                .B,
            ]
        )
        #expect(dFlatMajor.keySignature?.accidentalCount == 5)
        #expect(dFlatMajor.keySignature?.accidentalType == .flats)
        #expect(
            dFlatMajor.keySignature?.alteredLetters == [
                MusicTheoryKit.Pitch.NoteName.Letter.B,
                .E,
                .A,
                .D,
                .G,
            ]
        )
        #expect(eFlatDorian.keySignature?.accidentalCount == 5)
        #expect(eFlatDorian.keySignature?.accidentalType == .flats)
    }

    /// Verify that theoretical keys beyond seven accidentals do not pretend to have conventional signatures.
    @Test
    func limitsKeySignatureMetadataToConventionalSignatures() {
        let gSharpMajor = MusicTheoryKit.Harmony.Key(noteName: .GSharp, scaleKind: .major)

        #expect(gSharpMajor.keySignature == nil)
    }
}
