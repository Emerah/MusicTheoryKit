
# MusicTheoryKit

`MusicTheoryKit` is a Swift package for modeling practical music theory in code.

It is built to be useful as an **educational tool**: you can move from basic pitch and interval concepts to keys, scales, chords, progressions, and beat-based song structure using small, explicit value types.

## Why Use MusicTheoryKit?

- Teaches theory through code with clear, composable models
- Keeps pitch, harmony, and time in distinct namespaces
- Supports analysis-oriented workflows (degrees, harmonic functions, cadences)
- Includes notation-aware spelling (`NoteName`) for keys, scales, and chords
- Uses pure Swift value types that are easy to test and reason about

## Installation

Add `MusicTheoryKit` to your `Package.swift` dependencies and target dependencies.

```swift
dependencies: [
    .package(url: "https://github.com/Emerah/MusicTheoryKit.git", branch: "main")
]
```

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["MusicTheoryKit"]
    )
]
```

## Quick Start

```swift
import MusicTheoryKit

let c = MusicTheoryKit.Pitch.PitchClass.C
let e = c.transposed(by: 4)                 // E
let majorThird = MTKPitch.Interval(from: c, to: e)
print(majorThird)                            // Major Third
```

## Tutorial

### 1) Pitch and Interval Basics

```swift
import MusicTheoryKit

let c4 = MTKPitch.Pitch(pitchClass: .C, octave: 4)
let g4 = MTKPitch.Interval.perfectFifth.applied(to: c4)
print(g4)                                    // G4

let a4 = MTKPitch.Pitch(pitchClass: .A, octave: 4)
print(a4.frequency())                        // 440.0

let nearA = MTKPitch.Pitch.fromFrequency(442)
print(nearA?.description ?? "n/a")
```

### 2) Build Scales and Spell Them

```swift
import MusicTheoryKit

let dFlatMajor = MTKHarmony.Scale.major(tonic: .CSharp)
print(dFlatMajor.pitchClasses)               // [C#, D#, F, F#, G#, A#, C]

let noteNames = dFlatMajor.noteNames(tonicNoteName: .DFlat)
print(noteNames ?? [])                       // [Db, Eb, F, Gb, Ab, Bb, C]
```

`noteNames(tonicNoteName:)` returns `nil` when spelling would require accidentals not currently modeled (for example, double sharps/flats).

### 3) Work with Keys and Metadata

```swift
import MusicTheoryKit

let key = MTKHarmony.Key(noteName: .DFlat, scaleKind: .major)
print(key.description)                       // Db Major

if let signature = key.keySignature {
    print(signature.accidentalCount)         // 5
    print(signature.accidentalType?.description ?? "Natural")
    print(signature.alteredLetters)          // [B, E, A, D, G]
}

print(key.relativeNaturalMinor?.description ?? "n/a") // Bb Natural Minor
```

### 4) Build Chords and Progressions

```swift
import MusicTheoryKit

let chord = MTKHarmony.Chord(root: .C, quality: .dominantNinth)
print(chord.pitchClasses)                    // [C, E, G, A#, D]

let spelled = chord.noteNames(rootNoteName: .C)
print(spelled ?? [])                         // [C, E, G, Bb, D]

let progression = MTKHarmony.ChordProgression(
    key: .major(tonic: .C),
    degrees: [.II, .V, .I]
)!

print(progression.harmonicFunctions)         // [predominant, dominant, tonic]
print(progression.cadence?.description ?? "No Cadence")
```

### 5) Model Rhythm and Song Form

```swift
import MusicTheoryKit

let fourFour = MTKTime.TimeSignature(numerator: 4, denominator: 4)!
let event = MTKTime.NoteEvent(
    pitch: .init(pitchClass: .C, octave: 4),
    startBeat: 0,
    duration: 1,
    velocity: 90
)!

let measure1 = MTKTime.Measure(number: 1, timeSignature: fourFour, events: [event])!
let measure2 = MTKTime.Measure(number: 2, timeSignature: fourFour)!

let intro = MTKTime.Song.Section(kind: .intro, startMeasureNumber: 1, endMeasureNumber: 1)!
let verse = MTKTime.Song.Section(kind: .verse, startMeasureNumber: 2, endMeasureNumber: 2)!

let song = MTKTime.Song(
    title: "Lesson",
    measures: [measure1, measure2],
    sections: [intro, verse],
    key: .major(tonic: .C),
    tempoBPM: 96
)!

print(song.totalBeatCount)                   // 8
print(song.section(containingMeasureNumber: 2)?.kind.description ?? "None")
```

> Tip: `MTKPitch`, `MTKHarmony`, and `MTKTime` are public typealiases for `MusicTheoryKit.Pitch`, `MusicTheoryKit.Harmony`, and `MusicTheoryKit.Time`.

## Package Structure

### `MusicTheoryKit.Pitch`

**`PitchClass`**  
Represents one of the 12 chromatic classes (`C` through `B`) independent of octave, and provides transposition and distance in semitones.

**`Pitch`**  
Represents a concrete pitch (`PitchClass` + octave), with useful bridges to chromatic index, MIDI note numbers, and frequency.

**`Interval`**  
Represents musical distance in semitones, supports transposition of `Pitch`/`PitchClass`, and exposes common interval constants.

**`NoteName`**  
Represents a spelled note (letter + accidental), preserving notation identity (`C#` vs `Db`) for key, scale, and chord spelling.

### `MusicTheoryKit.Harmony`

**`Scale`**  
Represents a tonic plus interval pattern, with helpers for degrees, modes, step-pattern comparison, and notation-aware scale spelling.

**`Key`**  
Represents tonal context (tonic + scale kind), with relative/parallel relationships and key-signature metadata when notation is representable.

**`ChordQuality`**  
Represents the interval formula of a chord (triads, sevenths, extensions, and alterations) independent of root.

**`Chord`**  
Represents a root plus quality (and optional bass), with inversion/slash-chord analysis and notation-aware chord spelling.

**`Degree`**  
Represents a one-based scale degree with Roman numeral output and contextual harmonic-function analysis.

**`ChordProgression`**  
Represents a key plus ordered degrees, derives diatonic chords, exposes harmonic-function flow, and detects common cadences.

### `MusicTheoryKit.Time`

**`TimeSignature`**  
Represents meter as numerator/denominator and provides beat-accent analysis for simple and compound time.

**`NoteEvent`**  
Represents a single pitched event in beat time, including start, duration, and velocity.

**`Measure`**  
Represents a numbered measure with local events and meter-aware beat-strength queries.

**`Song`**  
Represents an ordered set of measures with optional key/tempo plus section/form modeling for teaching larger structure.

## Educational Use Cases

- Generate ear-training and theory exercises from typed models
- Show scale/chord spellings and compare enharmonic choices
- Demonstrate harmonic function and cadence behavior in key context
- Visualize rhythm by beat strength, meter, and event placement
- Build interactive lessons on song form (intro, verse, chorus, bridge)

## Current Scope

`MusicTheoryKit` is intentionally core-first. It focuses on theory representation and analysis utilities, not engraving, playback engines, or DAW workflows.
