import 'package:flutter/material.dart';
import '../models/pixel_art_data.dart';

/// High-performance CustomPainter for rendering pixel art grid
/// Optimized to handle up to 256x256 (65,536 pixels) at 60 FPS
class PixelBoardPainter extends CustomPainter {
  final PixelArtData pixelData;
  final double pixelSize;
  final bool showNumbers;
  final bool showGrid;

  PixelBoardPainter({
    required this.pixelData,
    required this.pixelSize,
    this.showNumbers = true,
    this.showGrid = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw all pixels
    for (int y = 0; y < pixelData.height; y++) {
      for (int x = 0; x < pixelData.width; x++) {
        final rect = Rect.fromLTWH(
          x * pixelSize,
          y * pixelSize,
          pixelSize,
          pixelSize,
        );

        final currentColor = pixelData.getCurrentColor(x, y);

        if (currentColor != null) {
          // Draw filled pixel
          paint.color = currentColor;
          canvas.drawRect(rect, paint);
        } else {
          // Draw unfilled pixel with white background
          paint.color = Colors.white;
          canvas.drawRect(rect, paint);

          // Draw number if zoomed in enough and numbers are visible
          if (showNumbers && pixelSize > 15) {
            final targetColor = pixelData.getTargetColor(x, y);
            final number = pixelData.getNumberForColor(targetColor);

            if (number != null) {
              _drawNumber(canvas, rect, number, pixelSize);
            }
          }
        }

        // Draw grid lines
        if (showGrid) {
          canvas.drawRect(rect, gridPaint);
        }
      }
    }
  }

  void _drawNumber(Canvas canvas, Rect rect, int number, double pixelSize) {
    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: pixelSize * 0.5,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: number.toString(),
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    final offset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(PixelBoardPainter oldDelegate) {
    return oldDelegate.pixelData != pixelData ||
        oldDelegate.pixelSize != pixelSize ||
        oldDelegate.showNumbers != showNumbers ||
        oldDelegate.showGrid != showGrid;
  }
}
