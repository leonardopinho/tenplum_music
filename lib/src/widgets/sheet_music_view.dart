import 'package:flutter/material.dart';
import 'package:tenplum_music/src/models/musical_models.dart';
import 'package:tenplum_music/src/rendering/sheet_music_painter.dart';

class SheetMusicView extends StatelessWidget {
  final List<Measure> measures;
  final Color lineColor;
  final Color noteColor;
  final double staffSpaceSize;
  final double? width;
  final double height;

  const SheetMusicView({
    super.key,
    required this.measures,
    this.lineColor = Colors.black87,
    this.noteColor = Colors.black,
    this.staffSpaceSize = 8.0,
    this.width,
    this.height = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use provided width, or fallback to constraints max width
        final double finalWidth = width ?? (constraints.maxWidth.isInfinite ? 500.0 : constraints.maxWidth);
        
        // Dynamically estimate height based on line-wrapping math:
        // Spacing at start of line = 60, min width per measure = 140
        final double availableWidth = finalWidth - 32.0; // Left & right margins
        final double usableWidth = availableWidth - 60.0;
        
        int measuresPerLine = (usableWidth / 140.0).floor();
        if (measuresPerLine < 1) measuresPerLine = 1;
        
        final int linesCount = (measures.length / measuresPerLine).ceil();
        // Spacing per system = 120 pixels, top/bottom pad = 80 pixels
        final double calculatedHeight = (linesCount * 120.0) + 40.0;
        final double finalHeight = height > calculatedHeight ? height : calculatedHeight;

        return SizedBox(
          width: finalWidth,
          height: finalHeight,
          child: CustomPaint(
            size: Size(finalWidth, finalHeight),
            painter: SheetMusicPainter(
              measures: measures,
              lineColor: lineColor,
              noteColor: noteColor,
              staffSpaceSize: staffSpaceSize,
            ),
          ),
        );
      },
    );
  }
}
