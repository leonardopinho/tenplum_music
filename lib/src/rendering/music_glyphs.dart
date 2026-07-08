import 'package:flutter/material.dart';

class MusicGlyphs {
  // Returns a Path for a stylized Treble Clef centered at (0, 0)
  static Path getTrebleClefPath(double height) {
    final Path path = Path();
    final double s = height / 100.0; // Scale factor

    // Draw a stylized G-Clef
    path.moveTo(-2 * s, 40 * s);
    // Vertical center line
    path.lineTo(-2 * s, -45 * s);
    // Top loop
    path.cubicTo(-2 * s, -55 * s, 10 * s, -50 * s, 8 * s, -38 * s);
    path.cubicTo(6 * s, -20 * s, -12 * s, -10 * s, -12 * s, 10 * s);
    // Main lower loop wrapping around G4 line
    path.cubicTo(-12 * s, 25 * s, 5 * s, 32 * s, 10 * s, 18 * s);
    path.cubicTo(12 * s, 8 * s, 0 * s, 0 * s, -6 * s, 5 * s);
    path.cubicTo(-10 * s, 10 * s, -8 * s, 22 * s, -1 * s, 22 * s);
    path.cubicTo(3 * s, 22 * s, 5 * s, 15 * s, 2 * s, 10 * s);
    
    // Bottom swirl
    path.moveTo(-2 * s, 40 * s);
    path.cubicTo(-2 * s, 48 * s, -8 * s, 52 * s, -12 * s, 48 * s);
    path.cubicTo(-15 * s, 45 * s, -14 * s, 40 * s, -10 * s, 40 * s);

    return path;
  }

  // Returns a Path for a Quarter Rest (Z-like lightning shape) centered at (0, 0)
  static Path getQuarterRestPath(double height) {
    final Path path = Path();
    final double s = height / 40.0; // Scale factor

    path.moveTo(-4 * s, -15 * s);
    path.lineTo(4 * s, -7 * s);
    path.lineTo(-5 * s, 3 * s);
    path.lineTo(3 * s, 10 * s);
    path.quadraticBezierTo(5 * s, 15 * s, 0 * s, 18 * s);
    path.quadraticBezierTo(-4 * s, 20 * s, -6 * s, 16 * s);

    return path;
  }

  // Paints a note head at (x, y)
  static void paintNoteHead(Canvas canvas, double x, double y, double size, bool filled, Color color) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-20 * 3.14159 / 180); // Standard tilted note head

    final Paint paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = filled ? 0.0 : 2.5;

    // A note head is an oval wider than it is high
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size * 1.3, height: size * 0.95),
      paint,
    );

    canvas.restore();
  }

  // Paints a rest of any duration
  static void paintRest(Canvas canvas, double x, double y, double size, double staffSpace, String durationName, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (durationName == 'Semibreve') {
      // Whole rest: sits hanging from the 4th staff line (drawn as a small rectangle hanging down)
      canvas.drawRect(
        Rect.fromLTWH(x - 8, y, 16, staffSpace * 0.45),
        paint,
      );
    } else if (durationName == 'Mínima') {
      // Half rest: sits resting on the 3rd staff line (drawn as a small rectangle sitting up)
      canvas.drawRect(
        Rect.fromLTWH(x - 8, y - staffSpace * 0.45, 16, staffSpace * 0.45),
        paint,
      );
    } else {
      // Quarter / Eighth / etc. rest: drawn using our path helper
      canvas.save();
      canvas.translate(x, y);
      final Path restPath = getQuarterRestPath(staffSpace * 2.5);
      
      final Paint strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(restPath, strokePaint);
      canvas.restore();
    }
  }
}
