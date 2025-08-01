import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:theme_provider/theme_provider.dart';

class LLMProviderSelector extends StatefulWidget {
  final LLMProvider? selectedProvider;
  final Function(LLMProvider) onProviderSelected;

  const LLMProviderSelector({
    Key? key,
    this.selectedProvider,
    required this.onProviderSelected,
  }) : super(key: key);

  @override
  State<LLMProviderSelector> createState() => _LLMProviderSelectorState();
}

class _LLMProviderSelectorState extends State<LLMProviderSelector> {
  List<LLMProvider> providers = [];
  List<LLMProvider> filteredProviders = [];
  TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProviders();
    searchController.addListener(_filterProviders);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _loadProviders() async {
    Box settingsBox = await Hive.openBox("settings");
    
    // Load default providers if not already saved
    final savedProviders = settingsBox.get("llm_providers", defaultValue: <LLMProvider>[]);
    
    if (savedProviders.isEmpty) {
      providers = LLMProvider.getDefaultProviders();
      await settingsBox.put("llm_providers", providers);
    } else {
      providers = List<LLMProvider>.from(savedProviders);
    }
    
    _filterProviders();
    await settingsBox.close();
  }

  void _filterProviders() {
    setState(() {
      filteredProviders = providers.where((provider) {
        final matchesSearch = provider.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
                            provider.model.toLowerCase().contains(searchController.text.toLowerCase());
        
        final matchesCategory = selectedCategory == 'All' ||
                               (selectedCategory == 'Free' && provider.isFree) ||
                               (selectedCategory == 'Paid' && !provider.isFree) ||
                               provider.type.name.toLowerCase() == selectedCategory.toLowerCase();
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Widget _buildProviderCard(LLMProvider provider) {
    final isSelected = widget.selectedProvider?.id == provider.id;
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.model,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            if (provider.description != null)
              Text(
                provider.description!,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: provider.apiKey != null && provider.apiKey!.isNotEmpty
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.key, color: Colors.orange),
        onTap: () => widget.onProviderSelected(provider),
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
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? Color(0xff0a0a0a) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select AI Model',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search models...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Color(0xff1a1a1a) : Colors.grey[100],
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                SizedBox(height: 16),
                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Free', 'Paid', 'Gemini', 'OpenAI', 'Anthropic', 'Groq', 'HuggingFace']
                        .map((category) => Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: selectedCategory == category,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                    _filterProviders();
                                  }
                                },
                                backgroundColor: isDark ? Color(0xff1a1a1a) : Colors.grey[200],
                                selectedColor: Colors.blue,
                                labelStyle: TextStyle(
                                  color: selectedCategory == category 
                                      ? Colors.white 
                                      : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          // Providers list
          Expanded(
            child: filteredProviders.isEmpty
                ? Center(
                    child: Text(
                      'No models found',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      return _buildProviderCard(filteredProviders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}