import 'package:hive/hive.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/services/llm_service.dart';

class LLMManager {
  static LLMManager? _instance;
  static LLMManager get instance => _instance ??= LLMManager._();
  
  LLMManager._();

  LLMProvider? _currentProvider;
  LLMService? _currentService;
  List<LLMProvider> _providers = [];

  LLMProvider? get currentProvider => _currentProvider;
  LLMService? get currentService => _currentService;
  List<LLMProvider> get providers => _providers;

  Future<void> initialize() async {
    await _loadProviders();
    await _loadCurrentProvider();
  }

  Future<void> _loadProviders() async {
    Box settingsBox = await Hive.openBox("settings");
    
    final savedProviders = settingsBox.get("llm_providers", defaultValue: <LLMProvider>[]);
    
    if (savedProviders.isEmpty) {
      _providers = LLMProvider.getDefaultProviders();
      await settingsBox.put("llm_providers", _providers);
    } else {
      _providers = List<LLMProvider>.from(savedProviders);
    }
    
    await settingsBox.close();
  }

  Future<void> _loadCurrentProvider() async {
    Box settingsBox = await Hive.openBox("settings");
    
    final currentProviderId = settingsBox.get("current_provider_id", defaultValue: "gemini-2.0-flash");
    
    // Find the provider
    _currentProvider = _providers.firstWhere(
      (p) => p.id == currentProviderId,
      orElse: () => _providers.first,
    );
    
    // Set up the service
    if (_currentProvider != null) {
      _currentService = LLMService(currentProvider: _currentProvider!);
    }
    
    await settingsBox.close();
  }

  Future<void> setCurrentProvider(LLMProvider provider) async {
    _currentProvider = provider;
    _currentService = LLMService(currentProvider: provider);
    
    // Save to storage
    Box settingsBox = await Hive.openBox("settings");
    await settingsBox.put("current_provider_id", provider.id);
    await settingsBox.close();
  }

  Future<void> updateProviderApiKey(String providerId, String apiKey) async {
    // Find and update the provider
    final providerIndex = _providers.indexWhere((p) => p.id == providerId);
    if (providerIndex != -1) {
      _providers[providerIndex].apiKey = apiKey.trim().isEmpty ? null : apiKey.trim();
      
      // Save to storage
      Box settingsBox = await Hive.openBox("settings");
      await settingsBox.put("llm_providers", _providers);
      await settingsBox.close();
      
      // Update current service if this is the current provider
      if (_currentProvider?.id == providerId) {
        _currentService?.updateProvider(_providers[providerIndex]);
      }
    }
  }

  List<LLMProvider> getAvailableProviders() {
    return _providers.where((provider) {
      // Free providers are always available
      if (provider.isFree) return true;
      
      // Paid providers need API keys
      return provider.apiKey != null && provider.apiKey!.isNotEmpty;
    }).toList();
  }

  List<LLMProvider> getFreeProviders() {
    return _providers.where((provider) => provider.isFree).toList();
  }

  List<LLMProvider> getProvidersByType(LLMProviderType type) {
    return _providers.where((provider) => provider.type == type).toList();
  }

  bool isProviderConfigured(String providerId) {
    final provider = _providers.firstWhere(
      (p) => p.id == providerId,
      orElse: () => throw Exception('Provider not found'),
    );
    
    return provider.isFree || (provider.apiKey != null && provider.apiKey!.isNotEmpty);
  }

  Future<void> addCustomProvider(LLMProvider provider) async {
    _providers.add(provider);
    
    Box settingsBox = await Hive.openBox("settings");
    await settingsBox.put("llm_providers", _providers);
    await settingsBox.close();
  }

  Future<void> removeProvider(String providerId) async {
    _providers.removeWhere((p) => p.id == providerId);
    
    Box settingsBox = await Hive.openBox("settings");
    await settingsBox.put("llm_providers", _providers);
    
    // If this was the current provider, switch to default
    if (_currentProvider?.id == providerId) {
      await setCurrentProvider(_providers.first);
    }
    
    await settingsBox.close();
  }

  // Get provider statistics
  Map<String, dynamic> getProviderStats() {
    final totalProviders = _providers.length;
    final freeProviders = _providers.where((p) => p.isFree).length;
    final configuredProviders = _providers.where((p) => 
      p.isFree || (p.apiKey != null && p.apiKey!.isNotEmpty)
    ).length;
    
    final providersByType = Map<String, int>();
    for (final provider in _providers) {
      final type = provider.type.name;
      providersByType[type] = (providersByType[type] ?? 0) + 1;
    }
    
    return {
      'total': totalProviders,
      'free': freeProviders,
      'configured': configuredProviders,
      'byType': providersByType,
    };
  }
}