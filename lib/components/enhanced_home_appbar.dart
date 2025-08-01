import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nativechat/components/api_keys_manager.dart';
import 'package:nativechat/components/llm_provider_selector.dart';
import 'package:nativechat/components/model_comparison_setup.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:theme_provider/theme_provider.dart';

class EnhancedHomeAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Function openDrawer;
  final Function creatSession;
  final Function clearConversation;
  final LLMProvider? currentProvider;
  final Function(LLMProvider) onProviderChanged;

  const EnhancedHomeAppbar({
    Key? key,
    required this.openDrawer,
    required this.creatSession,
    required this.clearConversation,
    this.currentProvider,
    required this.onProviderChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<EnhancedHomeAppbar> createState() => _EnhancedHomeAppbarState();
}

class _EnhancedHomeAppbarState extends State<EnhancedHomeAppbar> {
  
  void _showProviderSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LLMProviderSelector(
        selectedProvider: widget.currentProvider,
        onProviderSelected: (provider) {
          Navigator.pop(context);
          widget.onProviderChanged(provider);
        },
      ),
    );
  }

  void _showAPIKeysManager() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => APIKeysManager(
          onKeysUpdated: () {
            // Refresh providers if needed
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildProviderButton() {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
    return GestureDetector(
      onTap: _showProviderSelector,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Color(0xff1a1a1a) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getProviderIcon(widget.currentProvider?.type ?? LLMProviderType.gemini),
            SizedBox(width: 8),
            Text(
              widget.currentProvider?.name ?? 'Select Model',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Icon _getProviderIcon(LLMProviderType type) {
    switch (type) {
      case LLMProviderType.gemini:
        return Icon(Icons.auto_awesome, color: Colors.blue, size: 16);
      case LLMProviderType.openai:
        return Icon(Icons.psychology, color: Colors.green, size: 16);
      case LLMProviderType.anthropic:
        return Icon(Icons.smart_toy, color: Colors.orange, size: 16);
      case LLMProviderType.groq:
        return Icon(Icons.flash_on, color: Colors.yellow, size: 16);
      case LLMProviderType.huggingface:
        return Icon(Icons.face, color: Colors.purple, size: 16);
      case LLMProviderType.openrouter:
        return Icon(Icons.route, color: Colors.red, size: 16);
      case LLMProviderType.together:
        return Icon(Icons.group_work, color: Colors.teal, size: 16);
      case LLMProviderType.replicate:
        return Icon(Icons.content_copy, color: Colors.indigo, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
    return AppBar(
      backgroundColor: isDark ? Color(0xff0a0a0a) : Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => widget.openDrawer(),
        icon: Icon(
          Icons.menu,
          color: isDark ? Colors.grey[500] : Colors.grey[700],
        ),
      ),
      title: _buildProviderButton(),
      centerTitle: true,
      actions: [
        // API Keys Manager
        IconButton(
          onPressed: _showAPIKeysManager,
          icon: Icon(
            Icons.key,
            color: isDark ? Colors.grey[500] : Colors.grey[700],
          ),
          tooltip: 'Manage API Keys',
        ),
        // More options
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Colors.grey[500] : Colors.grey[700],
          ),
          onSelected: (value) {
            switch (value) {
              case 'new_chat':
                widget.creatSession();
                break;
              case 'clear_chat':
                widget.clearConversation();
                break;
              case 'compare_mode':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModelComparisonSetup(),
                  ),
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'new_chat',
              child: Row(
                children: [
                  Icon(Icons.add_comment, size: 20),
                  SizedBox(width: 12),
                  Text('New Chat'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'clear_chat',
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 20),
                  SizedBox(width: 12),
                  Text('Clear Chat'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'compare_mode',
              child: Row(
                children: [
                  Icon(Icons.compare_arrows, size: 20),
                  SizedBox(width: 12),
                  Text('Compare Models'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}