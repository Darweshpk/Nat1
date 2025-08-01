# Build Instructions for NativeChat

## Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code
- Android SDK (API level 21 or higher)
- Git

## Setup Steps

### 1. Clone Repository
```bash
git clone <repository-url>
cd nativechat
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Code Files
```bash
flutter packages pub run build_runner build
```

### 4. Run the App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

### 5. Build APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

### 6. Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Configuration

### API Keys Setup
Create a `.env` file in the root directory:
```
GEMINI_API_KEY=your_gemini_api_key_here
```

### Permissions
The app requires the following permissions:
- SMS access
- Call log access
- Location access
- Storage access
- Microphone access (for voice features)

## Troubleshooting

### Common Issues

1. **Plugin Compatibility**: Ensure all plugins are updated to latest versions
2. **Android SDK**: Minimum SDK version is 21
3. **Gradle Issues**: Clean build if encountering Gradle problems:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

### Build Errors
- Run `flutter doctor` to check for any configuration issues
- Ensure Android SDK and build tools are properly installed
- Check that all dependencies are compatible

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## Deployment

### Android
1. Build release APK or App Bundle
2. Sign the app with your keystore
3. Upload to Google Play Console

### iOS (if supported)
1. Build iOS app: `flutter build ios`
2. Open in Xcode for signing and deployment
3. Deploy via App Store Connect

## Support

For build issues or questions, please:
1. Check Flutter documentation
2. Review plugin documentation
3. Open an issue on GitHub repository