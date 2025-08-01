import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nativechat/widgets/feature_showcase.dart';
import 'package:nativechat/utils/app_theme.dart';
import 'package:nativechat/constants/app_constants.dart';

class PromptSuggestionsFeed extends StatelessWidget {
  final VoidCallback chatWithAI;
  final TextEditingController userMessageController;

  const PromptSuggestionsFeed({
    Key? key,
    required this.chatWithAI,
    required this.userMessageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FeatureShowcase(
              onGetStarted: () {
                userMessageController.text = "Hello! What can you help me with?";
                chatWithAI();
              },
            ),
            const SizedBox(height: 24),
            _buildSuggestionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Try these examples:',
              style: AppTheme.headingSmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: AppConstants.welcomePrompts.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSuggestionCard(entry.value, _getPromptIcon(entry.key)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String prompt, IconData icon) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return InkWell(
          onTap: () {
            userMessageController.text = prompt;
            chatWithAI();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(isDark).copyWith(
              border: Border.all(
                color: (isDark ? Colors.grey[800] : Colors.grey[200])!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    prompt,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getPromptIcon(int index) {
    const icons = [
      Icons.phone_android,    // Device info
      Icons.message,          // Calls & messages
      Icons.trending_up,      // Reddit trending
      Icons.code,             // Coding help
      Icons.battery_std,      // Battery usage
      Icons.newspaper,        // Tech news
    ];
    
    return icons[index % icons.length];
  }
}