import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/generation_params.dart';
import '../services/openai_service.dart';
import '../services/image_processor_service.dart';
import '../../game_board/providers/game_state_provider.dart';

/// Screen for generating AI pixel art
class GenerationScreen extends ConsumerStatefulWidget {
  const GenerationScreen({super.key});

  @override
  ConsumerState<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends ConsumerState<GenerationScreen> {
  ArtStyle _selectedStyle = ArtStyle.fantasy;
  Difficulty _selectedDifficulty = Difficulty.easy;
  final _customPromptController = TextEditingController();
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _customPromptController.dispose();
    super.dispose();
  }

  Future<void> _generatePixelArt() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final params = GenerationParams(
        style: _selectedStyle,
        difficulty: _selectedDifficulty,
        customPrompt: _customPromptController.text.trim().isEmpty
            ? null
            : _customPromptController.text.trim(),
      );

      // TODO: Get API key from secure storage or environment
      // For now, this is a placeholder - users need to provide their own key
      const apiKey = 'YOUR_OPENAI_API_KEY';

      if (apiKey == 'YOUR_OPENAI_API_KEY') {
        throw Exception(
          'Please configure your OpenAI API key. '
          'You can get one from https://platform.openai.com/api-keys',
        );
      }

      // Generate image with OpenAI DALL-E 3
      final openAIService = OpenAIService(apiKey: apiKey);
      final imageBytes = await openAIService.generateImage(
        prompt: params.fullPrompt,
        size: '1024x1024',
        quality: 'standard',
      );

      // Process image into pixel art
      final imageProcessor = ImageProcessorService();
      final pixelArtData = await imageProcessor.processImage(
        imageBytes: imageBytes,
        targetSize: _selectedDifficulty.size,
        maxColors: ImageProcessorService.maxPaletteColors,
      );

      // Load the generated puzzle
      ref.read(pixelArtDataProvider.notifier).loadNewPuzzle(pixelArtData);

      // Navigate to game board
      if (mounted) {
        context.go('/game-board');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Generation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Icon(
              Icons.auto_awesome,
              size: 64,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'Generate Pixel Art with AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create unique color-by-number puzzles using DALL-E 3',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Style selector
            const Text(
              'Art Style',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ArtStyle>(
              value: _selectedStyle,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.palette),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: ArtStyle.values.map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Text(style.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStyle = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Difficulty selector
            const Text(
              'Difficulty',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Difficulty>(
              value: _selectedDifficulty,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.grid_on),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: Difficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Custom prompt (optional)
            const Text(
              'Custom Prompt (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customPromptController,
              decoration: InputDecoration(
                hintText: 'e.g., A magical castle in the clouds',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Text(
              'Leave empty to use the selected style',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),

            // Generate button
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generatePixelArt,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isGenerating ? 'Generating...' : 'Generate Pixel Art',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. AI generates an image based on your selection\n'
                    '2. Image is resized to your chosen difficulty\n'
                    '3. Colors are reduced to 32 using K-Means clustering\n'
                    '4. Pixel art puzzle is created and ready to play!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
