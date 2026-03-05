// Package: MusicTheoryKit
// File: ScaleTests.swift
// Path: Tests/MusicTheoryKitTests/Harmony/ScaleTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - Scale tests

struct ScaleTests {
    /// Verify that a major scale resolves the expected pitch classes from its tonic.
    @Test
    func buildsMajorScalePitchClasses() {
        let scale = MusicTheoryKit.Harmony.Scale.major(tonic: .C)

        #expect(scale.degreeCount == 7)
        #expect(scale.pitchClasses == [.C, .D, .E, .F, .G, .A, .B])
    }

    /// Verify that a natural minor scale uses the expected interval pattern.
    @Test
    func buildsNaturalMinorScale() {
        let scale = MusicTheoryKit.Harmony.Scale.naturalMinor(tonic: .A)

        #expect(scale.intervals == [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .minorSeventh])
        #expect(scale.pitchClasses == [.A, .B, .C, .D, .E, .F, .G])
    }

    /// Verify that malformed interval patterns are rejected.
    @Test
    func rejectsInvalidIntervalPatterns() {
        let missingUnison = MusicTheoryKit.Harmony.Scale(tonic: .C, intervals: [.majorSecond, .majorThird])
        let duplicate = MusicTheoryKit.Harmony.Scale(tonic: .C, intervals: [.unison, .majorSecond, .majorSecond])
        let includesOctave = MusicTheoryKit.Harmony.Scale(tonic: .C, intervals: [.unison, .octave])

        #expect(missingUnison == nil)
        #expect(duplicate == nil)
        #expect(includesOctave == nil)
    }

    /// Verify that scale membership is derived from the resolved pitch classes.
    @Test
    func checksMembership() {
        let scale = MusicTheoryKit.Harmony.Scale.major(tonic: .D)

        #expect(scale.contains(.FSharp))
        #expect(scale.contains(.CSharp))
        #expect(scale.contains(.F) == false)
    }

    /// Verify that scales expose degree-aware interval and pitch-class lookup.
    @Test
    func resolvesDegreesToIntervalsAndPitchClasses() {
        let scale = MusicTheoryKit.Harmony.Scale.major(tonic: .C)

        #expect(scale.degrees == [.I, .II, .III, .IV, .V, .VI, .VII])
        #expect(scale.interval(at: .III) == .majorThird)
        #expect(scale.pitchClass(at: .VI) == .A)
        #expect(scale.contains(.VII))
        #expect(scale.contains(.init(rawValue: 8)!) == false)
    }

    /// Verify that degree mappings reflect the ordered pitch classes of the scale.
    @Test
    func exposesDegreePitchClassPairs() {
        let scale = MusicTheoryKit.Harmony.Scale.majorPentatonic(tonic: .G)

        #expect(scale.degreePitchClasses.map(\.degree) == [.I, .II, .III, .IV, .V])
        #expect(scale.degreePitchClasses.map(\.pitchClass) == [.G, .A, .B, .D, .E])
    }

    /// Verify that modes can be derived by rotating the scale around a new tonic degree.
    @Test
    func derivesModesFromDegrees() {
        let major = MusicTheoryKit.Harmony.Scale.major(tonic: .C)
        let dorian = major.mode(startingOn: .II)
        let phrygian = major.mode(startingOn: .III)

        #expect(dorian?.tonic == .D)
        #expect(dorian?.intervals == [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .majorSixth, .minorSeventh])
        #expect(phrygian?.pitchClasses == [.E, .F, .G, .A, .B, .C, .D])
    }

    /// Verify that a scale exposes all of its derived modes in degree order.
    @Test
    func exposesAllModes() {
        let scale = MusicTheoryKit.Harmony.Scale.majorPentatonic(tonic: .C)

        #expect(scale.modes.count == 5)
        #expect(scale.modes.first?.tonic == .C)
        #expect(scale.modes.last?.tonic == .A)
        #expect(scale.modes.last?.pitchClasses == [.A, .C, .D, .E, .G])
    }

    /// Verify that scales expose their chromatic step pattern including the closing octave step.
    @Test
    func exposesStepPatterns() {
        let major = MusicTheoryKit.Harmony.Scale.major(tonic: .C)
        let naturalMinor = MusicTheoryKit.Harmony.Scale.naturalMinor(tonic: .A)

        #expect(major.stepPattern == [2, 2, 1, 2, 2, 2, 1])
        #expect(naturalMinor.stepPattern == [2, 1, 2, 2, 1, 2, 2])
    }

