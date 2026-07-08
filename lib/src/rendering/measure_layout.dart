import 'dart:math' as math;

import 'package:tenplum_music/src/models/musical_models.dart';

class MeasureLayout {
  final int measuresPerLine;
  final int lineCount;
  final List<List<Measure>> lines;

  const MeasureLayout({
    required this.measuresPerLine,
    required this.lineCount,
    required this.lines,
  });
}

MeasureLayout buildMeasureLayout({
  required List<Measure> measures,
  required double availableWidth,
  required double leftMargin,
  required double minMeasureWidth,
}) {
  if (measures.isEmpty) {
    return const MeasureLayout(measuresPerLine: 1, lineCount: 0, lines: []);
  }

  final usableWidth = math.max(0.0, availableWidth - leftMargin);
  final measuresPerLine = math.max(1, (usableWidth / minMeasureWidth).floor());
  final lineCount = (measures.length / measuresPerLine).ceil();

  final lines = <List<Measure>>[];
  for (int i = 0; i < measures.length; i += measuresPerLine) {
    final end = math.min(i + measuresPerLine, measures.length);
    lines.add(measures.sublist(i, end));
  }

  return MeasureLayout(
    measuresPerLine: measuresPerLine,
    lineCount: lineCount,
    lines: lines,
  );
}

class RenderDimensionEstimator {
  static double estimateSystemHeight({
    required int lineCount,
    required double lineSpacing,
    required double extraPadding,
    required double minHeight,
  }) {
    final contentHeight = (lineCount * lineSpacing) + extraPadding;
    return math.max(minHeight, contentHeight);
  }
}
