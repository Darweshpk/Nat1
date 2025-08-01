import 'package:flutter/material.dart';
import 'package:nativechat/services/llm_manager.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/utils/app_theme.dart';
import 'package:nativechat/components/api_keys_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class APIKeyInput extends StatefulWidget {
  final VoidCallback? getSettings;

  const APIKeyInput({Key? key, this.getSettings}) : super(key: key);

  @override
  State<APIKeyInput> createState() => _APIKeyInputState();
}

class _APIKeyInputState extends State<APIKeyInput> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;
  LLMProvider? currentProvider;

  @override
  void initState() {
    super.initState();
    _loadCurrentProvider();
  }

  void _loadCurrentProvider() {
    setState(() {
      currentProvider = LLMManager.instance.currentProvider;
      _apiKeyController.text = currentProvider?.apiKey ?? '';
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 16),
            _buildProviderInfo(isDark),
            const SizedBox(height: 16),
            _buildApiKeyInput(isDark),
            const SizedBox(height: 16),
            _buildActionButtons(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.key,
            color: AppTheme.accentRed,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Key Required',
                style: AppTheme.headingSmall.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                'Configure your AI provider to continue',
                style: AppTheme.caption.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderInfo(bool isDark) {
    if (currentProvider == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[900] : Colors.grey[100])?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _getProviderIcon(currentProvider!.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentProvider!.name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (currentProvider!.description != null)
                  Text(
                    currentProvider!.description!,
                    style: AppTheme.caption.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Key',
          style: AppTheme.bodyMedium.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _apiKeyController,
          obscureText: _isObscured,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: AppTheme.inputDecoration(
            label: 'Enter your ${currentProvider?.name} API key',
            hint: 'sk-...',
            isDark: isDark,
            prefixIcon: const Icon(Icons.vpn_key),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _saveApiKey,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save, color: AppTheme.accentGreen),
                ),
              ],
            ),
          ),
          onSubmitted: (_) => _saveApiKey(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openApiKeyUrl(),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Get API Key'),
            style: AppTheme.outlinedButtonStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openKeysManager(context),
            icon: const Icon(Icons.tune, size: 16),
            label: const Text('Manage All'),
            style: AppTheme.elevatedButtonStyle,
          ),
        ),
      ],
    );
  }

  Widget _getProviderIcon(LLMProviderType type) {
    switch (type) {
      case LLMProviderType.gemini:
        return const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue);
      case LLMProviderType.openai:
        return const Icon(Icons.psychology, color: AppTheme.accentGreen);
      case LLMProviderType.anthropic:
        return const Icon(Icons.smart_toy, color: AppTheme.accentOrange);
      case LLMProviderType.groq:
        return const Icon(Icons.flash_on, color: AppTheme.accentYellow);
      default:
        return const Icon(Icons.api, color: AppTheme.primaryBlue);
    }
  }

  void _saveApiKey() async {
    if (currentProvider == null || _apiKeyController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await LLMManager.instance.updateProviderApiKey(
        currentProvider!.id,
        _apiKeyController.text.trim(),
      );
      
      widget.getSettings?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API key saved for ${currentProvider!.name}'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving API key: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openApiKeyUrl() async {
    if (currentProvider == null) return;
    
    String url = '';
    switch (currentProvider!.type) {
      case LLMProviderType.gemini:
        url = 'https://aistudio.google.com/app/apikey';
        break;
      case LLMProviderType.openai:
        url = 'https://platform.openai.com/api-keys';
        break;
      case LLMProviderType.anthropic:
        url = 'https://console.anthropic.com/account/keys';
        break;
      case LLMProviderType.groq:
        url = 'https://console.groq.com/keys';
        break;
      default:
        return;
    }
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openKeysManager(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => APIKeysManager(
          onKeysUpdated: () {
            _loadCurrentProvider();
            widget.getSettings?.call();
          },
        ),
      ),
    );
  }
}