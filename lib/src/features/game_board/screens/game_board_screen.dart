import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_provider.dart';
import '../widgets/pixel_board_widget.dart';
import '../widgets/color_palette_widget.dart';

/// Main game board screen with pixel art canvas and color palette
class GameBoardScreen extends ConsumerWidget {
  /// Margin for screen size calculations
  static const double _screenMarginHorizontal = 100.0;
  static const double _screenMarginVertical = 300.0;
  
  /// Pixel size constraints
  static const double _minPixelSize = 10.0;
  static const double _maxPixelSize = 40.0;

  const GameBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixelData = ref.watch(pixelArtDataProvider);
    final selectedColor = ref.watch(selectedColorProvider);
    final completion = pixelData.completionPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Board'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Completion percentage
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${(completion * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Clear button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear all',
            onPressed: () {
              ref.read(pixelArtDataProvider.notifier).clearAll();
            },
          ),
          // Test large grid button
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'large') {
                ref.read(pixelArtDataProvider.notifier).loadLargeGrid();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'large',
                child: Text('Load 256x256 Grid (Hard)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (completion > 0 && completion < 1)
            LinearProgressIndicator(
              value: completion,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          // Completion message
          if (pixelData.isComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.green.shade100,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Puzzle Complete! 🎉',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          // Instructions
          if (selectedColor == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              color: Colors.blue.shade50,
              child: const Text(
                'Select a color from the palette below to start painting',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          // Grid info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Grid Size: ${pixelData.width}x${pixelData.height} (${pixelData.width * pixelData.height} pixels)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          // Pixel board
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: Center(
                child: PixelBoardWidget(
                  pixelData: pixelData,
                  selectedColor: selectedColor,
                  onPixelTap: (x, y) {
                    if (selectedColor != null) {
                      ref
                          .read(pixelArtDataProvider.notifier)
                          .fillPixel(x, y, selectedColor);
                    }
                  },
                  initialPixelSize: _calculatePixelSize(
                    pixelData.width,
                    pixelData.height,
                    MediaQuery.of(context).size,
                  ),
                ),
              ),
            ),
          ),
          // Color palette
          ColorPaletteWidget(
            colorToNumber: pixelData.colorToNumber,
            selectedColor: selectedColor,
            onColorSelected: (color) {
              ref.read(selectedColorProvider.notifier).state = color;
            },
          ),
        ],
      ),
    );
  }

  /// Calculate appropriate pixel size based on screen size
  double _calculatePixelSize(int width, int height, Size screenSize) {
    final availableWidth = screenSize.width - _screenMarginHorizontal;
    final availableHeight = screenSize.height - _screenMarginVertical;

    final pixelSizeByWidth = availableWidth / width;
    final pixelSizeByHeight = availableHeight / height;

    return (pixelSizeByWidth < pixelSizeByHeight
            ? pixelSizeByWidth
            : pixelSizeByHeight)
        .clamp(_minPixelSize, _maxPixelSize);
  }
}
