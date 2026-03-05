// Package: MusicTheoryKit
// File: ChordProgressionTests.swift
// Path: Tests/MusicTheoryKitTests/Harmony/ChordProgressionTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - ChordProgression tests

struct ChordProgressionTests {
    /// Verify that a progression derives diatonic triads from its key and degree sequence.
    @Test
    func derivesDiatonicChords() {
        let progression = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.I, .IV, .V]
        )

        #expect(progression?.chords == [
            .major(root: .C),
            .major(root: .F),
            .major(root: .G),
        ])
    }

    /// Verify that minor-key progressions derive the expected diatonic triad qualities.
    @Test
    func derivesMinorKeyTriads() {
        let progression = MusicTheoryKit.Harmony.ChordProgression(
            key: .naturalMinor(tonic: .A),
            degrees: [.II, .V, .VII]
        )

        #expect(progression?.chords == [
            .diminished(root: .B),
            .minor(root: .E),
            .major(root: .G),
        ])
    }

    /// Verify that degrees outside the key's scale are rejected.
    @Test
    func rejectsOutOfBoundsDegrees() {
        let progression = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.I, .V, .init(rawValue: 8)!]
        )

        #expect(progression == nil)
    }

    /// Verify that transposition preserves the degree sequence and key kind.
    @Test
    func transposesToNewTonic() {
        let original = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.I, .V, .VI, .IV]
        )!
        let transposed = original.transposed(to: .D)

        #expect(transposed.key == .major(tonic: .D))
        #expect(transposed.degrees == original.degrees)
        #expect(transposed.chords == [
            .major(root: .D),
            .major(root: .A),
            .minor(root: .B),
            .major(root: .G),
        ])
    }

    /// Verify that the textual form exposes the key and Roman-numeral degrees.
    @Test
    func describesProgression() {
        let progression = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.II, .V, .I]
        )!

        #expect(progression.contains(.V))
        #expect(progression.description == "C Major: II - V - I")
    }

    /// Verify that progressions expose harmonic-function analysis from their degrees.
    @Test
    func derivesHarmonicFunctions() {
        let progression = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.I, .II, .V, .I]
        )!

        #expect(progression.harmonicFunctions == [.tonic, .predominant, .dominant, .tonic])
    }

    /// Verify that supported cadence types are detected from the tail of the progression.
    @Test
    func detectsCadences() {
        let authentic = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.II, .V, .I]
        )!
        let plagal = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.I, .IV, .I]
        )!
        let half = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.I, .II, .V]
        )!
        let halfFromSubdominant = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.IV, .V]
        )!
        let deceptive = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.II, .V, .VI]
        )!

        #expect(authentic.cadence == .authentic)
        #expect(plagal.cadence == .plagal)
        #expect(half.cadence == .half)
        #expect(halfFromSubdominant.cadence == .half)
        #expect(deceptive.cadence == .deceptive)
    }

    /// Verify that cadence lookup can be queried directly.
    @Test
    func checksCadenceMembership() {
        let progression = MusicTheoryKit.Harmony.ChordProgression(
            key: .major(tonic: .C),
            degrees: [.II, .V, .I]
        )!

        #expect(progression.endsWithCadence(.authentic))
        #expect(progression.endsWithCadence(.half) == false)
        #expect(MusicTheoryKit.Harmony.ChordProgression.Cadence.plagal.description == "Plagal Cadence")
    }
}
