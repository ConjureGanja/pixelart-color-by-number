import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pixel_art_data.dart';

/// Provider for managing the current pixel art game state
final pixelArtDataProvider =
    StateNotifierProvider<PixelArtDataNotifier, PixelArtData>((ref) {
  return PixelArtDataNotifier();
});

/// StateNotifier for managing pixel art data
class PixelArtDataNotifier extends StateNotifier<PixelArtData> {
  PixelArtDataNotifier() : super(_createSampleData());

  /// Create sample data for testing (can be replaced with actual puzzle data)
  static PixelArtData _createSampleData() {
    // Create a simple 16x16 grid for testing
    // In production, this would load from a file or API
    const size = 16;
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    final colorToNumber = {
      for (int i = 0; i < colors.length; i++) colors[i]: i + 1,
    };

    // Create a simple pattern
    final pixelColors = <Color>[];
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        // Create a simple pattern based on position
        final colorIndex = ((x + y) ~/ 3) % colors.length;
        pixelColors.add(colors[colorIndex]);
      }
    }

    return PixelArtData(
      width: size,
      height: size,
      pixelColors: pixelColors,
      currentColors: List.filled(size * size, null),
      colorToNumber: colorToNumber,
    );
  }

  /// Load a large grid for testing performance (256x256)
  void loadLargeGrid() {
    const size = 256;
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];

    final colorToNumber = {
      for (int i = 0; i < colors.length; i++) colors[i]: i + 1,
    };

    final pixelColors = <Color>[];
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final colorIndex = ((x + y) ~/ 32) % colors.length;
        pixelColors.add(colors[colorIndex]);
      }
    }

    state = PixelArtData(
      width: size,
      height: size,
      pixelColors: pixelColors,
      currentColors: List.filled(size * size, null),
      colorToNumber: colorToNumber,
    );
  }

  /// Fill a pixel with the selected color
  void fillPixel(int x, int y, Color color) {
    state = state.fillPixel(x, y, color);
  }

  /// Clear all filled pixels
  void clearAll() {
    final currentColors = state.currentColors;
    for (var i = 0; i < currentColors.length; i++) {
      currentColors[i] = null;
    }
    state = state.copyWith(
      currentColors: currentColors,
    );
  }

  /// Reset to a new puzzle
  void loadNewPuzzle(PixelArtData data) {
    state = data;
  }
}

/// Provider for the currently selected color
final selectedColorProvider = StateProvider<Color?>((ref) => null);
