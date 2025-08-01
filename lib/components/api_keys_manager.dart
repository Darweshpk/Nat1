import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class APIKeysManager extends StatefulWidget {
  final Function? onKeysUpdated;

  const APIKeysManager({Key? key, this.onKeysUpdated}) : super(key: key);

  @override
  State<APIKeysManager> createState() => _APIKeysManagerState();
}

class _APIKeysManagerState extends State<APIKeysManager> {
  List<LLMProvider> providers = [];
  Map<String, TextEditingController> controllers = {};
  Map<String, bool> showKeys = {};

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _loadProviders() async {
    Box settingsBox = await Hive.openBox("settings");
    final savedProviders = settingsBox.get("llm_providers", defaultValue: <LLMProvider>[]);
    
    if (savedProviders.isEmpty) {
      providers = LLMProvider.getDefaultProviders();
      await settingsBox.put("llm_providers", providers);
    } else {
      providers = List<LLMProvider>.from(savedProviders);
    }

    // Initialize controllers
    for (final provider in providers) {
      controllers[provider.id] = TextEditingController(text: provider.apiKey ?? '');
      showKeys[provider.id] = false;
    }

    setState(() {});
    await settingsBox.close();
  }

  void _saveApiKey(String providerId, String apiKey) async {
    Box settingsBox = await Hive.openBox("settings");
    
    // Update provider
    final providerIndex = providers.indexWhere((p) => p.id == providerId);
    if (providerIndex != -1) {
      providers[providerIndex].apiKey = apiKey.trim().isEmpty ? null : apiKey.trim();
      await settingsBox.put("llm_providers", providers);
    }
    
    await settingsBox.close();
    widget.onKeysUpdated?.call();
  }

  void _launchProviderURL(LLMProviderType type) async {
    String url = '';
    switch (type) {
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
      case LLMProviderType.huggingface:
        url = 'https://huggingface.co/settings/tokens';
        break;
      case LLMProviderType.openrouter:
        url = 'https://openrouter.ai/keys';
        break;
      case LLMProviderType.together:
        url = 'https://api.together.xyz/settings/api-keys';
        break;
      case LLMProviderType.replicate:
        url = 'https://replicate.com/account/api-tokens';
        break;
    }
    
    if (url.isNotEmpty) {
      await launchUrl(Uri.parse(url));
    }
  }

  Widget _buildProviderCard(LLMProvider provider) {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    final controller = controllers[provider.id]!;
    final showKey = showKeys[provider.id] ?? false;
    
    return Card(
      margin: EdgeInsets.all(8),
      color: isDark ? Color(0xff1a1a1a) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getProviderIcon(provider.type),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        provider.type.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.isFree)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                if (!provider.isFree)
                  IconButton(
                    onPressed: () => _launchProviderURL(provider.type),
                    icon: Icon(Icons.open_in_new, color: Colors.blue),
                    tooltip: 'Get API Key',
                  ),
              ],
            ),
            if (!provider.isFree) ...[
              SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: !showKey,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your ${provider.name} API key',
                  border: OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showKeys[provider.id] = !showKey;
                          });
                        },
                        icon: Icon(showKey ? Icons.visibility_off : Icons.visibility),
                      ),
                      IconButton(
                        onPressed: () => _saveApiKey(provider.id, controller.text),
                        icon: Icon(Icons.save),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                onSubmitted: (value) => _saveApiKey(provider.id, value),
              ),
              if (provider.apiKey != null && provider.apiKey!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'API Key configured',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ] else ...[
              SizedBox(height: 8),
              Text(
                'This provider offers free access with rate limits.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Icon _getProviderIcon(LLMProviderType type) {
    switch (type) {
      case LLMProviderType.gemini:
        return Icon(Icons.auto_awesome, color: Colors.blue);
      case LLMProviderType.openai:
        return Icon(Icons.psychology, color: Colors.green);
      case LLMProviderType.anthropic:
        return Icon(Icons.smart_toy, color: Colors.orange);
      case LLMProviderType.groq:
        return Icon(Icons.flash_on, color: Colors.yellow);
      case LLMProviderType.huggingface:
        return Icon(Icons.face, color: Colors.purple);
      case LLMProviderType.openrouter:
        return Icon(Icons.route, color: Colors.red);
      case LLMProviderType.together:
        return Icon(Icons.group_work, color: Colors.teal);
      case LLMProviderType.replicate:
        return Icon(Icons.content_copy, color: Colors.indigo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
    return Scaffold(
      appBar: AppBar(
        title: Text('API Keys Manager'),
        backgroundColor: isDark ? Color(0xff0a0a0a) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      backgroundColor: isDark ? Color(0xff0a0a0a) : Colors.grey[100],
      body: providers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                return _buildProviderCard(providers[index]);
              },
            ),
    );
  }
}