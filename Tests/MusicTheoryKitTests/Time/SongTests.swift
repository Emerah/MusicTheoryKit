// Package: MusicTheoryKit
// File: SongTests.swift
// Path: Tests/MusicTheoryKitTests/Time/SongTests.swift
// Date: 2026-03-04
// Author: Ahmed Emerah
// Email: ahmed.emerah@icloud.com
// Github: https://github.com/Emerah

import Testing
@testable import MusicTheoryKit

// MARK: - Song tests

struct SongTests {
    /// Verify that song construction validates title, tempo, measure numbering, and section ranges.
    @Test
    func validatesSongInvariants() {
        let fourFour = MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 4)!
        let measureOne = MusicTheoryKit.Time.Measure(number: 1, timeSignature: fourFour)!
        let measureTwo = MusicTheoryKit.Time.Measure(number: 2, timeSignature: fourFour)!
        let measureThree = MusicTheoryKit.Time.Measure(number: 3, timeSignature: fourFour)!
        let validSection = MusicTheoryKit.Time.Song.Section(kind: .intro, startMeasureNumber: 1, endMeasureNumber: 2)!
        let overlappingSection = MusicTheoryKit.Time.Song.Section(kind: .verse, startMeasureNumber: 2, endMeasureNumber: 3)!
        let outOfBoundsSection = MusicTheoryKit.Time.Song.Section(kind: .chorus, startMeasureNumber: 3, endMeasureNumber: 4)!

        #expect(MusicTheoryKit.Time.Song(title: "   ", measures: []) == nil)
        #expect(MusicTheoryKit.Time.Song(title: "Song", measures: [measureThree]) == nil)
        #expect(MusicTheoryKit.Time.Song(title: "Song", measures: [measureOne], tempoBPM: 0) == nil)
        #expect(
            MusicTheoryKit.Time.Song(
                title: "Song",
                measures: [measureOne, measureTwo, measureThree],
                sections: [validSection, overlappingSection]
            ) == nil
        )
        #expect(
            MusicTheoryKit.Time.Song(
                title: "Song",
                measures: [measureOne, measureTwo, measureThree],
                sections: [outOfBoundsSection]
            ) == nil
        )
        #expect(
            MusicTheoryKit.Time.Song(
                title: "Song",
                measures: [measureOne],
                tempoBPM: 120
            ) != nil
        )
    }

    /// Verify that total beats and measure count derive from the stored measures.
    @Test
    func computesAggregateStructure() {
        let measures = [
            MusicTheoryKit.Time.Measure(number: 1, timeSignature: .init(numerator: 4, denominator: 4)!)!,
            MusicTheoryKit.Time.Measure(number: 2, timeSignature: .init(numerator: 3, denominator: 4)!)!,
        ]
        let song = MusicTheoryKit.Time.Song(title: "Meter Study", measures: measures)!

        #expect(song.measureCount == 2)
        #expect(song.totalBeatCount == 7)
        #expect(song.description == "Meter Study (2 measures)")
    }

    /// Verify that local note events flatten into global beat positions while preserving note metadata.
    @Test
    func flattensNoteEventsIntoSongTimeline() {
        let firstMeasureEvent = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .C, octave: 4),
            startBeat: 1,
            duration: 1,
            velocity: 90
        )!
        let secondMeasureEvent = MusicTheoryKit.Time.NoteEvent(
            pitch: .init(pitchClass: .G, octave: 4),
            startBeat: 0.5,
            duration: 0.5,
            velocity: 72
        )!
        let measures = [
            MusicTheoryKit.Time.Measure(
                number: 1,
                timeSignature: .init(numerator: 4, denominator: 4)!,
                events: [firstMeasureEvent]
            )!,
            MusicTheoryKit.Time.Measure(
                number: 2,
                timeSignature: .init(numerator: 4, denominator: 4)!,
                events: [secondMeasureEvent]
            )!,
        ]
        let song = MusicTheoryKit.Time.Song(title: "Timeline", measures: measures)!

        #expect(song.flattenedNoteEvents == [
            .init(pitch: .init(pitchClass: .C, octave: 4), startBeat: 1, duration: 1, velocity: 90)!,
            .init(pitch: .init(pitchClass: .G, octave: 4), startBeat: 4.5, duration: 0.5, velocity: 72)!,
        ])
    }

    /// Verify that measure lookup and appending preserve contiguous numbering.
    @Test
    func looksUpAndAppendsMeasures() {
        let fourFour = MusicTheoryKit.Time.TimeSignature(numerator: 4, denominator: 4)!
        let measureOne = MusicTheoryKit.Time.Measure(number: 1, timeSignature: fourFour)!
        let measureTwo = MusicTheoryKit.Time.Measure(number: 2, timeSignature: fourFour)!
        let invalidMeasure = MusicTheoryKit.Time.Measure(number: 4, timeSignature: fourFour)!
        let song = MusicTheoryKit.Time.Song(
            title: "Form",
            measures: [measureOne],
            key: .major(tonic: .C),
            tempoBPM: 96
        )!

        #expect(song.measure(number: 1) == measureOne)
        #expect(song.measure(number: 2) == nil)
        #expect(song.appending(measureTwo)?.measureCount == 2)
        #expect(song.appending(invalidMeasure) == nil)
    }

    /// Verify that sections describe song form and can be queried by measure number and kind.
    @Test
    func exposesSongSections() {
        let measures = [
            MusicTheoryKit.Time.Measure(number: 1, timeSignature: .init(numerator: 4, denominator: 4)!)!,
            MusicTheoryKit.Time.Measure(number: 2, timeSignature: .init(numerator: 4, denominator: 4)!)!,
            MusicTheoryKit.Time.Measure(number: 3, timeSignature: .init(numerator: 4, denominator: 4)!)!,
            MusicTheoryKit.Time.Measure(number: 4, timeSignature: .init(numerator: 4, denominator: 4)!)!,
        ]
        let intro = MusicTheoryKit.Time.Song.Section(kind: .intro, startMeasureNumber: 1, endMeasureNumber: 1)!
        let verse = MusicTheoryKit.Time.Song.Section(kind: .verse, startMeasureNumber: 2, endMeasureNumber: 3)!
        let chorus = MusicTheoryKit.Time.Song.Section(kind: .chorus, startMeasureNumber: 4, endMeasureNumber: 4)!
        let song = MusicTheoryKit.Time.Song(
            title: "Form Study",
            measures: measures,
            sections: [chorus, intro, verse]
        )!

        #expect(song.sections == [intro, verse, chorus])
        #expect(song.section(containingMeasureNumber: 1) == intro)
        #expect(song.section(containingMeasureNumber: 3) == verse)
        #expect(song.section(containingMeasureNumber: 5) == nil)
        #expect(song.sections(of: .verse) == [verse])
        #expect(MusicTheoryKit.Time.Song.Section.Kind.preChorus.description == "Pre-Chorus")
    }
}
