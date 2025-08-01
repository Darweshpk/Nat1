import 'package:flutter/material.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/services/llm_service.dart';
import 'package:theme_provider/theme_provider.dart';

class ModelComparisonView extends StatefulWidget {
  final List<LLMProvider> selectedProviders;
  final String prompt;
  
  const ModelComparisonView({
    Key? key,
    required this.selectedProviders,
    required this.prompt,
  }) : super(key: key);

  @override
  State<ModelComparisonView> createState() => _ModelComparisonViewState();
}

class _ModelComparisonViewState extends State<ModelComparisonView> {
  Map<String, String> responses = {};
  Map<String, bool> isLoading = {};
  Map<String, String> errors = {};

  @override
  void initState() {
    super.initState();
    _generateResponses();
  }

  void _generateResponses() async {
    for (final provider in widget.selectedProviders) {
      setState(() {
        isLoading[provider.id] = true;
        responses[provider.id] = '';
        errors[provider.id] = '';
      });

      try {
        final service = LLMService(currentProvider: provider);
        String accumulatedResponse = '';
        
        await for (final chunk in service.streamChatResponse(
          message: widget.prompt,
          chatHistory: [],
        )) {
          accumulatedResponse += chunk;
          setState(() {
            responses[provider.id] = accumulatedResponse;
          });
        }
      } catch (e) {
        setState(() {
          errors[provider.id] = e.toString();
        });
      } finally {
        setState(() {
          isLoading[provider.id] = false;
        });
      }
    }
  }

  Widget _buildProviderResponse(LLMProvider provider) {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    final isLoadingProvider = isLoading[provider.id] ?? false;
    final response = responses[provider.id] ?? '';
    final error = errors[provider.id] ?? '';

    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xff1a1a1a) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xff2a2a2a) : Colors.grey[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
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
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        provider.model,
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
              ],
            ),
          ),
          // Response content
          Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(minHeight: 200),
            child: isLoadingProvider
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Generating response...',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                : error.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error: $error',
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : response.isEmpty
                        ? Center(
                            child: Text(
                              'No response generated',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          )
                        : SelectableText(
                            response,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              height: 1.5,
                            ),
                          ),
          ),
        ],
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
        title: Text('Model Comparison'),
        backgroundColor: isDark ? Color(0xff0a0a0a) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              _generateResponses();
            },
            icon: Icon(Icons.refresh),
            tooltip: 'Regenerate responses',
          ),
        ],
      ),
      backgroundColor: isDark ? Color(0xff0a0a0a) : Colors.grey[100],
      body: Column(
        children: [
          // Prompt display
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xff1a1a1a) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prompt:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.prompt,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Responses
          Expanded(
            child: widget.selectedProviders.length <= 2
                ? Row(
                    children: widget.selectedProviders
                        .map((provider) => Expanded(
                              child: _buildProviderResponse(provider),
                            ))
                        .toList(),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: widget.selectedProviders.length,
                    itemBuilder: (context, index) {
                      return _buildProviderResponse(widget.selectedProviders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}