import 'package:flutter/material.dart';
import 'package:tenplum_music/src/models/musical_models.dart';
import 'package:tenplum_music/src/rendering/chord_diagram_painter.dart';

class ChordDiagramView extends StatelessWidget {
  final ChordDefinition chord;
  final Color lineColor;
  final Color dotColor;
  final Color textColor;
  final double width;
  final double height;

  const ChordDiagramView({
    super.key,
    required this.chord,
    this.lineColor = Colors.black87,
    this.dotColor = const Color(0xFF4F46E5), // Indigo accent
    this.textColor = Colors.black87,
    this.width = 180.0,
    this.height = 220.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: ChordDiagramPainter(
          chord: chord,
          lineColor: lineColor,
          dotColor: dotColor,
          textColor: textColor,
        ),
      ),
    );
  }
}
