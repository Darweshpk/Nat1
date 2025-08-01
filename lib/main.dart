import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nativechat/models/chat_session.dart';
import 'package:nativechat/models/settings.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/services/llm_manager.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/enhanced_homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(ChatSessionModelAdapter());
  Hive.registerAdapter(LLMProviderTypeAdapter());
  Hive.registerAdapter(LLMProviderAdapter());
  
  // Initialize LLM Manager
  await LLMManager.instance.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: NativeChatApp()));
}

class NativeChatApp extends StatefulWidget {
  const NativeChatApp({super.key});

  @override
  State<NativeChatApp> createState() => _NativeChatAppState();
}

class _NativeChatAppState extends State<NativeChatApp> {
  ChatSessionModel? session;
  
  @override
  Widget build(BuildContext context) {
    const darkGreyColor = Color(0xff0a0a0a);
    const lightGreyColor = Color(0xfff5f7fa);
    const primaryBlue = Color(0xff4285f4);
    const primaryDark = Color(0xff1a73e8);

    return ThemeProvider(
      saveThemesOnChange: true,
      loadThemeOnInit: true,
      defaultThemeId: "dark_theme",
      themes: [
        // Light Theme
        AppTheme(
          id: "light_theme",
          description: "Light Theme",
          data: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: primaryBlue,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryBlue,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
            ),
            cardTheme: CardTheme(
              color: lightGreyColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        
        // Dark Theme
        AppTheme(
          id: "dark_theme",
          description: "Dark Theme",
          data: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: primaryDark,
            scaffoldBackgroundColor: darkGreyColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryDark,
              brightness: Brightness.dark,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: darkGreyColor,
              foregroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            cardTheme: CardTheme(
              color: const Color(0xff1a1a1a),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
              titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) => MaterialApp(
            title: 'NativeChat - AI Assistant',
            theme: ThemeProvider.themeOf(themeContext).data,
            debugShowCheckedModeBanner: false,
            initialRoute: "/",
            routes: {
              "/": (context) => EnhancedHomepage(session: session),
            },
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0), // Prevent font scaling issues
                ),
                child: child!,
              );
            },
          ),
        ),
      ),
    );
  }
}