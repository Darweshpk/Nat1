import 'package:flutter/material.dart';
import 'package:nativechat/components/model_comparison_view.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/services/llm_manager.dart';
import 'package:theme_provider/theme_provider.dart';

class ModelComparisonSetup extends StatefulWidget {
  const ModelComparisonSetup({Key? key}) : super(key: key);

  @override
  State<ModelComparisonSetup> createState() => _ModelComparisonSetupState();
}

class _ModelComparisonSetupState extends State<ModelComparisonSetup> {
  TextEditingController promptController = TextEditingController();
  List<LLMProvider> selectedProviders = [];
  List<LLMProvider> availableProviders = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableProviders();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  void _loadAvailableProviders() {
    availableProviders = LLMManager.instance.getAvailableProviders();
    setState(() {});
  }

  void _toggleProvider(LLMProvider provider) {
    setState(() {
      if (selectedProviders.contains(provider)) {
        selectedProviders.remove(provider);
      } else {
        if (selectedProviders.length < 4) {
          selectedProviders.add(provider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum 4 models can be compared at once')),
          );
        }
      }
    });
  }

  void _startComparison() {
    if (selectedProviders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one model')),
      );
      return;
    }

    if (promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModelComparisonView(
          selectedProviders: selectedProviders,
          prompt: promptController.text.trim(),
        ),
      ),
    );
  }

  Widget _buildProviderCard(LLMProvider provider) {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    final isSelected = selectedProviders.contains(provider);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected 
          ? (isDark ? Colors.blue.shade800 : Colors.blue.shade100)
          : (isDark ? Color(0xff1a1a1a) : Colors.white),
      child: ListTile(
        leading: _getProviderIcon(provider.type),
        title: Row(
          children: [
            Expanded(
              child: Text(
                provider.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (provider.isFree)
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
        subtitle: Text(
          provider.model,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: Colors.blue)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: () => _toggleProvider(provider),
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
        title: Text('Compare AI Models'),
        backgroundColor: isDark ? Color(0xff0a0a0a) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      backgroundColor: isDark ? Color(0xff0a0a0a) : Colors.grey[100],
      body: Column(
        children: [
          // Prompt input
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xff1a1a1a) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your prompt:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: promptController,
                  maxLines: 4,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'e.g., "Explain quantum computing in simple terms"',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? Color(0xff2a2a2a) : Colors.grey[50],
                  ),
                ),
              ],
            ),
          ),
          
          // Selected models count
          if (selectedProviders.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${selectedProviders.length} model${selectedProviders.length == 1 ? '' : 's'} selected (max 4)',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),

          // Model selection
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Select models to compare:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: availableProviders.isEmpty
                      ? Center(
                          child: Text(
                            'No models available. Please configure API keys first.',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: availableProviders.length,
                          itemBuilder: (context, index) {
                            return _buildProviderCard(availableProviders[index]);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Compare button
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedProviders.isNotEmpty && promptController.text.trim().isNotEmpty
                  ? _startComparison
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.compare_arrows),
                  SizedBox(width: 8),
                  Text(
                    'Compare Models',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}