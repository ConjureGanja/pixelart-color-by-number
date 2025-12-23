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
    final newCurrentColors = List<Color?>.from(currentColors);
    newCurrentColors[getIndex(x, y)] = color;
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
}
