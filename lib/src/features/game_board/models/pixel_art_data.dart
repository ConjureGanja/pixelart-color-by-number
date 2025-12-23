import 'package:flutter/material.dart';

/// Data model for pixel art color-by-number puzzle
/// Optimized for performance with large grids (up to 256x256)
class PixelArtData {
  /// Width of the pixel grid
  final int width;

  /// Height of the pixel grid
  final int height;

  /// Target color for each pixel (the solution)
  /// Index: y * width + x
  final List<Color> pixelColors;

  /// Current colors filled in by the user
  /// Index: y * width + x
  /// null means unfilled
  final List<Color?> currentColors;

  /// Map of color to number label (e.g., Color -> 1, 2, 3, etc.)
  final Map<Color, int> colorToNumber;

  PixelArtData({
    required this.width,
    required this.height,
    required this.pixelColors,
    required this.currentColors,
    required this.colorToNumber,
  }) : assert(pixelColors.length == width * height,
            'pixelColors length must equal width * height'),
       assert(currentColors.length == width * height,
            'currentColors length must equal width * height');

  /// Create empty pixel art data
  factory PixelArtData.empty(int width, int height) {
    return PixelArtData(
      width: width,
      height: height,
      pixelColors: List.filled(width * height, Colors.white),
      currentColors: List.filled(width * height, null),
      colorToNumber: {},
    );
  }

  /// Get the index for a given x, y coordinate
  int getIndex(int x, int y) => y * width + x;

  /// Get the target color at x, y
  Color getTargetColor(int x, int y) => pixelColors[getIndex(x, y)];

  /// Get the current color at x, y (null if unfilled)
  Color? getCurrentColor(int x, int y) => currentColors[getIndex(x, y)];

  /// Check if pixel at x, y is filled
  bool isPixelFilled(int x, int y) => currentColors[getIndex(x, y)] != null;

  /// Check if pixel at x, y is correctly colored
  bool isPixelCorrect(int x, int y) {
    final current = currentColors[getIndex(x, y)];
    if (current == null) return false;
    return current.value == pixelColors[getIndex(x, y)].value;
  }

  /// Get the number label for a color
  int? getNumberForColor(Color color) => colorToNumber[color];

  /// Fill a pixel with a color
  PixelArtData fillPixel(int x, int y, Color color) {
    final index = getIndex(x, y);

    // If the pixel already has the same color, avoid creating a new list/instance.
    final existing = currentColors[index];
    if (existing != null && existing.value == color.value) {
      return this;
    }

    final newCurrentColors = List<Color?>.from(currentColors);
    newCurrentColors[index] = color;
    return copyWith(currentColors: newCurrentColors);
  }

  /// Calculate completion percentage
  double get completionPercentage {
    int correctCount = 0;
    for (int i = 0; i < pixelColors.length; i++) {
      if (currentColors[i] != null &&
          currentColors[i]!.value == pixelColors[i].value) {
        correctCount++;
      }
    }
    return correctCount / pixelColors.length;
  }

  /// Check if puzzle is complete
  bool get isComplete => completionPercentage == 1.0;

  /// Get all unique colors in the palette
  Set<Color> get uniqueColors => colorToNumber.keys.toSet();

  /// Create a copy with updated fields
  PixelArtData copyWith({
    int? width,
    int? height,
    List<Color>? pixelColors,
    List<Color?>? currentColors,
    Map<Color, int>? colorToNumber,
  }) {
    return PixelArtData(
      width: width ?? this.width,
      height: height ?? this.height,
      pixelColors: pixelColors ?? this.pixelColors,
      currentColors: currentColors ?? this.currentColors,
      colorToNumber: colorToNumber ?? this.colorToNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PixelArtData) return false;

    // Compare dimensions first (fast check)
    if (width != other.width || height != other.height) return false;

    // Compare lists content
    if (pixelColors.length != other.pixelColors.length) return false;
    if (currentColors.length != other.currentColors.length) return false;

    for (int i = 0; i < pixelColors.length; i++) {
      if (pixelColors[i].value != other.pixelColors[i].value) return false;
    }

    for (int i = 0; i < currentColors.length; i++) {
      final c1 = currentColors[i];
      final c2 = other.currentColors[i];
      if (c1 == null && c2 == null) continue;
      if (c1 == null || c2 == null) return false;
      if (c1.value != c2.value) return false;
    }

    // Compare colorToNumber map
    if (colorToNumber.length != other.colorToNumber.length) return false;
    for (final entry in colorToNumber.entries) {
      final otherValue = other.colorToNumber[entry.key];
      if (otherValue != entry.value) return false;
    }

    return true;
  }

  @override
  int get hashCode {
    int hash = width.hashCode ^ height.hashCode;

    // Hash a sample of pixels to avoid iterating through all 65k pixels
    // Sample every 16th pixel for reasonable distribution
    for (int i = 0; i < pixelColors.length; i += 16) {
      hash ^= pixelColors[i].value.hashCode;
    }

    for (int i = 0; i < currentColors.length; i += 16) {
      final color = currentColors[i];
      if (color != null) {
        hash ^= color.value.hashCode;
      }
    }

    // Include colorToNumber in hash
    hash ^= colorToNumber.length.hashCode;

    return hash;
  }
}
