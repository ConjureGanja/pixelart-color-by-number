/// Difficulty levels for pixel art generation
enum Difficulty {
  easy(49, 'Easy (49x49)'),
  medium(96, 'Medium (96x96)'),
  hard(256, 'Hard (256x256)');

  const Difficulty(this.size, this.label);

  final int size;
  final String label;
}

/// Art styles for AI generation
enum ArtStyle {
  fantasy('Fantasy', 'fantasy, magical, mythical'),
  space('Space', 'space, cosmic, sci-fi, stars'),
  nature('Nature', 'nature, landscape, natural'),
  abstract('Abstract', 'abstract, geometric, modern'),
  animals('Animals', 'animals, wildlife, creatures'),
  architecture('Architecture', 'buildings, architecture, urban'),
  food('Food', 'food, cuisine, delicious'),
  underwater('Underwater', 'underwater, ocean, marine');

  const ArtStyle(this.label, this.prompt);

  final String label;
  final String prompt;
}

/// Generation parameters for AI pixel art
class GenerationParams {
  final ArtStyle style;
  final Difficulty difficulty;
  final String? customPrompt;

  const GenerationParams({
    required this.style,
    required this.difficulty,
    this.customPrompt,
  });

  /// Get the full prompt for AI generation
  String get fullPrompt {
    final basePrompt = customPrompt ?? style.prompt;
    return '$basePrompt, simple, clear, vibrant colors, suitable for pixel art';
  }

  GenerationParams copyWith({
    ArtStyle? style,
    Difficulty? difficulty,
    String? customPrompt,
  }) {
    return GenerationParams(
      style: style ?? this.style,
      difficulty: difficulty ?? this.difficulty,
      customPrompt: customPrompt ?? this.customPrompt,
    );
  }
}
