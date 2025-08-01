import 'package:flutter/material.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/utils/app_theme.dart';

class AIProviderSelector extends StatelessWidget {
  final List<LLMProvider> providers;
  final LLMProvider? currentProvider;
  final Function(LLMProvider) onProviderSelected;
  final bool showOnlyConfigured;

  const AIProviderSelector({
    Key? key,
    required this.providers,
    required this.currentProvider,
    required this.onProviderSelected,
    this.showOnlyConfigured = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableProviders = showOnlyConfigured 
        ? providers.where((p) => p.isFree || (p.apiKey?.isNotEmpty ?? false)).toList()
        : providers;

    return Container(
      decoration: AppTheme.cardDecoration(isDark),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'AI Provider',
                style: AppTheme.headingSmall.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableProviders.map((provider) {
              final isSelected = currentProvider?.id == provider.id;
              final isConfigured = provider.isFree || (provider.apiKey?.isNotEmpty ?? false);
              
              return GestureDetector(
                onTap: isConfigured ? () => onProviderSelected(provider) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryBlue
                        : (isDark ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryBlue
                          : (isConfigured ? Colors.transparent : Colors.grey),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getProviderIcon(provider.type, isSelected),
                      const SizedBox(width: 6),
                      Text(
                        provider.name,
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (provider.isFree) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'FREE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (!isConfigured) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.lock,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (currentProvider != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[900] : Colors.grey[50])?.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      currentProvider!.description ?? 'Current AI model: ${currentProvider!.model}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getProviderIcon(LLMProviderType type, bool isSelected) {
    Color iconColor = isSelected ? Colors.white : AppTheme.primaryBlue;
    
    switch (type) {
      case LLMProviderType.gemini:
        return Icon(Icons.auto_awesome, size: 14, color: iconColor);
      case LLMProviderType.openai:
        return Icon(Icons.psychology, size: 14, color: iconColor);
      case LLMProviderType.anthropic:
        return Icon(Icons.smart_toy, size: 14, color: iconColor);
      case LLMProviderType.groq:
        return Icon(Icons.flash_on, size: 14, color: iconColor);
      case LLMProviderType.huggingface:
        return Icon(Icons.face, size: 14, color: iconColor);
      case LLMProviderType.openrouter:
        return Icon(Icons.route, size: 14, color: iconColor);
      case LLMProviderType.together:
        return Icon(Icons.group_work, size: 14, color: iconColor);
      case LLMProviderType.replicate:
        return Icon(Icons.content_copy, size: 14, color: iconColor);
    }
  }
}