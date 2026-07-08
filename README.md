# Templum Music

A lightweight, declarative, and vector-based music notation, tablature, interactive fretboard, and chord diagram rendering suite for Flutter.

Built entirely using native Canvas drawing (`CustomPainter`), eliminating any reliance on heavy SMuFL font files, ensuring instant load times, responsive scaling, and native dark/light theme adaptation on all platforms (iOS, Android, macOS, Web, Windows).

---

## Key Features

*   **Sheet Music (`SheetMusicView`)**: Renders treble clef staves, notes with stems, accidentals, and ledger lines. Supports automatic line-wrapping (responsiveness).
  
* **Tablature (`TablatureView`)**: Renders 6-string guitar tablatures with fret numbers perfectly centered and masked over the lines. Supports automatic wrapping.
  
* **Guitar Fretboard (`CustomFretboard`)**: Renders a realistic rosewood fretboard with scale markers, intervals, `O(1)` tap coordinates mapping, click callbacks (`onNoteTapped`), and customizable styles via `FretboardStyle`.
  
* **Chord Diagrams (`ChordDiagramView`)**: Renders vertical chord charts with barre indicators, finger placements, and open (○) or muted (✕) string markers (explicit or inferred from `fret: 0`).

---

## Getting Started

Add the package dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  templum_music:
    path: /path/to/templum_music_lib
