import 'package:flutter/material.dart';

/// Color palette widget for selecting colors to paint with
class ColorPaletteWidget extends StatelessWidget {
  final Map<Color, int> colorToNumber;
  final Color? selectedColor;
  final Function(Color) onColorSelected;

  const ColorPaletteWidget({
    super.key,
    required this.colorToNumber,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = colorToNumber.keys.toList()
      ..sort((a, b) => colorToNumber[a]!.compareTo(colorToNumber[b]!));

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: colors.map((color) {
            final number = colorToNumber[color]!;
            final isSelected = selectedColor == color;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _ColorButton(
                color: color,
                number: number,
                isSelected: isSelected,
                onTap: () => onColorSelected(color),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              color: _getContrastColor(color),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
