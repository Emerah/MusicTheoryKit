// Package: MusicTheoryKit
// File: MusicTheoryKit.swift
// Path: Sources/MusicTheoryKit/MusicTheoryKit.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

/// Namespace for the MusicTheoryKit public API.
public enum MusicTheoryKit {}

// MARK: - Pitch domain

extension MusicTheoryKit {
    /// Namespace for pitch primitives such as pitch classes, pitches, and intervals.
    public enum Pitch {}
}

// MARK: - Harmony domain

extension MusicTheoryKit {
    /// Namespace for harmonic structures such as scales, keys, chords, and progressions.
    public enum Harmony {}
}

// MARK: - Time domain

extension MusicTheoryKit {
    /// Namespace for time-based musical structures such as note events, measures, and songs.
    public enum Time {}
}

// MARK: - Domain aliases

/// Short alias for ``MusicTheoryKit/Pitch`` domain types.
public typealias MTKPitch = MusicTheoryKit.Pitch

/// Short alias for ``MusicTheoryKit/Harmony`` domain types.
public typealias MTKHarmony = MusicTheoryKit.Harmony

/// Short alias for ``MusicTheoryKit/Time`` domain types.
public typealias MTKTime = MusicTheoryKit.Time
