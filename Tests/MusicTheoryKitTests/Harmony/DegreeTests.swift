// Package: MusicTheoryKit
// File: DegreeTests.swift
// Path: Tests/MusicTheoryKitTests/Harmony/DegreeTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - Degree tests

struct DegreeTests {
    /// Verify that degree initialization accepts only one-based values.
    @Test
    func validatesRawValues() {
        #expect(MusicTheoryKit.Harmony.Degree(rawValue: 0) == nil)
        #expect(MusicTheoryKit.Harmony.Degree(rawValue: -1) == nil)
        #expect(MusicTheoryKit.Harmony.Degree(rawValue: 1) == .I)
        #expect(MusicTheoryKit.Harmony.Degree(rawValue: 7) == .VII)
    }

    /// Verify that conventional degree constants are exposed in order.
    @Test
    func exposesDiatonicDegrees() {
        #expect(MusicTheoryKit.Harmony.Degree.allCases == [.I, .II, .III, .IV, .V, .VI, .VII])
        #expect(MusicTheoryKit.Harmony.Degree.V.zeroBasedIndex == 4)
    }

    /// Verify that descriptions use Roman numerals for conventional degrees.
    @Test
    func describesConventionalDegrees() {
        #expect(MusicTheoryKit.Harmony.Degree.IV.romanNumeral == "IV")
        #expect(MusicTheoryKit.Harmony.Degree.VII.description == "VII")
    }

    /// Verify that larger degrees fall back to a readable numeric description.
    @Test
    func describesExtendedDegrees() {
        let ninthDegree = MusicTheoryKit.Harmony.Degree(rawValue: 9)

        #expect(ninthDegree?.romanNumeral == "Degree 9")
        #expect(ninthDegree?.description == "Degree 9")
    }

    /// Verify that harmonic-function mapping works for supported major and minor key families.
    @Test
    func resolvesHarmonicFunctionInSupportedKeys() {
        let cMajor = MusicTheoryKit.Harmony.Key.major(tonic: .C)
        let aMinor = MusicTheoryKit.Harmony.Key.naturalMinor(tonic: .A)

        #expect(MusicTheoryKit.Harmony.Degree.I.harmonicFunction(in: cMajor) == .tonic)
        #expect(MusicTheoryKit.Harmony.Degree.II.harmonicFunction(in: cMajor) == .predominant)
        #expect(MusicTheoryKit.Harmony.Degree.V.harmonicFunction(in: cMajor) == .dominant)
        #expect(MusicTheoryKit.Harmony.Degree.IV.harmonicFunction(in: aMinor) == .predominant)
        #expect(MusicTheoryKit.Harmony.Degree.VII.harmonicFunction(in: aMinor) == .dominant)
    }

    /// Verify that modal keys do not currently force a harmonic-function interpretation.
    @Test
    func leavesModalFunctionUndefined() {
        let dDorian = MusicTheoryKit.Harmony.Key(tonic: .D, scaleKind: .dorian)

        #expect(MusicTheoryKit.Harmony.Degree.II.harmonicFunction(in: dDorian) == nil)
        #expect(MusicTheoryKit.Harmony.Degree.HarmonicFunction.tonic.description == "Tonic")
    }
}
