import 'package:flutter/material.dart';
import 'package:tenplum_music/src/widgets/custom_fretboard.dart';

class FretboardPainter extends CustomPainter {
  final List<String> strings;
  final int startFret;
  final int endFret;
  final List<String> highlightedNotes;
  final String? rootNote;
  final Map<String, String>? noteDegrees;
  final bool showDegrees;
  final bool showOpenStrings;
  final double fretWidth;
  final double openStringAreaWidth;

  // Tapped note state
  final int? tappedString;
  final int? tappedFret;

  // Style customization
  final FretboardStyle style;

  FretboardPainter({
    required this.strings,
    required this.startFret,
    required this.endFret,
    required this.highlightedNotes,
    required this.rootNote,
    required this.noteDegrees,
    required this.showDegrees,
    required this.showOpenStrings,
    required this.fretWidth,
    required this.openStringAreaWidth,
    required this.style,
    this.tappedString,
    this.tappedFret,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double leftEdge = openStringAreaWidth + 20.0;
    final double fretboardWidth = size.width - leftEdge - 20.0;
    final double topMargin = 20.0;
    final double bottomMargin = 20.0;
    final double fretboardHeight = size.height - topMargin - bottomMargin;
    final int fretCount = endFret - startFret;

    // Draw Fretboard Wood Background
    final Rect fretboardRect = Rect.fromLTWH(leftEdge, topMargin, fretboardWidth, fretboardHeight);
    final Paint woodPaint = Paint()
      ..color = style.woodColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(fretboardRect, woodPaint);

    final Paint grainPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double y = topMargin + 4; y < topMargin + fretboardHeight; y += 8) {
      canvas.drawLine(Offset(leftEdge, y), Offset(leftEdge + fretboardWidth, y), grainPaint);
    }

    final Paint markerPaint = Paint()
      ..color = style.inlayDotColor
      ..style = PaintingStyle.fill;

    for (int fret = startFret + 1; fret <= endFret; fret++) {
      if (fret == 3 || fret == 5 || fret == 7 || fret == 9 || fret == 15 || fret == 17 || fret == 19 || fret == 21) {
        double fretLeft = leftEdge + (fret - startFret - 1) * fretWidth;
        double dotX = fretLeft + (fretWidth / 2);
        double dotY = topMargin + (fretboardHeight / 2);
        canvas.drawCircle(Offset(dotX, dotY), 6.0, markerPaint);
      } else if (fret == 12 || fret == 24) {
        double fretLeft = leftEdge + (fret - startFret - 1) * fretWidth;
        double dotX = fretLeft + (fretWidth / 2);
        double dotY1 = topMargin + (fretboardHeight * 0.25);
        double dotY2 = topMargin + (fretboardHeight * 0.75);
        canvas.drawCircle(Offset(dotX, dotY1), 6.0, markerPaint);
        canvas.drawCircle(Offset(dotX, dotY2), 6.0, markerPaint);
      }
    }

    // Draw Fret Lines
    final Paint fretPaint = Paint()
      ..color = style.fretWireColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw Nut (fret 0 line, thicker)
    final Paint nutPaint = Paint()
      ..color = style.fretWireColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawLine(Offset(leftEdge, topMargin), Offset(leftEdge, topMargin + fretboardHeight), nutPaint);

    for (int i = 1; i <= fretCount; i++) {
      double x = leftEdge + i * fretWidth;
      canvas.drawLine(Offset(x, topMargin), Offset(x, topMargin + fretboardHeight), fretPaint);
    }

    // Draw Strings
    final int stringCount = strings.length;
    final double stringSpacing = fretboardHeight / (stringCount - 1);

    for (int i = 0; i < stringCount; i++) {
      double y = topMargin + i * stringSpacing;
      double strokeWidth = 1.0 + (i * 0.5);

      final Paint stringPaint = Paint()
        ..color = style.stringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawLine(Offset(leftEdge, y), Offset(leftEdge + fretboardWidth, y), stringPaint);

      if (showOpenStrings) {
        final Paint openStringPaint = Paint()
          ..color = style.stringColor.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
        canvas.drawLine(Offset(20.0, y), Offset(leftEdge, y), openStringPaint);
      }
    }

    // Draw Note Markers
    for (int stringIdx = 0; stringIdx < stringCount; stringIdx++) {
      String openNote = strings[stringIdx];
      double y = topMargin + stringIdx * stringSpacing;

      for (int fret = startFret; fret <= endFret; fret++) {
        if (fret == 0 && !showOpenStrings) continue;

        String noteAtFret = CustomFretboard.getNoteAt(openNote, fret);

        String? matchedHighlightNote;
        for (var hn in highlightedNotes) {
          if (CustomFretboard.areNotesEquivalent(noteAtFret, hn)) {
            matchedHighlightNote = hn;
            break;
          }
        }

        if (matchedHighlightNote != null) {
          double x;
          if (fret == 0) {
            x = 10.0 + (openStringAreaWidth / 2);
          } else {
            double fretLeft = leftEdge + (fret - startFret - 1) * fretWidth;
            x = fretLeft + (fretWidth / 2);
          }

          bool isRoot = rootNote != null && CustomFretboard.areNotesEquivalent(noteAtFret, rootNote!);
          Color markerColor = isRoot ? style.rootMarkerColor : style.markerColor;

          final Paint markerPaint = Paint()
            ..color = markerColor
            ..style = PaintingStyle.fill;

          final Paint borderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

          double markerRadius = 14.0;
          if (isRoot) {
            RRect rrect = RRect.fromRectAndRadius(Rect.fromCircle(center: Offset(x, y), radius: markerRadius), const Radius.circular(6.0));
            canvas.drawRRect(rrect, markerPaint);
            canvas.drawRRect(rrect, borderPaint);
          } else {
            canvas.drawCircle(Offset(x, y), markerRadius, markerPaint);
            canvas.drawCircle(Offset(x, y), markerRadius, borderPaint);
          }

          String text = matchedHighlightNote;
          if (showDegrees && noteDegrees != null) {
            String? degree;
            for (var entry in noteDegrees!.entries) {
              if (CustomFretboard.areNotesEquivalent(noteAtFret, entry.key)) {
                degree = entry.value;
                break;
              }
            }
            if (degree != null) {
              text = degree;
            }
          }

          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(color: style.noteTextColor, fontSize: 11.0, fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
        }
      }
    }

    // Draw Tapped Note Glow Ring
    if (tappedString != null && tappedFret != null) {
      final int stringIdx = tappedString! - 1;
      if (stringIdx >= 0 && stringIdx < stringCount) {
        final double y = topMargin + stringIdx * stringSpacing;
        double x;
        if (tappedFret == 0) {
          x = 10.0 + (openStringAreaWidth / 2);
        } else {
          double fretLeft = leftEdge + (tappedFret! - startFret - 1) * fretWidth;
          x = fretLeft + (fretWidth / 2);
        }

        final Paint glowPaint = Paint()
          ..color = style.glowColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

        canvas.drawCircle(Offset(x, y), 18.0, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FretboardPainter oldDelegate) {
    return oldDelegate.strings != strings ||
        oldDelegate.startFret != startFret ||
        oldDelegate.endFret != endFret ||
        oldDelegate.highlightedNotes != highlightedNotes ||
        oldDelegate.rootNote != rootNote ||
        oldDelegate.noteDegrees != noteDegrees ||
        oldDelegate.showDegrees != showDegrees ||
        oldDelegate.showOpenStrings != showOpenStrings ||
        oldDelegate.tappedString != tappedString ||
        oldDelegate.tappedFret != tappedFret ||
        oldDelegate.style != style;
  }
}
