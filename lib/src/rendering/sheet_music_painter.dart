import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tenplum_music/src/models/musical_models.dart';
import 'package:tenplum_music/src/rendering/measure_layout.dart';
import 'package:tenplum_music/src/rendering/music_glyphs.dart';

class SheetMusicPainter extends CustomPainter {
  final List<Measure> measures;
  final Color lineColor;
  final Color noteColor;
  final double staffSpaceSize;

  SheetMusicPainter({
    required this.measures,
    this.lineColor = Colors.black87,
    this.noteColor = Colors.black,
    this.staffSpaceSize = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (measures.isEmpty) return;

    final double width = size.width;
    const double startX = 16.0;
    final double endX = width - 16.0;
    final double availableWidth = endX - startX;

    // Layout configuration
    const double leftMargin =
        60.0; // Spacing at the start of each line for clef
    const double minMeasureWidth = 140.0;
    final layout = buildMeasureLayout(
      measures: measures,
      availableWidth: availableWidth,
      leftMargin: leftMargin,
      minMeasureWidth: minMeasureWidth,
    );
    final lines = layout.lines;

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint barlinePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw each line vertically
    const double lineSpacing = 120.0; // Distance between staff lines vertically
    for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      final List<Measure> lineMeasures = lines[lineIdx];
      final double staffCenterY = 40.0 + (lineIdx * lineSpacing);

      // Draw the 5 Staff Lines
      for (int i = 0; i < 5; i++) {
        double lineY = staffCenterY - (2 - i) * staffSpaceSize;
        canvas.drawLine(Offset(startX, lineY), Offset(endX, lineY), linePaint);
      }

      // Draw start vertical barline
      double topY = staffCenterY - 2 * staffSpaceSize;
      double bottomY = staffCenterY + 2 * staffSpaceSize;
      canvas.drawLine(
        Offset(startX, topY),
        Offset(startX, bottomY),
        barlinePaint,
      );

      // Draw Treble Clef
      canvas.save();
      canvas.translate(startX + 24.0, staffCenterY + staffSpaceSize * 0.5);
      final Path clefPath = MusicGlyphs.getTrebleClefPath(staffSpaceSize * 4);
      final Paint clefPaint = Paint()
        ..color = noteColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(clefPath, clefPaint);
      canvas.restore();

      // Draw Measures in this line
      final double measuresAreaWidth = availableWidth - leftMargin;
      final double measureWidth = measuresAreaWidth / lineMeasures.length;

      for (int mIdx = 0; mIdx < lineMeasures.length; mIdx++) {
        final Measure measure = lineMeasures[mIdx];
        final double measureStartX =
            startX + leftMargin + (mIdx * measureWidth);
        final double measureEndX = measureStartX + measureWidth;

        // Draw barline at the end of the measure
        canvas.drawLine(
          Offset(measureEndX, topY),
          Offset(measureEndX, bottomY),
          barlinePaint,
        );

        // If this is the very last measure in the piece, draw a double barline
        final bool isLastMeasure =
            (lineIdx == lines.length - 1) && (mIdx == lineMeasures.length - 1);
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

        // Draw notes inside this measure
        for (final Note note in measure.notes) {
          // Calculate horizontal x position proportional to startBeat
          final double beatRatio = note.startBeat / measure.beatsPerMeasure;
          // Leave some margins inside the measure
          final double noteX =
              measureStartX + 20.0 + beatRatio * (measureWidth - 40.0);

          if (note.isRest) {
            // Draw Rest
            final double restY = staffCenterY;
            MusicGlyphs.paintRest(
              canvas,
              noteX,
              restY,
              staffSpaceSize * 1.5,
              staffSpaceSize,
              note.duration.name,
              noteColor,
            );
          } else {
            // Draw Note
            final Pitch pitch = note.pitch!;
            // Vertical position based on step formula:
            // S = 4 is middle line (B4), S = 0 is bottom line (E4)
            final double noteY =
                staffCenterY - (pitch.step - 4) * (staffSpaceSize / 2);

            // Draw Ledger Lines (if note is below C4 or above A5)
            if (pitch.step <= -2) {
              // Bottom ledger lines (e.g. C4 at step -2)
              for (int stepIdx = -2; stepIdx >= pitch.step; stepIdx -= 2) {
                double ledgerY =
                    staffCenterY - (stepIdx - 4) * (staffSpaceSize / 2);
                canvas.drawLine(
                  Offset(noteX - 10, ledgerY),
                  Offset(noteX + 10, ledgerY),
                  linePaint,
                );
              }
            } else if (pitch.step >= 10) {
              // Top ledger lines (e.g. A5 at step 10)
              for (int stepIdx = 10; stepIdx <= pitch.step; stepIdx += 2) {
                double ledgerY =
                    staffCenterY - (stepIdx - 4) * (staffSpaceSize / 2);
                canvas.drawLine(
                  Offset(noteX - 10, ledgerY),
                  Offset(noteX + 10, ledgerY),
                  linePaint,
                );
              }
            }

            // Draw Note Head (filled for quarter/eighth/sixteenth, open for whole/half)
            final bool filled =
                note.duration != NoteDuration.whole &&
                note.duration != NoteDuration.half;
            MusicGlyphs.paintNoteHead(
              canvas,
              noteX,
              noteY,
              staffSpaceSize * 1.2,
              filled,
              noteColor,
            );

            // Draw Stem (vertical line) if duration is shorter than a whole note
            if (note.duration != NoteDuration.whole) {
              final double stemHeight = staffSpaceSize * 3.5;
              final bool stemUp =
                  pitch.step <
                  4; // Stem up for notes below middle line, down otherwise

              final double stemX = stemUp
                  ? noteX + (staffSpaceSize * 0.6)
                  : noteX - (staffSpaceSize * 0.6);
              final double stemEndY = stemUp
                  ? noteY - stemHeight
                  : noteY + stemHeight;

              final Paint stemPaint = Paint()
                ..color = noteColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.8;

              canvas.drawLine(
                Offset(stemX, noteY),
                Offset(stemX, stemEndY),
                stemPaint,
              );

              // Draw flag if note is eighth/sixteenth
              if (note.duration == NoteDuration.eighth ||
                  note.duration == NoteDuration.sixteenth) {
                final double flagX = stemX;
                final double flagStartY = stemEndY;
                final double flagDirectionY = stemUp ? 1 : -1;

                final Path flagPath = Path()
                  ..moveTo(flagX, flagStartY)
                  ..quadraticBezierTo(
                    flagX + 8,
                    flagStartY + 8 * flagDirectionY,
                    flagX + 10,
                    flagStartY + 14 * flagDirectionY,
                  )
                  ..quadraticBezierTo(
                    flagX + 6,
                    flagStartY + 10 * flagDirectionY,
                    flagX,
                    flagStartY + 4 * flagDirectionY,
                  );

                final Paint flagPaint = Paint()
                  ..color = noteColor
                  ..style = PaintingStyle.fill;

                canvas.drawPath(flagPath, flagPaint);

                // Add secondary flag for sixteenth notes
                if (note.duration == NoteDuration.sixteenth) {
                  final double shiftY = 6 * flagDirectionY;
                  canvas.save();
                  canvas.translate(0, shiftY);
                  canvas.drawPath(flagPath, flagPaint);
                  canvas.restore();
                }
              }
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SheetMusicPainter oldDelegate) {
    return !listEquals(oldDelegate.measures, measures) ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.noteColor != noteColor ||
        oldDelegate.staffSpaceSize != staffSpaceSize;
  }
}
