import 'package:flutter/material.dart';
import 'package:tenplum_music/src/models/musical_models.dart';

class TablaturePainter extends CustomPainter {
  final List<Measure> measures;
  final Color lineColor;
  final Color numberColor;
  final Color backgroundColor;
  final double stringSpacing;
  final int stringCount;

  TablaturePainter({
    required this.measures,
    this.lineColor = Colors.black87,
    this.numberColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.stringSpacing = 14.0,
    this.stringCount = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (measures.isEmpty) return;

    final double width = size.width;
    const double startX = 16.0;
    final double endX = width - 16.0;
    final double availableWidth = endX - startX;

    // Layout configuration
    const double leftMargin = 40.0; // Spacing at the start of each line for TAB label
    const double minMeasureWidth = 140.0;
    final double usableWidth = availableWidth - leftMargin;

    // Calculate measures per line
    int measuresPerLine = (usableWidth / minMeasureWidth).floor();
    if (measuresPerLine < 1) measuresPerLine = 1;

    // Partition measures into lines
    final List<List<Measure>> lines = [];
    for (int i = 0; i < measures.length; i += measuresPerLine) {
      int endIdx = i + measuresPerLine;
      if (endIdx > measures.length) endIdx = measures.length;
      lines.add(measures.sublist(i, endIdx));
    }

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint barlinePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double lineSpacing = 120.0; // Spacing between systems
    for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      final List<Measure> lineMeasures = lines[lineIdx];
      final double staffCenterY = 50.0 + (lineIdx * lineSpacing);

      // Draw 6 String Lines
      // Visual top string (index 0) = String 1 (High E)
      // Visual bottom string (index 5) = String 6 (Low E)
      final double halfOffset = (stringCount - 1) / 2.0;
      for (int i = 0; i < stringCount; i++) {
        double stringY = staffCenterY - (halfOffset - i) * stringSpacing;
        canvas.drawLine(Offset(startX, stringY), Offset(endX, stringY), linePaint);
      }

      // Draw start vertical barline
      double topY = staffCenterY - halfOffset * stringSpacing;
      double bottomY = staffCenterY + halfOffset * stringSpacing;
      canvas.drawLine(Offset(startX, topY), Offset(startX, bottomY), barlinePaint);

      // Draw "TAB" Label
      final TextPainter tabPainter = TextPainter(
        text: TextSpan(
          text: 'T\nA\nB',
          style: TextStyle(
            color: lineColor.withValues(alpha: 0.8),
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            height: 0.95,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tabPainter.layout();
      tabPainter.paint(
        canvas,
        Offset(startX + 8.0, staffCenterY - tabPainter.height / 2.0),
      );

      // Draw Measures
      final double measuresAreaWidth = availableWidth - leftMargin;
      final double measureWidth = measuresAreaWidth / lineMeasures.length;

      for (int mIdx = 0; mIdx < lineMeasures.length; mIdx++) {
        final Measure measure = lineMeasures[mIdx];
        final double measureStartX = startX + leftMargin + (mIdx * measureWidth);
        final double measureEndX = measureStartX + measureWidth;

        // Draw barline at the end of the measure
        canvas.drawLine(
          Offset(measureEndX, topY),
          Offset(measureEndX, bottomY),
          barlinePaint,
        );

        // Draw double barline for last measure
        final bool isLastMeasure = (lineIdx == lines.length - 1) && (mIdx == lineMeasures.length - 1);
        if (isLastMeasure) {
          canvas.drawLine(
            Offset(measureEndX - 4, topY),
            Offset(measureEndX - 4, bottomY),
            Paint()
              ..color = lineColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4.0,
          );
        }

        // Draw notes
        for (final Note note in measure.notes) {
          if (note.isRest || note.string == null || note.fret == null) continue;

          // Calculate horizontal note x position
          final double beatRatio = note.startBeat / measure.beatsPerMeasure;
          final double noteX = measureStartX + 20.0 + beatRatio * (measureWidth - 40.0);

          // Calculate vertical position (string 1 at top, string 6 at bottom)
          final int stringIndex = note.string! - 1;
          final double noteY = staffCenterY - (halfOffset - stringIndex) * stringSpacing;

          // Draw a masking circle to erase the line under the number
          final Paint maskPaint = Paint()
            ..color = backgroundColor
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(noteX, noteY), 8.5, maskPaint);

          // Draw Fret Number
          final TextPainter fretPainter = TextPainter(
            text: TextSpan(
              text: note.fret.toString(),
              style: TextStyle(
                color: numberColor,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          fretPainter.layout();
          fretPainter.paint(
            canvas,
            Offset(noteX - fretPainter.width / 2, noteY - fretPainter.height / 2),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TablaturePainter oldDelegate) {
    return oldDelegate.measures != measures ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.numberColor != numberColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.stringSpacing != stringSpacing ||
        oldDelegate.stringCount != stringCount;
  }
}
