import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pixelzen_ai/src/features/ai_generation/services/image_processor_service.dart';

void main() {
  group('ImageProcessorService', () {
    late ImageProcessorService service;

    setUp(() {
      service = ImageProcessorService();
    });

    test('processes image correctly with simple colors', () async {
      // Create a simple 10x10 test image with 3 colors
      final testImage = img.Image(width: 10, height: 10);

      // Fill with three distinct colors in blocks
      for (int y = 0; y < 10; y++) {
        for (int x = 0; x < 10; x++) {
          final color = x < 4
              ? img.ColorRgb8(255, 0, 0) // Red
              : x < 7
                  ? img.ColorRgb8(0, 255, 0) // Green
                  : img.ColorRgb8(0, 0, 255); // Blue
          testImage.setPixel(x, y, color);
        }
      }

      final imageBytes = Uint8List.fromList(img.encodePng(testImage));

      // Process to 5x5 with max 3 colors
      final result = await service.processImage(
        imageBytes: imageBytes,
        targetSize: 5,
        maxColors: 3,
      );

      expect(result.width, 5);
      expect(result.height, 5);
      expect(result.pixelColors.length, 25);
      expect(result.currentColors.length, 25);
      expect(result.colorToNumber.length, lessThanOrEqualTo(3));

      // Verify all current colors are null (unfilled)
      for (final color in result.currentColors) {
        expect(color, isNull);
      }

      // Verify colorToNumber mapping exists
      expect(result.colorToNumber.isNotEmpty, true);
    });

    test('handles different target sizes', () async {
      // Create a simple test image
      final testImage = img.Image(width: 100, height: 100);
      for (int y = 0; y < 100; y++) {
        for (int x = 0; x < 100; x++) {
          testImage.setPixel(x, y, img.ColorRgb8(128, 128, 128));
        }
      }

      final imageBytes = Uint8List.fromList(img.encodePng(testImage));

      // Test different sizes
      for (final size in [49, 96, 256]) {
        final result = await service.processImage(
          imageBytes: imageBytes,
          targetSize: size,
          maxColors: 10,
        );

        expect(result.width, size);
        expect(result.height, size);
        expect(result.pixelColors.length, size * size);
      }
    });

    test('quantizes colors to max limit', () async {
      // Create an image with many colors
      final testImage = img.Image(width: 50, height: 50);

      for (int y = 0; y < 50; y++) {
        for (int x = 0; x < 50; x++) {
          // Create gradient with many colors
          testImage.setPixel(
            x,
            y,
            img.ColorRgb8(
              (x * 5) % 256,
              (y * 5) % 256,
              ((x + y) * 3) % 256,
            ),
          );
        }
      }

      final imageBytes = Uint8List.fromList(img.encodePng(testImage));

      // Process with max 10 colors
      final result = await service.processImage(
        imageBytes: imageBytes,
        targetSize: 20,
        maxColors: 10,
      );

      // Should have at most 10 colors
      expect(result.colorToNumber.length, lessThanOrEqualTo(10));
      expect(result.colorToNumber.length, greaterThan(0));

      // Verify all pixels use palette colors
      for (final pixelColor in result.pixelColors) {
        expect(result.colorToNumber.containsKey(pixelColor), true);
      }
    });

    test('throws exception for invalid image data', () async {
      final invalidBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      expect(
        () => service.processImage(
          imageBytes: invalidBytes,
          targetSize: 10,
          maxColors: 5,
        ),
        throwsException,
      );
    });

    test('handles single color image', () async {
      // Create a solid color image
      final testImage = img.Image(width: 20, height: 20);
      final solidColor = img.ColorRgb8(100, 150, 200);

      for (int y = 0; y < 20; y++) {
        for (int x = 0; x < 20; x++) {
          testImage.setPixel(x, y, solidColor);
        }
      }

      final imageBytes = Uint8List.fromList(img.encodePng(testImage));

      final result = await service.processImage(
        imageBytes: imageBytes,
        targetSize: 10,
        maxColors: 5,
      );

      // Should have only 1 color
      expect(result.colorToNumber.length, 1);

      // All pixels should be the same color
      final firstColor = result.pixelColors[0];
      for (final color in result.pixelColors) {
        expect(color.value, firstColor.value);
      }
    });

    test('creates correct PixelArtData structure', () async {
      final testImage = img.Image(width: 10, height: 10);
      for (int y = 0; y < 10; y++) {
        for (int x = 0; x < 10; x++) {
          testImage.setPixel(x, y, img.ColorRgb8(200, 100, 50));
        }
      }

      final imageBytes = Uint8List.fromList(img.encodePng(testImage));

      final result = await service.processImage(
        imageBytes: imageBytes,
        targetSize: 8,
        maxColors: 5,
      );

      // Verify structure
      expect(result.width, 8);
      expect(result.height, 8);
      expect(result.pixelColors.length, 64);
      expect(result.currentColors.length, 64);

      // Verify all colors have number mappings
      for (final color in result.colorToNumber.keys) {
        expect(result.colorToNumber[color], greaterThan(0));
        expect(result.colorToNumber[color], lessThanOrEqualTo(32));
      }
    });
  });
}
