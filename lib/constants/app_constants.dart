// App Constants
class AppConstants {
  // App Information
  static const String appName = 'NativeChat';
  static const String appVersion = '1.8.1';
  static const String appBuildNumber = '18';
  static const String appDescription = 'Advanced AI-powered mobile assistant';
  
  // URLs
  static const String appWebsite = 'https://nativechat.ai';
  static const String githubRepo = 'https://github.com/nativechat/nativechat';
  static const String supportEmail = 'support@nativechat.ai';
  
  // API Endpoints
  static const String redditApiBase = 'https://www.reddit.com/r';
  
  // Storage Keys
  static const String chatSessionBox = 'chat_session';
  static const String settingsBox = 'settings';
  static const String memoriesBox = 'memories';
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double elevation = 4.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Colors
  static const int primaryBlue = 0xff4285f4;
  static const int primaryDark = 0xff1a73e8;
  static const int darkGrey = 0xff0a0a0a;
  static const int lightGrey = 0xfff5f7fa;
  static const int accentGreen = 0xff34a853;
  static const int accentRed = 0xffea4335;
  static const int accentYellow = 0xfffbbc04;
  
  // File Size Limits (in bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10 MB
  static const int maxFileSize = 50 * 1024 * 1024;  // 50 MB
  static const int maxAudioSize = 25 * 1024 * 1024; // 25 MB
  
  // Chat Configuration
  static const int maxChatHistory = 100;
  static const int maxMemories = 50;
  static const int maxMessageLength = 4000;
  
  // Voice Configuration
  static const double speechRate = 0.5;
  static const double speechPitch = 1.0;
  static const double speechVolume = 0.8;
  
  // Default Prompts
  static const List<String> welcomePrompts = [
    "What can you tell me about my device?",
    "Show me my recent calls and messages",
    "What's trending on Reddit today?",
    "Help me with coding questions",
    "Analyze my phone's battery usage",
    "Get me the latest tech news",
  ];
  
  // Supported File Types
  static const List<String> supportedImageTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'
  ];
  
  static const List<String> supportedDocumentTypes = [
    'pdf', 'doc', 'docx', 'txt', 'rtf', 'csv'
  ];
  
  static const List<String> supportedAudioTypes = [
    'mp3', 'm4a', 'wav', 'aac'
  ];
  
  // Feature Flags
  static const bool enableVoiceMode = true;
  static const bool enableMemorySystem = true;
  static const bool enableRedditIntegration = true;
  static const bool enableLocationServices = true;
  static const bool enableFileSharing = true;
  
  // Performance Constants
  static const int streamChunkSize = 1024;
  static const int maxConcurrentRequests = 3;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration streamTimeout = Duration(seconds: 60);
}