    /// Verify that pattern comparison can distinguish identical scales from modal variants.
    @Test
    func comparesPatternsAndModes() {
        let cMajor = MusicTheoryKit.Harmony.Scale.major(tonic: .C)
        let gMajor = MusicTheoryKit.Harmony.Scale.major(tonic: .G)
        let dDorian = MusicTheoryKit.Harmony.Scale.dorian(tonic: .D)

        #expect(cMajor.hasSamePattern(as: gMajor))
        #expect(cMajor.hasSamePattern(as: dDorian) == false)
        #expect(dDorian.isMode(of: cMajor))
        #expect(cMajor.isMode(of: dDorian))
    }

    /// Verify that step-pattern differences expose where two scale formulas diverge.
    @Test
    func computesStepPatternDifference() {
        let naturalMinor = MusicTheoryKit.Harmony.Scale.naturalMinor(tonic: .A)
        let harmonicMinor = MusicTheoryKit.Harmony.Scale.harmonicMinor(tonic: .A)
        let difference = harmonicMinor.stepPatternDifference(from: naturalMinor)

        #expect(difference == [0, 0, 0, 0, 0, 1, -1])
        #expect(MusicTheoryKit.Harmony.Scale.majorPentatonic(tonic: .C).stepPatternDifference(from: naturalMinor) == nil)
    }

    /// Verify that transposition preserves the interval pattern while changing the tonic.
    @Test
    func transposesToNewTonic() {
        let original = MusicTheoryKit.Harmony.Scale.major(tonic: .C)
        let transposed = original.transposed(to: .E)

        #expect(transposed.tonic == .E)
        #expect(transposed.intervals == original.intervals)
        #expect(transposed.pitchClasses == [.E, .FSharp, .GSharp, .A, .B, .CSharp, .DSharp])
    }

    /// Verify that added preset scales resolve the expected pitch-class collections.
    @Test
    func buildsAdditionalScalePresets() {
        let harmonicMinor = MusicTheoryKit.Harmony.Scale.harmonicMinor(tonic: .A)
        let majorPentatonic = MusicTheoryKit.Harmony.Scale.majorPentatonic(tonic: .C)
        let lydian = MusicTheoryKit.Harmony.Scale.lydian(tonic: .F)

        #expect(harmonicMinor.pitchClasses == [.A, .B, .C, .D, .E, .F, .GSharp])
        #expect(majorPentatonic.pitchClasses == [.C, .D, .E, .G, .A])
        #expect(lydian.pitchClasses == [.F, .G, .A, .B, .C, .D, .E])
    }

    /// Verify that alias and modal presets preserve the expected interval structures.
    @Test
    func buildsModalAndAliasPresets() {
        let aeolian = MusicTheoryKit.Harmony.Scale.aeolian(tonic: .E)
        let naturalMinor = MusicTheoryKit.Harmony.Scale.naturalMinor(tonic: .E)
        let locrian = MusicTheoryKit.Harmony.Scale.locrian(tonic: .B)

        #expect(aeolian.intervals == naturalMinor.intervals)
        #expect(locrian.pitchClasses == [.B, .C, .D, .E, .F, .G, .A])
    }

    /// Verify that scales can be spelled from a tonic note name.
    @Test
    func spellsScaleNoteNames() {
        let dFlatMajor = MusicTheoryKit.Harmony.Scale.major(tonic: .CSharp)
        let aHarmonicMinor = MusicTheoryKit.Harmony.Scale.harmonicMinor(tonic: .A)
        let gSharpMajor = MusicTheoryKit.Harmony.Scale.major(tonic: .GSharp)

        #expect(dFlatMajor.noteNames(tonicNoteName: .DFlat) == [.DFlat, .EFlat, .F, .GFlat, .AFlat, .BFlat, .C])
        #expect(aHarmonicMinor.noteNames(tonicNoteName: .A) == [.A, .B, .C, .D, .E, .F, .GSharp])
        #expect(gSharpMajor.noteNames(tonicNoteName: .GSharp) == nil)
    }
}
