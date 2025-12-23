# PixelZen AI - Color-by-Number

A color-by-number coloring game for Android and iOS with AI-powered image generation.

## Features

- 🎨 **AI Generation**: Generate custom color-by-number puzzles using OpenAI DALL-E 3
  - Choose from 8 art styles (Fantasy, Space, Nature, Abstract, Animals, Architecture, Food, Underwater)
  - 3 difficulty levels (49x49, 96x96, 256x256)
  - K-Means color quantization to 32 colors
  - Custom prompts supported
- 🎮 **Game Board**: Interactive color-by-number gameplay
  - High-performance rendering for large grids (up to 256x256)
  - Zoom and pan with InteractiveViewer
  - Progress tracking and completion detection
- 🖼️ **Gallery**: View and manage your completed artworks

## Architecture

This project follows **Feature-First Clean Architecture** with the following structure:

```
lib/
├── main.dart
└── src/
    ├── core/              # Shared utilities, constants, and resources
    └── features/
        ├── ai_generation/ # AI-powered puzzle generation
        ├── game_board/    # Game board and gameplay logic
        └── gallery/       # Gallery of completed artworks
```

## Tech Stack

- **State Management**: Riverpod (with code generation)
- **Routing**: GoRouter
- **Local Storage**: Hive
- **Networking**: Dio
- **Image Processing**: image package

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ConjureGanja/pixelart-color-by-number.git
cd pixelart-color-by-number
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation (for Riverpod, Freezed, etc.):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running the App

```bash
flutter run
```

### AI Generation Setup

To use the AI generation feature, you need an OpenAI API key:

1. Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. Update the API key in `lib/src/features/ai_generation/screens/generation_screen.dart`:
   ```dart
   const apiKey = 'YOUR_OPENAI_API_KEY';
   ```

For production, use secure storage methods (environment variables, Flutter secure storage, etc.).

See [AI_GENERATION_IMPLEMENTATION.md](AI_GENERATION_IMPLEMENTATION.md) for detailed documentation.

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## Development

### Code Generation

When you add new providers, models, or serialization code, run:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

This will watch for changes and automatically regenerate code.

### Linting

The project uses `flutter_lints` for code quality. Run:

```bash
flutter analyze
```

## License

This project is licensed under the MIT License.
