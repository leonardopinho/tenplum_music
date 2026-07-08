import 'package:flutter/material.dart';
import 'package:tenplum_music/src/models/musical_models.dart';
import 'package:tenplum_music/src/rendering/tablature_painter.dart';

class TablatureView extends StatelessWidget {
  final List<Measure> measures;
  final Color lineColor;
  final Color numberColor;
  final Color backgroundColor;
  final double stringSpacing;
  final int stringCount;
  final double? width;
  final double height;

  const TablatureView({
    super.key,
    required this.measures,
    this.lineColor = Colors.black87,
    this.numberColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.stringSpacing = 14.0,
    this.stringCount = 6,
    this.width,
    this.height = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double finalWidth = width ?? (constraints.maxWidth.isInfinite ? 500.0 : constraints.maxWidth);
        
        // Dynamic height estimation based on line-wrapping:
        // Margins = 32, start margin = 40, min width per measure = 140
        final double availableWidth = finalWidth - 32.0;
        final double usableWidth = availableWidth - 40.0;
        
        int measuresPerLine = (usableWidth / 140.0).floor();
        if (measuresPerLine < 1) measuresPerLine = 1;
        
        final int linesCount = (measures.length / measuresPerLine).ceil();
        final double calculatedHeight = (linesCount * 120.0) + 40.0;
        final double finalHeight = height > calculatedHeight ? height : calculatedHeight;

        return SizedBox(
          width: finalWidth,
          height: finalHeight,
          child: CustomPaint(
            size: Size(finalWidth, finalHeight),
            painter: TablaturePainter(
              measures: measures,
              lineColor: lineColor,
              numberColor: numberColor,
              backgroundColor: backgroundColor,
              stringSpacing: stringSpacing,
              stringCount: stringCount,
            ),
          ),
        );
      },
    );
  }
}
