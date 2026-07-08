import 'package:flutter/foundation.dart';

enum Pitch {
  c4(-2, 'C4'),
  d4(-1, 'D4'),
  e4(0, 'E4'),
  f4(1, 'F4'),
  g4(2, 'G4'),
  a4(3, 'A4'),
  b4(4, 'B4'),
  c5(5, 'C5'),
  d5(6, 'D5'),
  e5(7, 'E5'),
  f5(8, 'F5'),
  g5(9, 'G5'),
  a5(10, 'A5');

  final int step;
  final String name;

  const Pitch(this.step, this.name);
}

enum NoteDuration {
  whole(4.0, 'Whole'),
  half(2.0, 'Half'),
  quarter(1.0, 'Quarter'),
  eighth(0.5, 'Eighth'),
  sixteenth(0.25, 'Sixteenth');

  final double beats;
  final String name;

  const NoteDuration(this.beats, this.name);
}

enum ClefType { treble, bass }

class Note {
  final Pitch? pitch;
  final NoteDuration duration;
  final double startBeat;

  final int? string;
  final int? fret; // Fret number (0 for open string)

  const Note({
    this.pitch,
    required this.duration,
    required this.startBeat,
    this.string,
    this.fret,
  });

  bool get isRest => pitch == null && fret == null;

  @override
  String toString() {
    if (isRest) return 'Rest(${duration.name})';
    if (fret != null && string != null) {
      return 'TabNote(String: $string, Fret: $fret, ${duration.name})';
    }
    return 'Note(${pitch!.name}, ${duration.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.pitch == pitch &&
        other.duration == duration &&
        other.startBeat == startBeat &&
        other.string == string &&
        other.fret == fret;
  }

  @override
  int get hashCode => Object.hash(pitch, duration, startBeat, string, fret);
}

class Measure {
  final int number;
  final List<Note> notes;
  final double beatsPerMeasure; // Defaults to 4.0 (4/4 time signature)

  const Measure({
    required this.number,
    required this.notes,
    this.beatsPerMeasure = 4.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Measure &&
        other.number == number &&
        listEquals(other.notes, notes) &&
        other.beatsPerMeasure == beatsPerMeasure;
  }

  @override
  int get hashCode =>
      Object.hash(number, Object.hashAll(notes), beatsPerMeasure);
}

class ChordPlacement {
  final int string; // 1-indexed (1 = High E, 6 = Low E)
  final int fret; // Fret number relative to nut (e.g., 1, 2, 3)
  final int? finger; // Optional: 1, 2, 3, 4
  final int? barreEndString;

  const ChordPlacement({
    required this.string,
    required this.fret,
    this.finger,
    this.barreEndString,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChordPlacement &&
        other.string == string &&
        other.fret == fret &&
        other.finger == finger &&
        other.barreEndString == barreEndString;
  }

  @override
  int get hashCode => Object.hash(string, fret, finger, barreEndString);
}

enum ChordStringMarker { none, muted, open }

class ChordDefinition {
  final String name; // e.g., "Dm7"
  final int startFret;
  final List<ChordPlacement> placements;

  // High E (index 0) to Low E (index 5) markers
  final List<ChordStringMarker> stringMarkers;

  const ChordDefinition({
    required this.name,
    this.startFret = 1,
    required this.placements,
    this.stringMarkers = const [
      ChordStringMarker.none,
      ChordStringMarker.none,
      ChordStringMarker.none,
      ChordStringMarker.none,
      ChordStringMarker.none,
      ChordStringMarker.none,
    ],
  });

  // High E (index 0) to Low E (index 5), with open markers inferred from fret-0 placements.
  List<ChordStringMarker> get effectiveStringMarkers {
    final resolved = List<ChordStringMarker>.filled(6, ChordStringMarker.none);

    for (int i = 0; i < stringMarkers.length && i < 6; i++) {
      resolved[i] = stringMarkers[i];
    }

    for (final placement in placements) {
      if (placement.fret != 0) continue;
      final markerIndex = placement.string - 1;
      if (markerIndex < 0 || markerIndex >= 6) continue;
      if (resolved[markerIndex] == ChordStringMarker.none) {
        resolved[markerIndex] = ChordStringMarker.open;
      }
    }

    return List.unmodifiable(resolved);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChordDefinition &&
        other.name == name &&
        other.startFret == startFret &&
        listEquals(other.placements, placements) &&
        listEquals(other.stringMarkers, stringMarkers);
  }

  @override
  int get hashCode => Object.hash(
    name,
    startFret,
    Object.hashAll(placements),
    Object.hashAll(stringMarkers),
  );
}
