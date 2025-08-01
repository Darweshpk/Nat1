# Changelog

All notable changes to NativeChat will be documented in this file.

## [Unreleased] - 2025-08-01

### 🔧 Fixed
- **Critical Build Issue**: Updated `flutter_sms_inbox` from v1.0.3 to v1.0.4
  - Fixed Flutter v2 embedding compatibility issue
  - Resolved compilation errors during APK build
  - Updated Android Gradle Plugin support

### 🚀 Improved
- **Dependencies Updated**:
  - `permission_handler`: ^11.4.0 → ^12.0.1
  - `flutter_sms_inbox`: ^1.0.3 → ^1.0.4
  - Android Gradle Plugin: 8.1.0 → 8.3.1
  - Kotlin version: 1.8.22 → 1.9.22

### 🔧 Configuration Updates
- **Android Configuration**:
  - Set explicit `minSdk = 21` for better compatibility
  - Fixed duplicate permission in AndroidManifest.xml
  - Updated Gradle wrapper and build tools

### 📚 Documentation
- Added comprehensive `BUILD.md` with setup instructions
- Enhanced build troubleshooting guide
- Added testing and deployment documentation

### 🧹 Code Quality
- Cleaned up duplicate permissions in manifest
- Improved project structure for better maintainability
- Optimized build configuration for faster compilation

## Previous Versions

### [1.8.0] - Previous Release
- Initial app functionality
- Gemini integration
- Voice mode implementation
- System information features
- SMS and call log analysis

---

### Legend
- 🚀 **Improved**: Enhancements and performance improvements
- 🔧 **Fixed**: Bug fixes and issue resolutions
- ➕ **Added**: New features and capabilities
- ⚠️ **Deprecated**: Features marked for removal
- 🗑️ **Removed**: Deleted features or dependencies
- 📚 **Documentation**: Documentation updates
- 🧹 **Code Quality**: Code improvements and refactoring