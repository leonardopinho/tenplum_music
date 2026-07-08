import 'package:flutter/material.dart';
import 'package:tenplum_music/src/models/musical_models.dart';

class ChordDiagramPainter extends CustomPainter {
  final ChordDefinition chord;
  final Color lineColor;
  final Color dotColor;
  final Color textColor;
  final double stringSpacing;
  final double fretSpacing;

  ChordDiagramPainter({required this.chord, this.lineColor = Colors.black87, this.dotColor = const Color(0xFF4F46E5), this.textColor = Colors.black87, this.stringSpacing = 24.0, this.fretSpacing = 28.0});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftMargin = 35.0;
    const double topMargin = 45.0;

    // Grid coordinates
    const int totalFretsDisplayed = 5;
    final double gridLeft = leftMargin;
    final double gridRight = leftMargin + 5 * stringSpacing;
    final double gridTop = topMargin;
    final double gridBottom = topMargin + totalFretsDisplayed * fretSpacing;

    final Paint gridPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw 6 Strings (Vertical lines)
    for (int i = 0; i < 6; i++) {
      double x = gridLeft + i * stringSpacing;
      canvas.drawLine(Offset(x, gridTop), Offset(x, gridBottom), gridPaint);
    }

    // Draw 5 Fret Lines (Horizontal lines)
    for (int i = 0; i <= totalFretsDisplayed; i++) {
      double y = gridTop + i * fretSpacing;
      canvas.drawLine(Offset(gridLeft, y), Offset(gridRight, y), gridPaint);
    }

    // Draw Nut (Thicker top line if starting at fret 1)
    if (chord.startFret == 1) {
      final Paint nutPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5;
      canvas.drawLine(Offset(gridLeft - 1, gridTop), Offset(gridRight + 1, gridTop), nutPaint);
    } else {
      // Draw start fret label on the left (e.g. "5 fr")
      final TextPainter fretLabelPainter = TextPainter(
        text: TextSpan(
          text: '${chord.startFret} fr',
          style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 11.0, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      fretLabelPainter.layout();
      fretLabelPainter.paint(canvas, Offset(gridLeft - fretLabelPainter.width - 8, gridTop + (fretSpacing / 2) - fretLabelPainter.height / 2));
    }

    // Draw Chord Name Title
    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: chord.name,
        style: TextStyle(color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset((gridLeft + gridRight) / 2 - titlePainter.width / 2, 4.0));

    // Draw Open / Muted Markers above the Nut
    for (int i = 0; i < 6; i++) {
      // Maps visual index i (0 to 5, left to right) to stringMarkers index (5 to 0, right to left)
      final int markerIndex = 5 - i;
      if (markerIndex < 0 || markerIndex >= chord.stringMarkers.length) continue;

      final marker = chord.stringMarkers[markerIndex];
      final double markerX = gridLeft + i * stringSpacing;
      final double markerY = gridTop - 12.0;

      if (marker == ChordStringMarker.muted) {
        // Draw Muted "X"
        final TextPainter xPainter = TextPainter(
          text: TextSpan(
            text: '✕',
            style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 10.0, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        xPainter.layout();
        xPainter.paint(canvas, Offset(markerX - xPainter.width / 2, markerY - xPainter.height / 2));
      } else if (marker == ChordStringMarker.open) {
        // Draw Open "O"
        final TextPainter oPainter = TextPainter(
          text: TextSpan(
            text: '○',
            style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 11.0, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        oPainter.layout();
        oPainter.paint(canvas, Offset(markerX - oPainter.width / 2, markerY - oPainter.height / 2));
      }
    }

    // Draw Placements (Dots and Barres)
    final Paint dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw Barre Chords first
    for (final placement in chord.placements) {
      if (placement.barreEndString != null) {
        final int relativeFret = placement.fret - chord.startFret;
        if (relativeFret < 0 || relativeFret >= totalFretsDisplayed) continue;

        final double fretY = gridTop + relativeFret * fretSpacing + (fretSpacing / 2);

        // Standard coordinate conversion: S = 6 is Left (i = 0), S = 1 is Right (i = 5)
        final double xStart = gridLeft + (6 - placement.string) * stringSpacing;
        final double xEnd = gridLeft + (6 - placement.barreEndString!) * stringSpacing;

        final Paint barrePaint = Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 16.0;

        canvas.drawLine(Offset(xStart, fretY), Offset(xEnd, fretY), barrePaint);
      }
    }

    // Draw Finger Dots
    for (final placement in chord.placements) {
      final int relativeFret = placement.fret - chord.startFret;
      if (relativeFret < 0 || relativeFret >= totalFretsDisplayed) continue;

      final double dotY = gridTop + relativeFret * fretSpacing + (fretSpacing / 2);
      final double dotX = gridLeft + (6 - placement.string) * stringSpacing;

      // Draw Finger Dot
      canvas.drawCircle(Offset(dotX, dotY), 10.0, dotPaint);
      canvas.drawCircle(Offset(dotX, dotY), 10.0, borderPaint);

      // Draw Finger number text inside if present
      if (placement.finger != null) {
        final TextPainter fingerPainter = TextPainter(
          text: TextSpan(
            text: placement.finger.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        fingerPainter.layout();
        fingerPainter.paint(canvas, Offset(dotX - fingerPainter.width / 2, dotY - fingerPainter.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant ChordDiagramPainter oldDelegate) {
    return oldDelegate.chord != chord || oldDelegate.lineColor != lineColor || oldDelegate.dotColor != dotColor || oldDelegate.textColor != textColor || oldDelegate.stringSpacing != stringSpacing || oldDelegate.fretSpacing != fretSpacing;
  }
}
