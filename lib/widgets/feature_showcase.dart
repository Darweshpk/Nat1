import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nativechat/utils/app_theme.dart';

class FeatureShowcase extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const FeatureShowcase({Key? key, this.onGetStarted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildWelcomeHeader(isDark),
            const SizedBox(height: 24),
            ..._buildFeatureCards(isDark),
            const SizedBox(height: 24),
            _buildGetStartedButton(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to NativeChat',
            style: AppTheme.headingLarge.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your Advanced AI Assistant',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureCards(bool isDark) {
    final features = [
      {
        'icon': Icons.psychology,
        'title': 'Multi-AI Support',
        'description': '8+ AI providers including Gemini, GPT-4o, Claude',
        'gradient': const LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryDark]),
      },
      {
        'icon': Icons.mic,
        'title': 'Voice Interaction',
        'description': 'Hands-free conversation with speech-to-text',
        'gradient': const LinearGradient(colors: [AppTheme.accentGreen, Color(0xff2d7d32)]),
      },
      {
        'icon': Icons.phone_android,
        'title': 'Device Integration',
        'description': 'Access calls, SMS, apps, and system info',
        'gradient': const LinearGradient(colors: [AppTheme.accentOrange, Color(0xffe65100)]),
      },
      {
        'icon': Icons.image,
        'title': 'Multimodal AI',
        'description': 'Process images, files, and documents',
        'gradient': const LinearGradient(colors: [AppTheme.accentYellow, Color(0xfff57f17)]),
      },
    ];

    return features.map((feature) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: feature['gradient'] as LinearGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature['title'] as String,
                    style: AppTheme.headingSmall.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['description'] as String,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )).toList();
  }

  Widget _buildGetStartedButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onGetStarted,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat, size: 20),
              const SizedBox(width: 8),
              Text(
                'Start Chatting',
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}