```

Import the library in your Dart code:

```dart
import 'package:templum_music/templum_music.dart';
```

---

## Usage Examples

### 1. Sheet Music (`SheetMusicView`)
Renders a sequence of musical notes on a traditional 5-line staff with responsive line-wrapping.

```dart
SheetMusicView(
  measures: [
    Measure(
      number: 1,
      notes: [
        Note(pitch: Pitch.c4, duration: NoteDuration.quarter, startBeat: 0.0), // Middle C
        Note(pitch: Pitch.e4, duration: NoteDuration.quarter, startBeat: 1.0), // E
        Note(pitch: Pitch.g4, duration: NoteDuration.quarter, startBeat: 2.0), // G
        Note(pitch: Pitch.c5, duration: NoteDuration.quarter, startBeat: 3.0), // C Octave
      ],
    ),
  ],
  lineColor: Colors.black87,
  noteColor: Colors.indigo,
  staffSpaceSize: 8.0, // Spacing between staff lines
)
```

**Preview:**

![Sheet Music](https://raw.githubusercontent.com/leonardopinho/templum_music/main/doc/screenshots/sheet_music.png)

---

### 2. Tablature (`TablatureView`)
Renders fret numbers with an opaque circular background mask under the strings to prevent line/number intersections.

```dart
TablatureView(
  measures: [
    Measure(
      number: 1,
      notes: [
        Note(string: 6, fret: 0, duration: NoteDuration.quarter, startBeat: 0.0), // Low E Open
        Note(string: 6, fret: 3, duration: NoteDuration.quarter, startBeat: 1.0), // G (String 6 Fret 3)
        Note(pitch: Pitch.c4, string: 5, fret: 3, duration: NoteDuration.quarter, startBeat: 2.0), // C (String 5 Fret 3)
      ],
    ),
  ],
  lineColor: Colors.black87,
  numberColor: Colors.black87,
  backgroundColor: Colors.white,
  stringSpacing: 14.0,
)
```

**Preview:**

![Tablature](https://raw.githubusercontent.com/leonardopinho/templum_music/main/doc/screenshots/tablature.png)

---

### 3. Interactive Fretboard (`CustomFretboard`)
An interactive fretboard widget. Captures click gestures, resolves the note automatically, and highlights note degrees/tonics.

```dart
CustomFretboard(
  tuning: const ['E', 'A', 'D', 'G', 'B', 'E'],
  startFret: 0,
  endFret: 12,
  highlightedNotes: const ['D', 'F#', 'A', 'C'], // Notes to display (D7 Arpeggio)
  rootNote: 'D', // Tonic note displays as a red rounded square
  noteDegrees: const {
    'D': 'R',
    'F#': '3',
    'A': '5',
    'C': 'b7',
  },
  showDegrees: true, // Display harmonic intervals instead of note letters
  showOpenStrings: true,
  onNoteTapped: (note, string, fret) {
    print('Tapped note: $note at String $string, Fret $fret');
    // Trigger audio playback or state updates here
  },
  // Custom visual styling configurations
  style: const FretboardStyle(
    woodColor: Color(0xFF2E1C0C),      // Dark brown rosewood background
    fretWireColor: Color(0xFFB0BEC5),  // Silver frets
    markerColor: Colors.indigo,        // Scale notes marker fill
    rootMarkerColor: Colors.red,       // Root/tonic marker fill
    glowColor: Color(0xFF10B981),      // Active glow ring on click
  ),
)
```

**Preview:**

![Interactive Fretboard](https://raw.githubusercontent.com/leonardopinho/templum_music/main/doc/screenshots/fretboard.png)

---

### 4. Chord Diagrams (`ChordDiagramView`)
Renders standard vertical guitar chord charts with support for multiple configurations.

`ChordDefinition` supports open strings in two equivalent ways:
- Set `ChordStringMarker.open` in `stringMarkers`
- Or provide `ChordPlacement(..., fret: 0)` and let `effectiveStringMarkers` infer the open marker

```dart
ChordDiagramView(
  chord: ChordDefinition(
    name: 'Bm7',
    startFret: 2,
    placements: [
      ChordPlacement(string: 5, fret: 2, finger: 1), // Barre begins (finger 1)
      ChordPlacement(string: 4, fret: 4, finger: 3), // Finger 3 on fret 4
      ChordPlacement(string: 3, fret: 2, finger: 1), 
      ChordPlacement(string: 2, fret: 3, finger: 2), // Finger 2 on fret 3
      ChordPlacement(string: 1, fret: 2, finger: 1), 
    ],
    stringMarkers: [
      ChordStringMarker.muted, // Muted String 6 (X)
      ChordStringMarker.none,
      ChordStringMarker.none,
      ChordStringMarker.none,
      ChordStringMarker.none,
      ChordStringMarker.none,
    ],
  ),
  lineColor: Colors.black87,
  textColor: Colors.black87,
  dotColor: Colors.indigo,
)
```

**Preview:**

![Chord Diagrams](https://raw.githubusercontent.com/leonardopinho/templum_music/main/doc/screenshots/chords.png)

---

## Theoretical Music Model

All components use a shared, clean set of domain models located in `src/models/musical_models.dart`:

*   **`Pitch`**: Scientific pitch notation definition (e.g., `Pitch.c4` = Middle C, `Pitch.a4` = A 440Hz).
*   **`NoteDuration`**: Rhythmic duration fraction mappings (e.g., `NoteDuration.whole` = 4 beats, `NoteDuration.quarter` = 1 beat).
*   **`Note`**: Represents a note event (pitch, duration, start beat, string/fret).
*   **`Measure`**: Groups notes together inside a numbered bar.
*   **`ChordDefinition`**: Contains diagram placements and string markers, with `effectiveStringMarkers` resolving inferred open strings.

---

## License

This project is licensed under the **Apache License 2.0**.

Copyright (c) 2026 Leonardo Pinho.

You are free to use, copy, modify, distribute and include this library in personal, educational, open source or commercial projects, provided that the original copyright notice and license are preserved.

Commercial use is allowed under this license. However, this license does not grant rights to use the project author's name, brand, identity or trademarks to endorse derivative products without permission.

See the [`LICENSE`](LICENSE) file for details.

## Attribution

When using this library, please keep the original copyright and license notice:

```text
    Templum Music Tools
    Copyright (c) 2026 Leonardo Pinho
    Licensed under the Apache License, Version 2.0
```

## Disclaimer

This software is provided as-is, without warranties or guarantees of any kind.

## Author

Created by **Leonardo Pinho**.

- Email: contato@leonardopinho.com
- GitHub: https://github.com/leonardopinho
- LinkedIn: https://www.linkedin.com/in/leonardo-pinho
