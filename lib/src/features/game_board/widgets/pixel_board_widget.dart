import 'package:flutter/material.dart';
import '../models/pixel_art_data.dart';
import 'pixel_board_painter.dart';

/// Interactive pixel board widget with zoom and pan support
/// Wraps the CustomPainter in an InteractiveViewer for performance
class PixelBoardWidget extends StatefulWidget {
  final PixelArtData pixelData;
  final Color? selectedColor;
  final Function(int x, int y)? onPixelTap;
  final double initialPixelSize;

  const PixelBoardWidget({
    super.key,
    required this.pixelData,
    this.selectedColor,
    this.onPixelTap,
    this.initialPixelSize = 20.0,
  });

  @override
  State<PixelBoardWidget> createState() => _PixelBoardWidgetState();
}

class _PixelBoardWidgetState extends State<PixelBoardWidget> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardWidth = widget.pixelData.width * widget.initialPixelSize;
    final boardHeight = widget.pixelData.height * widget.initialPixelSize;

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 10.0,
      boundaryMargin: const EdgeInsets.all(100),
      onInteractionUpdate: (details) {
        final newScale =
            _transformationController.value.getMaxScaleOnAxis();
        final bool showGridBefore = _currentScale > 0.7;
        final bool showGridAfter = newScale > 0.7;
        if (showGridBefore != showGridAfter) {
          setState(() {
            _currentScale = newScale;
          });
        } else {
          _currentScale = newScale;
        }
      },
      child: GestureDetector(
        onTapDown: (details) {
          if (widget.onPixelTap != null && widget.selectedColor != null) {
            _handleTap(details.localPosition);
          }
        },
        child: CustomPaint(
          size: Size(boardWidth, boardHeight),
          painter: PixelBoardPainter(
            pixelData: widget.pixelData,
            pixelSize: widget.initialPixelSize,
            showNumbers: true,
            showGrid: _currentScale > 0.7,
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset localPosition) {
    final x = (localPosition.dx / widget.initialPixelSize).floor();
    final y = (localPosition.dy / widget.initialPixelSize).floor();

    if (x >= 0 &&
        x < widget.pixelData.width &&
        y >= 0 &&
        y < widget.pixelData.height) {
      widget.onPixelTap?.call(x, y);
    }
  }
}
