import 'package:flutter/material.dart';
import 'package:tenplum_music/src/models/musical_models.dart';
import 'package:tenplum_music/src/rendering/measure_layout.dart';
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
        final double finalWidth =
            width ??
            (constraints.maxWidth.isInfinite ? 500.0 : constraints.maxWidth);

        final double availableWidth = finalWidth - 32.0; // Left & right margins

        final layout = buildMeasureLayout(
          measures: measures,
          availableWidth: availableWidth,
          leftMargin: 60.0,
          minMeasureWidth: 140.0,
        );

        final double finalHeight =
            RenderDimensionEstimator.estimateSystemHeight(
              lineCount: layout.lineCount,
              lineSpacing: 120.0,
              extraPadding: 40.0,
              minHeight: height,
            );

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
