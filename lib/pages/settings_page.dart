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
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
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
          // AI Model Selection Section
          Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'AI Model',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (currentProvider != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xff1a1a1a) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentProvider!.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (currentProvider!.isFree)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'FREE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentProvider!.model,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (currentProvider!.description != null) ...[
                            SizedBox(height: 4),
                            Text(
                              currentProvider!.description!,
                              style: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showProviderSelector,
                            icon: Icon(Icons.swap_horiz),
                            label: Text('Change Model'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        if (!currentProvider!.isFree)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showApiKeyDialog(currentProvider!),
                              icon: Icon(Icons.key),
                              label: Text('API Key'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (currentProvider!.apiKey?.isNotEmpty ?? false) 
                                    ? Colors.green 
                                    : Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Available Models Summary
          Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Available Models',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildProviderChip('🤖 Gemini', 'Google AI', Colors.blue),
                      _buildProviderChip('⚡ Groq', 'Ultra Fast & Free', Colors.yellow),
                      _buildProviderChip('🤗 HuggingFace', 'Open Source & Free', Colors.purple),
                      _buildProviderChip('🔥 OpenAI', 'GPT-4o/Mini', Colors.green),
                      _buildProviderChip('🧠 Claude', 'Anthropic', Colors.orange),
                      _buildProviderChip('🔀 OpenRouter', 'All Models', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // App Settings
          Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'App Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    spacing: 10.0,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: DarkModeToggleButton()), 
                      Expanded(child: OneSidedChatToggleButton())
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Memory Management
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.memory, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Memory Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  MemoriesButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderChip(String name, String description, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
