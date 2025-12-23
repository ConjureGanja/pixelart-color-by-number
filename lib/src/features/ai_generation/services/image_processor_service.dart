import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../game_board/models/pixel_art_data.dart';

/// Service for processing AI-generated images into pixel art
/// Uses K-Means clustering for color quantization
class ImageProcessorService {
  /// Maximum number of colors in the palette
  static const int maxPaletteColors = 32;

  /// Process an image into PixelArtData
  /// 
  /// [imageBytes] - Raw image data
  /// [targetSize] - Target grid size (e.g., 49, 96, 256)
  /// [maxColors] - Maximum number of colors (default: 32)
  Future<PixelArtData> processImage({
    required List<int> imageBytes,
    required int targetSize,
    int maxColors = maxPaletteColors,
  }) async {
    // Decode the image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to target dimensions
    final resized = img.copyResize(
      image,
      width: targetSize,
      height: targetSize,
      interpolation: img.Interpolation.average,
    );

    // Extract all colors from the resized image
    final colors = <Color>[];
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        colors.add(Color.fromARGB(
          pixel.a.toInt(),
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        ));
      }
    }

    // Quantize colors using K-Means clustering
    final palette = _quantizeColors(colors, maxColors);

    // Create color to number mapping
    final colorToNumber = <Color, int>{};
    for (int i = 0; i < palette.length; i++) {
      colorToNumber[palette[i]] = i + 1;
    }

    // Map each pixel to the nearest palette color
    final pixelColors = <Color>[];
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        final originalColor = Color.fromARGB(
          pixel.a.toInt(),
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );
        final nearestColor = _findNearestColor(originalColor, palette);
        pixelColors.add(nearestColor);
      }
    }

    return PixelArtData(
      width: targetSize,
      height: targetSize,
      pixelColors: pixelColors,
      currentColors: List.filled(targetSize * targetSize, null),
      colorToNumber: colorToNumber,
    );
  }

  /// Quantize colors using K-Means clustering algorithm
  List<Color> _quantizeColors(List<Color> colors, int k) {
    if (colors.isEmpty) return [];
    if (colors.length <= k) return colors.toSet().toList();

    // Initialize centroids randomly
    final random = math.Random(42); // Fixed seed for consistency
    final centroids = <Color>[];
    final uniqueColors = colors.toSet().toList();

    // Select k random unique colors as initial centroids
    for (int i = 0; i < k && i < uniqueColors.length; i++) {
      centroids.add(uniqueColors[random.nextInt(uniqueColors.length)]);
    }

    // K-Means iterations
    const maxIterations = 10;
    for (int iteration = 0; iteration < maxIterations; iteration++) {
      // Assign each color to nearest centroid
      final clusters = List.generate(k, (_) => <Color>[]);

      for (final color in colors) {
        int nearestIndex = 0;
        double minDistance = double.infinity;

        for (int i = 0; i < centroids.length; i++) {
          final distance = _colorDistance(color, centroids[i]);
          if (distance < minDistance) {
            minDistance = distance;
            nearestIndex = i;
          }
        }

        clusters[nearestIndex].add(color);
      }

      // Recalculate centroids
      bool converged = true;
      for (int i = 0; i < k; i++) {
        if (clusters[i].isEmpty) continue;

        final newCentroid = _averageColor(clusters[i]);
        if (_colorDistance(centroids[i], newCentroid) > 1.0) {
          converged = false;
        }
        centroids[i] = newCentroid;
      }

      if (converged) break;
    }

    return centroids;
  }

  /// Calculate Euclidean distance between two colors in RGB space
  double _colorDistance(Color c1, Color c2) {
    final dr = c1.red - c2.red;
    final dg = c1.green - c2.green;
    final db = c1.blue - c2.blue;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  /// Calculate average color from a list of colors
  Color _averageColor(List<Color> colors) {
    if (colors.isEmpty) return Colors.white;

    int totalR = 0, totalG = 0, totalB = 0;

    for (final color in colors) {
      totalR += color.red;
      totalG += color.green;
      totalB += color.blue;
    }

    return Color.fromARGB(
      255,
      totalR ~/ colors.length,
      totalG ~/ colors.length,
      totalB ~/ colors.length,
    );
  }

  /// Find the nearest palette color for a given color
  Color _findNearestColor(Color color, List<Color> palette) {
    if (palette.isEmpty) return color;

    Color nearest = palette[0];
    double minDistance = _colorDistance(color, nearest);

    for (int i = 1; i < palette.length; i++) {
      final distance = _colorDistance(color, palette[i]);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = palette[i];
      }
    }

    return nearest;
  }
}
