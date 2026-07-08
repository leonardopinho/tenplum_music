import 'package:flutter/material.dart';
import 'package:tenplum_music/src/rendering/fretboard_painter.dart';

class FretboardStyle {
  final Color woodColor;
  final Color fretWireColor;
  final Color stringColor;
  final Color markerColor;
  final Color rootMarkerColor;
  final Color noteTextColor;
  final Color glowColor;
  final Color inlayDotColor;

  const FretboardStyle({
    this.woodColor = const Color(0xFF2E1C0C),
    this.fretWireColor = const Color(0xFFB0BEC5),
    this.stringColor = const Color(0xFFCFD8DC),
    this.markerColor = const Color(0xFF4F46E5),
    this.rootMarkerColor = const Color(0xFFEF4444),
    this.noteTextColor = Colors.white,
    this.glowColor = const Color(0xFF10B981),
    this.inlayDotColor = const Color(0x99B0BEC5), // grey/silver inlay dots
  });
}

class CustomFretboard extends StatefulWidget {
  final List<String> tuning;
  final int startFret;
  final int endFret;
  final List<String> highlightedNotes;
  final String? rootNote;
  final Map<String, String>? noteDegrees;
  final bool showDegrees;
  final bool showOpenStrings;
  final void Function(String note, int string, int fret)? onNoteTapped;
  final FretboardStyle style;

  const CustomFretboard({
    super.key,
    this.tuning = const ['E', 'A', 'D', 'G', 'B', 'E'],
    this.startFret = 0,
    this.endFret = 12,
    required this.highlightedNotes,
    this.rootNote,
    this.noteDegrees,
    this.showDegrees = false,
    this.showOpenStrings = true,
    this.onNoteTapped,
    this.style = const FretboardStyle(),
  });

  static const List<String> _chromaticSharps = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];
  static const List<String> _chromaticFlats = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
  ];

  static String normalize(String note) {
    String n = note.trim().toUpperCase();
    if (n == 'C#') return 'DB';
    if (n == 'D#') return 'EB';
    if (n == 'F#') return 'GB';
    if (n == 'G#') return 'AB';
    if (n == 'A#') return 'BB';
    if (n == 'DB') return 'DB';
    if (n == 'EB') return 'EB';
    if (n == 'GB') return 'GB';
    if (n == 'AB') return 'AB';
    if (n == 'BB') return 'BB';
    return n;
  }

  static bool areNotesEquivalent(String note1, String note2) {
    return normalize(note1) == normalize(note2);
  }

  static String getNoteAt(String openNote, int fret) {
    int openIdx = _chromaticSharps.indexWhere((n) => areNotesEquivalent(n, openNote));
    if (openIdx == -1) {
      openIdx = _chromaticFlats.indexWhere((n) => areNotesEquivalent(n, openNote));
    }
    if (openIdx == -1) return openNote;
    
    int targetIdx = (openIdx + fret) % 12;
    return _chromaticSharps[targetIdx];
  }

  @override
  State<CustomFretboard> createState() => _CustomFretboardState();
}

class _CustomFretboardState extends State<CustomFretboard> {
  int? _tappedString;
  int? _tappedFret;

  void _handleTap(TapUpDetails details) {
    final double localX = details.localPosition.dx;
    final double localY = details.localPosition.dy;

    final double fretWidth = 80.0;
    final double openStringAreaWidth = widget.showOpenStrings ? 60.0 : 0.0;
    final double leftEdge = openStringAreaWidth + 20.0;
    final double topMargin = 20.0;
    final double bottomMargin = 20.0;
    const double height = 240.0;
    final double fretboardHeight = height - topMargin - bottomMargin;

    final List<String> visualStrings = List.from(widget.tuning.reversed);
    final int stringCount = visualStrings.length;
    final double stringSpacing = fretboardHeight / (stringCount - 1);

    // 1. Resolve String Index (visual top stringIdx = 0 corresponds to String 6, bottom is String 1)
    final double relativeY = localY - topMargin;
    final double stringIdxDouble = relativeY / stringSpacing;
    final int stringIdx = stringIdxDouble.round().clamp(0, stringCount - 1);
    final int stringNum = stringIdx + 1; // 1-indexed (1 = High E, 6 = Low E)

    // 2. Resolve Fret
    int tappedFret = -1;
    if (widget.showOpenStrings && localX >= 20.0 && localX < leftEdge) {
      tappedFret = 0; // Open string
    } else if (localX >= leftEdge) {
      final double relativeX = localX - leftEdge;
      tappedFret = widget.startFret + (relativeX / fretWidth).floor() + 1;
    }

    if (tappedFret >= widget.startFret && tappedFret <= widget.endFret) {
      final String openNote = visualStrings[stringIdx];
      final String noteName = CustomFretboard.getNoteAt(openNote, tappedFret);

      setState(() {
        _tappedString = stringNum;
        _tappedFret = tappedFret;
      });

      if (widget.onNoteTapped != null) {
        widget.onNoteTapped!(noteName, stringNum, tappedFret);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fretWidth = 80.0;
    final int fretCount = widget.endFret - widget.startFret;
    final double openStringAreaWidth = widget.showOpenStrings ? 60.0 : 0.0;
    final double totalWidth = openStringAreaWidth + (fretCount * fretWidth) + 40.0;
    const double height = 240.0;

    final List<String> visualStrings = List.from(widget.tuning.reversed);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: GestureDetector(
        onTapUp: _handleTap,
        child: Container(
          width: totalWidth,
          height: height,
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: CustomPaint(
            size: Size(totalWidth, height),
            painter: FretboardPainter(
              strings: visualStrings,
              startFret: widget.startFret,
              endFret: widget.endFret,
              highlightedNotes: widget.highlightedNotes,
              rootNote: widget.rootNote,
              noteDegrees: widget.noteDegrees,
              showDegrees: widget.showDegrees,
              showOpenStrings: widget.showOpenStrings,
              fretWidth: fretWidth,
              openStringAreaWidth: openStringAreaWidth,
              tappedString: _tappedString,
              tappedFret: _tappedFret,
              style: widget.style,
            ),
          ),
        ),
      ),
    );
  }
}
