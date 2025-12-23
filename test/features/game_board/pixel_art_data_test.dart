import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelzen_ai/src/features/game_board/models/pixel_art_data.dart';

void main() {
  group('PixelArtData', () {
    test('creates empty data correctly', () {
      const width = 10;
      const height = 10;
      final data = PixelArtData.empty(width, height);

      expect(data.width, width);
      expect(data.height, height);
      expect(data.pixelColors.length, width * height);
      expect(data.currentColors.length, width * height);
    });

    test('getIndex calculates correct index', () {
      final data = PixelArtData.empty(10, 10);

      expect(data.getIndex(0, 0), 0);
      expect(data.getIndex(5, 0), 5);
      expect(data.getIndex(0, 1), 10);
      expect(data.getIndex(5, 5), 55);
    });

    test('fillPixel updates currentColors', () {
      final data = PixelArtData.empty(10, 10);
      final color = Colors.red;

      final updated = data.fillPixel(5, 5, color);

      expect(updated.getCurrentColor(5, 5), color);
      expect(updated.isPixelFilled(5, 5), true);
      expect(data.getCurrentColor(5, 5), null); // Original unchanged
    });

    test('completion percentage calculates correctly', () {
      const width = 10;
      const height = 10;
      final pixelColors = List.filled(width * height, Colors.red);
      final currentColors = List<Color?>.filled(width * height, null);

      var data = PixelArtData(
        width: width,
        height: height,
        pixelColors: pixelColors,
        currentColors: currentColors,
        colorToNumber: {Colors.red: 1},
      );

      expect(data.completionPercentage, 0.0);

      // Fill half correctly
      for (int i = 0; i < 50; i++) {
        data = data.fillPixel(i % width, i ~/ width, Colors.red);
      }

      expect(data.completionPercentage, 0.5);
      expect(data.isComplete, false);

      // Fill all correctly
      for (int i = 50; i < 100; i++) {
        data = data.fillPixel(i % width, i ~/ width, Colors.red);
      }

      expect(data.completionPercentage, 1.0);
      expect(data.isComplete, true);
    });

    test('handles large grids (256x256)', () {
      const size = 256;
      final data = PixelArtData.empty(size, size);

      expect(data.width, size);
      expect(data.height, size);
      expect(data.pixelColors.length, size * size);
      expect(data.currentColors.length, size * size);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = PixelArtData.empty(10, 10);
      final newColors = List.filled(100, Colors.blue);

      final updated = original.copyWith(pixelColors: newColors);

      expect(updated.pixelColors, newColors);
      expect(updated.width, original.width);
      expect(original.pixelColors, isNot(newColors)); // Original unchanged
    });
  });
}
