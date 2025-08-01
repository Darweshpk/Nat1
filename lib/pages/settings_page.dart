import 'package:flutter/material.dart';
import 'package:nativechat/components/settings_components/dark_mode_toggle_button.dart';
import 'package:nativechat/components/settings_components/memories_buttons.dart';
import 'package:nativechat/components/settings_components/one_sided_chat_toggle_button.dart';
import 'package:nativechat/state/is_one_sided_chat_mode_notifier.dart';
import 'package:nativechat/services/llm_manager.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/components/llm_provider_selector.dart';
import 'package:theme_provider/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var isOneSidedChatModeNotifier = IsOneSidedChatModeNotifier();
  LLMProvider? currentProvider;
  List<LLMProvider> providers = [];

  @override
  void initState() {
    super.initState();
    isOneSidedChatModeNotifier.getIsOneSidedMode();
    _loadLLMInfo();
  }

  void _loadLLMInfo() async {
    await LLMManager.instance.initialize();
    setState(() {
      currentProvider = LLMManager.instance.currentProvider;
      providers = LLMManager.instance.providers;
    });
  }

  void _showProviderSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LLMProviderSelector(
        selectedProvider: currentProvider,
        onProviderSelected: (provider) async {
          await LLMManager.instance.setCurrentProvider(provider);
          _loadLLMInfo();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Switched to ${provider.name}')),
          );
        },
      ),
    );
  }

  void _showApiKeyDialog(LLMProvider provider) {
    final controller = TextEditingController(text: provider.apiKey ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${provider.name} API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your API key for ${provider.name}:'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter API key...',
                border: OutlineInputBorder(),
              ),
            ),
            if (provider.isFree) 
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'This model is FREE to use!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await LLMManager.instance.updateProviderApiKey(
                provider.id, 
                controller.text.trim()
              );
              _loadLLMInfo();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('API key updated for ${provider.name}')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        children: [
          Row(
            spacing: 10.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [DarkModeToggleButton(), OneSidedChatToggleButton()],
          ),
          SizedBox(height: 10.0),
          Row(
            spacing: 10.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MemoriesButtons(),
            ],
          ),
        ],
      ),
    );
  }
}
