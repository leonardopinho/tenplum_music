import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:templum_music/templum_music.dart';

void main() {
  group('templum_music Package Tests', () {
    test('Pitch mapping resolves correct steps for treble clef', () {
      expect(Pitch.c4.step, equals(-2)); // Middle C
      expect(Pitch.e4.step, equals(0)); // Bottom line
      expect(Pitch.b4.step, equals(4)); // Middle line
      expect(Pitch.f5.step, equals(8)); // Top line
    });

    test('NoteDuration returns correct beat ratios', () {
      expect(NoteDuration.whole.beats, equals(4.0));
      expect(NoteDuration.quarter.beats, equals(1.0));
      expect(NoteDuration.eighth.beats, equals(0.5));
    });

    test(
      'Note models correctly distinguish rests, pitches, and tablatures',
      () {
        const note = Note(
          pitch: Pitch.d4,
          duration: NoteDuration.quarter,
          startBeat: 0.0,
        );
        const tabNote = Note(
          string: 6,
          fret: 3,
          duration: NoteDuration.quarter,
          startBeat: 0.0,
        );
        const rest = Note(duration: NoteDuration.quarter, startBeat: 1.0);

        expect(note.isRest, isFalse);
        expect(note.pitch, equals(Pitch.d4));

        expect(tabNote.isRest, isFalse);
        expect(tabNote.string, equals(6));
        expect(tabNote.fret, equals(3));

        expect(rest.isRest, isTrue);
        expect(rest.pitch, isNull);
      },
    );

    test('Fretboard calculation equivalents work correctly', () {
      expect(CustomFretboard.normalize('C#'), equals('DB'));
      expect(CustomFretboard.areNotesEquivalent('C#', 'Db'), isTrue);
      expect(CustomFretboard.getNoteAt('E', 5), equals('A'));
      expect(CustomFretboard.getNoteAt('A', 7), equals('E'));
    });

    testWidgets('SheetMusicView renders without errors', (
      WidgetTester tester,
    ) async {
      final measures = [
        const Measure(
          number: 1,
          notes: [
            Note(
              pitch: Pitch.d4,
              duration: NoteDuration.quarter,
              startBeat: 0.0,
            ),
            Note(
              pitch: Pitch.e4,
              duration: NoteDuration.quarter,
              startBeat: 1.0,
            ),
            Note(duration: NoteDuration.half, startBeat: 2.0),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SheetMusicView(measures: measures)),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('TablatureView renders without errors', (
      WidgetTester tester,
    ) async {
      final measures = [
        const Measure(
          number: 1,
          notes: [
            Note(
              string: 6,
              fret: 10,
              duration: NoteDuration.quarter,
              startBeat: 0.0,
            ),
            Note(
              string: 5,
              fret: 12,
              duration: NoteDuration.quarter,
              startBeat: 1.0,
            ),
            Note(
              string: 4,
              fret: 12,
              duration: NoteDuration.quarter,
              startBeat: 2.0,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TablatureView(measures: measures)),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('ChordDefinition parses placements and markers correctly', () {
      const chord = ChordDefinition(
        name: 'C',
        startFret: 1,
        placements: [
          ChordPlacement(string: 5, fret: 3, finger: 3),
          ChordPlacement(string: 4, fret: 2, finger: 2),
          ChordPlacement(string: 2, fret: 1, finger: 1),
        ],
        stringMarkers: [
          ChordStringMarker.open, // String 1 (High E)
          ChordStringMarker.none, // String 2
          ChordStringMarker.open, // String 3
          ChordStringMarker.none, // String 4
          ChordStringMarker.none, // String 5
          ChordStringMarker.muted, // String 6 (Low E)
        ],
      );

      expect(chord.name, equals('C'));
      expect(chord.startFret, equals(1));
      expect(chord.placements.length, equals(3));
      expect(chord.stringMarkers.first, equals(ChordStringMarker.open));
      expect(chord.stringMarkers.last, equals(ChordStringMarker.muted));
    });

    test(
      'ChordDefinition infers open string markers from fret-0 placements',
      () {
        const chord = ChordDefinition(
          name: 'Cmaj7',
          placements: [
            ChordPlacement(string: 5, fret: 3, finger: 3),
            ChordPlacement(string: 4, fret: 2, finger: 2),
            ChordPlacement(string: 3, fret: 0),
            ChordPlacement(string: 2, fret: 0),
            ChordPlacement(string: 1, fret: 0),
          ],
          stringMarkers: [
            ChordStringMarker.none,
            ChordStringMarker.none,
            ChordStringMarker.none,
            ChordStringMarker.none,
            ChordStringMarker.none,
            ChordStringMarker.muted,
          ],
        );

        expect(chord.effectiveStringMarkers[0], equals(ChordStringMarker.open));
        expect(chord.effectiveStringMarkers[1], equals(ChordStringMarker.open));
        expect(chord.effectiveStringMarkers[2], equals(ChordStringMarker.open));
        expect(
          chord.effectiveStringMarkers[5],
          equals(ChordStringMarker.muted),
        );
      },
    );

    test('Measure and Note value equality works for equivalent data', () {
      const noteA = Note(
        pitch: Pitch.e4,
        duration: NoteDuration.quarter,
        startBeat: 0.0,
      );
      const noteB = Note(
        pitch: Pitch.e4,
        duration: NoteDuration.quarter,
        startBeat: 0.0,
      );

      const measureA = Measure(number: 1, notes: [noteA]);
      const measureB = Measure(number: 1, notes: [noteB]);

      expect(noteA, equals(noteB));
      expect(measureA, equals(measureB));
    });

    testWidgets('ChordDiagramView renders on Canvas without errors', (
      WidgetTester tester,
    ) async {
      const chord = ChordDefinition(
        name: 'Dm7',
        startFret: 1,
        placements: [
          ChordPlacement(string: 1, fret: 1, finger: 1),
          ChordPlacement(string: 2, fret: 1, finger: 1),
          ChordPlacement(string: 3, fret: 2, finger: 2),
        ],
        stringMarkers: [
          ChordStringMarker.none,
          ChordStringMarker.none,
          ChordStringMarker.none,
          ChordStringMarker.open,
          ChordStringMarker.muted,
          ChordStringMarker.muted,
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChordDiagramView(chord: chord)),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets(
      'CustomFretboard resolves taps and triggers onNoteTapped callback',
      (WidgetTester tester) async {
        String? tappedNote;
        int? tappedString;
        int? tappedFret;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomFretboard(
                tuning: const ['E', 'A', 'D', 'G', 'B', 'E'],
                startFret: 0,
                endFret: 12,
                highlightedNotes: const ['A'],
                onNoteTapped: (note, string, fret) {
                  tappedNote = note;
                  tappedString = string;
                  tappedFret = fret;
                },
              ),
            ),
          ),
        );

        final gestureDetectorFinder = find.byType(GestureDetector);
        expect(gestureDetectorFinder, findsOneWidget);

        final double tapX = 60.0 + 20.0 + 4.5 * 80.0;
        final double tapY = 20.0 + 5 * 40.0;

        final RenderBox box = tester.renderObject(gestureDetectorFinder);
        final Offset topLeft = box.localToGlobal(Offset.zero);

        await tester.tapAt(topLeft + Offset(tapX, tapY));
        await tester.pump();

        expect(tappedNote, equals('A'));
        expect(tappedString, equals(6));
        expect(tappedFret, equals(5));
      },
    );

    testWidgets(
      'CustomFretboard renders with custom FretboardStyle configuration',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomFretboard(
                highlightedNotes: ['C'],
                style: FretboardStyle(
                  woodColor: Colors.blueGrey,
                  fretWireColor: Colors.amber,
                  markerColor: Colors.pink,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'CustomFretboard tap mapping respects startFret when it is above zero',
      (WidgetTester tester) async {
        int? tappedFret;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomFretboard(
                startFret: 5,
                endFret: 12,
                highlightedNotes: const ['A'],
                onNoteTapped: (note, string, fret) {
                  tappedFret = fret;
                },
              ),
            ),
          ),
        );

        final gestureDetectorFinder = find.byType(GestureDetector);
        final RenderBox box = tester.renderObject(gestureDetectorFinder);
        final Offset topLeft = box.localToGlobal(Offset.zero);

        // First rendered fret region should map to startFret.
        await tester.tapAt(topLeft + const Offset(60.0, 120.0));
        await tester.pump();

        expect(tappedFret, equals(5));
      },
    );
  });
}
