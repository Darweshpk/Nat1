// Global constants for NativeChat application
class Constants {
  // App Metadata
  static const String appName = 'NativeChat';
  static const String appVersion = '1.8.1';
  static const String appBuildNumber = '18';
  static const String appDescription = 'Advanced AI-powered mobile assistant with multi-provider support';
  static const String appPackageName = 'com.nativechat.ai';
  
  // URLs and Links
  static const String appWebsite = 'https://nativechat.ai';
  static const String githubRepo = 'https://github.com/nativechat/nativechat';
  static const String supportEmail = 'support@nativechat.ai';
  static const String privacyPolicy = 'https://nativechat.ai/privacy';
  static const String termsOfService = 'https://nativechat.ai/terms';
  
  // API Configuration
  static const String apiVersion = 'v1';
  static const int apiTimeout = 30; // seconds
  static const int maxRetries = 3;
  static const int maxConcurrentRequests = 5;
  
  // Storage Keys
  static const String settingsBox = 'settings';
  static const String chatSessionBox = 'chat_session';
  static const String memoriesBox = 'memories';
  static const String providersBox = 'llm_providers';
  static const String cacheBox = 'cache';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  static const double defaultElevation = 4.0;
  static const double smallElevation = 2.0;
  static const double largeElevation = 8.0;
  
  // Animation Durations
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 300;
  static const int longAnimationMs = 500;
  static const int extraLongAnimationMs = 800;
  
  // File Size Limits (bytes)
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxFileSizeBytes = 50 * 1024 * 1024;  // 50 MB
  static const int maxAudioSizeBytes = 25 * 1024 * 1024; // 25 MB
  static const int maxVideoSizeBytes = 100 * 1024 * 1024; // 100 MB
  
  // Chat Configuration
  static const int maxChatHistoryLength = 100;
  static const int maxMemoriesCount = 50;
  static const int maxMessageLength = 4000;
  static const int maxAttachmentsPerMessage = 5;
  
  // Voice Configuration
  static const double defaultSpeechRate = 0.5;
  static const double defaultSpeechPitch = 1.0;
  static const double defaultSpeechVolume = 0.8;
  static const int voiceTimeoutSeconds = 30;
  
  // Network Configuration
  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;
  
  // Supported File Extensions
  static const List<String> supportedImageExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'
  ];
  
  static const List<String> supportedDocumentExtensions = [
    'pdf', 'doc', 'docx', 'txt', 'rtf', 'csv', 'xlsx', 'xls', 'ppt', 'pptx'
  ];
  
  static const List<String> supportedAudioExtensions = [
    'mp3', 'm4a', 'wav', 'aac', 'ogg', 'flac'
  ];
  
  static const List<String> supportedVideoExtensions = [
    'mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', '3gp'
  ];
  
  // Feature Flags
  static const bool enableVoiceMode = true;
  static const bool enableMemorySystem = true;
  static const bool enableRedditIntegration = true;
  static const bool enableLocationServices = true;
  static const bool enableFileSharing = true;
  static const bool enableMultipleProviders = true;
  static const bool enableAnalytics = false; // Privacy-focused
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  
  // Default Prompts and Suggestions
  static const List<String> defaultWelcomePrompts = [
    "What can you tell me about my device?",
    "Show me my recent calls and messages",
    "What's trending on Reddit today?",
    "Help me with coding questions",
    "Analyze my phone's battery usage",
    "Get me the latest tech news",
    "Generate some creative content",
    "Explain a complex topic simply",
  ];
  
  // Theme Configuration
  static const List<String> availableThemes = ['light', 'dark', 'system'];
  static const String defaultTheme = 'dark';
  
  // Language Configuration
  static const List<String> supportedLanguages = [
    'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'ar', 'hi', 'ur'
  ];
  static const String defaultLanguage = 'en';
  
  // Performance Thresholds
  static const int maxMemoryUsageMB = 200;
  static const int maxCpuUsagePercent = 80;
  static const int maxBatteryUsagePercent = 5;
  static const double minFrameRate = 30.0;
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String apiKeyErrorMessage = 'API key is required for this provider.';
  static const String permissionErrorMessage = 'Permission is required for this feature.';
  
  // Success Messages
  static const String chatClearedMessage = 'Chat history cleared successfully.';
  static const String apiKeySavedMessage = 'API key saved successfully.';
  static const String settingsSavedMessage = 'Settings saved successfully.';
  static const String memorySavedMessage = 'Memory saved successfully.';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String urlPattern = r'https?://[^\s/$.?#].[^\s]*';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]+$';
  
  // API Key Patterns
  static const String geminiApiKeyPattern = r'^AIza[0-9A-Za-z-_]{35}$';
  static const String openaiApiKeyPattern = r'^sk-[a-zA-Z0-9]{48}$';
  static const String anthropicApiKeyPattern = r'^sk-ant-[a-zA-Z0-9\-_]{95}$';
  
  // Keyboard Shortcuts (for future desktop support)
  static const Map<String, String> keyboardShortcuts = {
    'new_chat': 'Ctrl+N',
    'clear_chat': 'Ctrl+L',
    'toggle_voice': 'Ctrl+M',
    'send_message': 'Enter',
    'multiline_message': 'Shift+Enter',
  };
  
  // Social Media Links
  static const String twitterUrl = 'https://twitter.com/nativechat';
  static const String linkedinUrl = 'https://linkedin.com/company/nativechat';
  static const String discordUrl = 'https://discord.gg/nativechat';
  static const String telegramUrl = 'https://t.me/nativechat';
  
  // Development Configuration
  static const bool isDevelopment = false;
  static const bool enableDebugMode = false;
  static const bool enableVerboseLogging = false;
  static const bool enableNetworkLogging = false;
  
  // Cache Configuration
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
  static const int cacheExpirationHours = 24;
  static const int maxCacheEntries = 1000;
  
  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerHour = 1000;
  static const int maxRequestsPerDay = 10000;
  
  // Accessibility
  static const double minTouchTargetSize = 44.0;
  static const double maxTextScaleFactor = 2.0;
  static const double minTextScaleFactor = 0.8;
  
  // Security
  static const int sessionTimeoutMinutes = 60;
  static const int maxLoginAttempts = 5;
  static const int passwordMinLength = 8;
  static const bool requireBiometricAuth = false;
}

// Enums for better type safety
enum AppTheme { light, dark, system }
enum AppLanguage { english, spanish, french, german, italian, portuguese, russian, chinese, japanese, korean, arabic, hindi, urdu }
enum MessageType { text, image, file, audio, video, system }
enum ConnectionStatus { connected, disconnected, connecting, error }
enum ProviderStatus { active, inactive, error, configuring }

// Extension methods for enums
extension AppThemeExtension on AppTheme {
  String get name {
    switch (this) {
      case AppTheme.light: return 'light';
      case AppTheme.dark: return 'dark';
      case AppTheme.system: return 'system';
    }
  }
}