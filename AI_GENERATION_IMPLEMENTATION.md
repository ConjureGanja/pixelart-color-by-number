# AI Generation Feature Implementation

## Overview
The AI generation feature allows users to create custom pixel art puzzles using OpenAI's DALL-E 3 API. Images are automatically processed, downscaled, and color-quantized to create playable color-by-number puzzles.

## Workflow

### 1. User Input
- **Style Selection**: Choose from predefined styles (Fantasy, Space, Nature, Abstract, Animals, Architecture, Food, Underwater)
- **Difficulty Selection**: Choose grid size
  - Easy: 49x49 (2,401 pixels)
  - Medium: 96x96 (9,216 pixels)
  - Hard: 256x256 (65,536 pixels)
- **Custom Prompt** (Optional): Provide custom text description

### 2. AI Image Generation
- Uses OpenAI DALL-E 3 API to generate a 1024x1024 image
- Prompt is enhanced with "simple, clear, vibrant colors, suitable for pixel art"
- Image is downloaded as raw bytes

### 3. Image Processing Pipeline

The `ImageProcessorService` performs the following steps:

#### a. Downscaling
- Resizes the 1024x1024 image to the target difficulty size
- Uses average interpolation for smooth color transitions

#### b. Color Quantization (K-Means Clustering)
- Reduces the thousands of colors in the AI image to exactly 32 distinct colors
- Uses K-Means clustering algorithm:
  1. Initialize 32 random centroids from the image colors
  2. Assign each pixel to the nearest centroid (Euclidean distance in RGB space)
  3. Recalculate centroids as the average of assigned colors
  4. Repeat until convergence (max 10 iterations)

#### c. Palette Mapping
- Creates a map of Color → Number (1-32)
- Maps every pixel to the nearest palette color
- Generates `PixelArtData` structure ready for gameplay

### 4. Navigation
- Automatically loads the generated puzzle into the game board
- Navigates to `/game-board` route
- User can immediately start playing

## Architecture

```
lib/src/features/ai_generation/
├── ai_generation.dart              # Barrel file
├── models/
│   └── generation_params.dart      # Difficulty, ArtStyle, params
├── services/
│   ├── openai_service.dart         # DALL-E 3 API integration
│   └── image_processor_service.dart # Image processing & quantization
└── screens/
    └── generation_screen.dart      # UI for generation
```

## Key Components

### ImageProcessorService

The core service that converts AI images into pixel art:

```dart
Future<PixelArtData> processImage({
  required List<int> imageBytes,
  required int targetSize,
  int maxColors = 32,
}) async {
  // 1. Decode image
  // 2. Resize to target size
  // 3. Extract all colors
  // 4. Quantize using K-Means
  // 5. Create palette mapping
  // 6. Map pixels to palette
  // 7. Return PixelArtData
}
```

**K-Means Algorithm Details**:
- Fixed seed (42) for consistent results
- Euclidean distance in RGB space: `sqrt((r1-r2)² + (g1-g2)² + (b1-b2)²)`
- Maximum 10 iterations to balance quality and performance
- Early convergence detection (< 1.0 distance change)

### OpenAIService

Handles communication with OpenAI API:

```dart
Future<Uint8List> generateImage({
  required String prompt,
  String size = '1024x1024',
  String quality = 'standard',
}) async {
  // 1. Call DALL-E 3 API
  // 2. Get image URL from response
  // 3. Download image bytes
  // 4. Return as Uint8List
}
```

### GenerationScreen

User interface with:
- Style dropdown (8 options)
- Difficulty dropdown (3 options)
- Optional custom prompt text field
- Generate button with loading state
- Error handling and user feedback
- Info card explaining the process

## API Configuration

The OpenAI API key must be configured before use:

```dart
// In generation_screen.dart, update:
const apiKey = 'YOUR_OPENAI_API_KEY';

// For production, use secure storage:
// - Environment variables
// - Flutter secure storage
// - Cloud secrets manager
```

Get your API key from: https://platform.openai.com/api-keys

## Usage Example

```dart
// Generate pixel art
final params = GenerationParams(
  style: ArtStyle.fantasy,
  difficulty: Difficulty.medium,
  customPrompt: 'A magical castle in the clouds',
);

// Generate with AI
final openAI = OpenAIService(apiKey: apiKey);
final imageBytes = await openAI.generateImage(
  prompt: params.fullPrompt,
);

// Process into pixel art
final processor = ImageProcessorService();
final pixelArt = await processor.processImage(
  imageBytes: imageBytes,
  targetSize: params.difficulty.size,
  maxColors: 32,
);

// Load into game
gameStateNotifier.loadNewPuzzle(pixelArt);
```

## Performance

- Image download: ~2-5 seconds (depends on network)
- AI generation: ~10-30 seconds (OpenAI processing)
- Image processing:
  - 49x49: <100ms
  - 96x96: <300ms
  - 256x256: ~1-2 seconds
- K-Means clustering: Linear time O(n·k·i) where n=pixels, k=colors, i=iterations

## Error Handling

The system handles:
- Invalid API key
- Network errors
- Image decode failures
- API rate limits
- Malformed responses

All errors are displayed to the user with clear messages.

## Testing

Comprehensive tests included:
- Color quantization accuracy
- Different image sizes
- Single color images
- Invalid image data handling
- PixelArtData structure validation

Run tests:
```bash
flutter test test/features/ai_generation/
```

## Future Enhancements

1. **API Key Management**: Secure storage and user-provided keys
2. **Image Upload**: Allow users to upload their own images
3. **Preview**: Show AI-generated image before processing
4. **Caching**: Cache generated puzzles for reuse
5. **Custom Palettes**: Allow users to choose color palettes
6. **Progressive Processing**: Show progress during image processing
7. **Batch Generation**: Generate multiple puzzles at once
8. **Favorites**: Save favorite generated puzzles
