# 🎵 Beatify

A modern, dark-themed music player for Android built with Flutter. Beatify provides a beautiful and intuitive interface for managing your music library with features like album organization, playlist management, and a sleek dark UI.

## ✨ Features

- 🎨 **Modern Dark Theme** - Beautiful dark UI with glassmorphism effects
- 📱 **Android Optimized** - Built specifically for Android with MediaStore integration
- 🎵 **Music Library** - Scan and organize your music collection
- 📀 **Album Management** - Create custom albums and organize your music
- 🎧 **Audio Player** - Full-featured music player with mini player
- 🔍 **Search & Filter** - Find your music quickly
- 🎯 **Real-time Updates** - Changes sync across all screens instantly

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Android SDK
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/beatify.git
   cd beatify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Build & Deploy

### Local Build
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```


## 🛠️ Project Structure

```
lib/
├── core/                 # Core functionality
│   ├── di/              # Dependency injection
│   └── theme/           # App theming
├── data/                # Data layer
│   └── repositories/    # Repository implementations
├── domain/              # Domain layer
│   ├── entities/        # Data models
│   └── repositories/    # Repository interfaces
├── features/            # Feature modules
│   ├── album/           # Album management
│   ├── home/            # Home screen
│   ├── library/         # Music library
│   ├── player/          # Audio player
│   ├── root/            # Navigation
│   └── settings/        # App settings
├── services/            # Core services
└── widgets/             # Reusable widgets
```

## 🎨 Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Audio**: just_audio
- **Icons**: Phosphor Icons
- **Storage**: SharedPreferences
- **Architecture**: Clean Architecture + Domain-Driven Design

## 📱 Screenshots

*Coming soon...*

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- just_audio for audio playback capabilities
- Phosphor Icons for beautiful icons
- All contributors and testers

---

Made with ❤️ and Flutter
