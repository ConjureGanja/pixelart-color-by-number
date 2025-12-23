# PixelZen AI - Color-by-Number

A color-by-number coloring game for Android and iOS with AI-powered image generation.

## Features

- 🎨 **AI Generation**: Generate custom color-by-number puzzles using AI
- 🎮 **Game Board**: Interactive color-by-number gameplay
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
