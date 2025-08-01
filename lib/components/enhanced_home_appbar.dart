import 'package:flutter/material.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/widgets/ai_provider_selector.dart';
import 'package:nativechat/utils/app_theme.dart';
import 'package:nativechat/constants/app_constants.dart';

class EnhancedHomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback openDrawer;
  final VoidCallback creatSession;
  final VoidCallback clearConversation;
  final LLMProvider? currentProvider;
  final Function(LLMProvider) onProviderChanged;

  const EnhancedHomeAppbar({
    Key? key,
    required this.openDrawer,
    required this.creatSession,
    required this.clearConversation,
    required this.currentProvider,
    required this.onProviderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppTheme.darkGrey : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black,
      leading: IconButton(
        onPressed: openDrawer,
        icon: const Icon(Icons.menu),
        tooltip: 'Chat History',
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: AppTheme.headingSmall.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (currentProvider != null)
                Text(
                  currentProvider!.name,
                  style: AppTheme.caption.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        // AI Provider Quick Switch
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology,
              color: AppTheme.primaryBlue,
              size: 18,
            ),
          ),
          tooltip: 'Switch AI Provider',
          onSelected: (value) {
            if (value == 'manage_providers') {
              _showProviderSelector(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'manage_providers',
              child: Row(
                children: [
                  const Icon(Icons.tune, size: 18),
                  const SizedBox(width: 8),
                  const Text('Manage Providers'),
                ],
              ),
            ),
          ],
        ),
        
        // More Options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'new_chat':
                creatSession();
                break;
              case 'clear_chat':
                _showClearChatDialog(context);
                break;
              case 'settings':
                Navigator.pushNamed(context, '/settings');
                break;
              case 'about':
                _showAboutDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'new_chat',
              child: Row(
                children: [
                  Icon(Icons.add_comment, size: 18),
                  SizedBox(width: 8),
                  Text('New Chat'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_chat',
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 18),
                  SizedBox(width: 8),
                  Text('Clear Chat'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 18),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18),
                  SizedBox(width: 8),
                  Text('About'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showProviderSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            AIProviderSelector(
              providers: LLMProvider.getDefaultProviders(),
              currentProvider: currentProvider,
              onProviderSelected: (provider) {
                onProviderChanged(provider);
                Navigator.pop(context);
              },
              showOnlyConfigured: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear the current conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              clearConversation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.psychology,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(AppConstants.appDescription),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Multi-AI Provider Support'),
        const Text('• Voice Interaction'),
        const Text('• Device Integration'),
        const Text('• Multimodal Capabilities'),
        const Text('• Memory System'),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}