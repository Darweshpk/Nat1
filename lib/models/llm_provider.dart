import 'package:hive/hive.dart';

part 'llm_provider.g.dart';

@HiveType(typeId: 2)
enum LLMProviderType {
  @HiveField(0)
  gemini,
  @HiveField(1)
  openai,
  @HiveField(2)
  anthropic,
  @HiveField(3)
  groq,
  @HiveField(4)
  huggingface,
  @HiveField(5)
  openrouter,
  @HiveField(6)
  together,
  @HiveField(7)
  replicate,
}

@HiveType(typeId: 3)
class LLMProvider extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  LLMProviderType type;

  @HiveField(3)
  String? apiKey;

  @HiveField(4)
  String model;

  @HiveField(5)
  String baseUrl;

  @HiveField(6)
  bool isEnabled;

  @HiveField(7)
  bool isFree;

  @HiveField(8)
  int? maxTokens;

  @HiveField(9)
  double? temperature;

  @HiveField(10)
  String? description;

  LLMProvider({
    required this.id,
    required this.name,
    required this.type,
    this.apiKey,
    required this.model,
    required this.baseUrl,
    this.isEnabled = true,
    this.isFree = false,
    this.maxTokens = 8192,
    this.temperature = 1.0,
    this.description,
  });

  // Predefined providers
  static List<LLMProvider> getDefaultProviders() {
    return [
      // Gemini (existing)
      LLMProvider(
        id: 'gemini-2.0-flash',
        name: 'Gemini 2.0 Flash',
        type: LLMProviderType.gemini,
        model: 'gemini-2.0-flash',
        baseUrl: 'https://generativelanguage.googleapis.com',
        description: 'Google\'s latest multimodal AI model',
      ),
      
      // OpenAI
      LLMProvider(
        id: 'gpt-4o',
        name: 'GPT-4o',
        type: LLMProviderType.openai,
        model: 'gpt-4o',
        baseUrl: 'https://api.openai.com/v1',
        description: 'OpenAI\'s latest multimodal model',
      ),
      LLMProvider(
        id: 'gpt-4o-mini',
        name: 'GPT-4o Mini',
        type: LLMProviderType.openai,
        model: 'gpt-4o-mini',
        baseUrl: 'https://api.openai.com/v1',
        description: 'Faster and cheaper GPT-4o variant',
      ),
      
      // Anthropic
      LLMProvider(
        id: 'claude-sonnet-4',
        name: 'Claude 4 Sonnet',
        type: LLMProviderType.anthropic,
        model: 'claude-sonnet-4-20250514',
        baseUrl: 'https://api.anthropic.com',
        description: 'Anthropic\'s most capable model',
      ),
      LLMProvider(
        id: 'claude-3-5-sonnet',
        name: 'Claude 3.5 Sonnet',
        type: LLMProviderType.anthropic,
        model: 'claude-3-5-sonnet-20241022',
        baseUrl: 'https://api.anthropic.com',
        description: 'Fast and capable Claude model',
      ),
      
      // Groq (Free & Fast)
      LLMProvider(
        id: 'groq-llama3-70b',
        name: 'Llama 3 70B (Groq)',
        type: LLMProviderType.groq,
        model: 'llama3-70b-8192',
        baseUrl: 'https://api.groq.com/openai/v1',
        isFree: true,
        description: 'Ultra-fast inference with Llama 3 70B',
      ),
      LLMProvider(
        id: 'groq-mixtral-8x7b',
        name: 'Mixtral 8x7B (Groq)',
        type: LLMProviderType.groq,
        model: 'mixtral-8x7b-32768',
        baseUrl: 'https://api.groq.com/openai/v1',
        isFree: true,
        description: 'Fast Mixtral model on Groq',
      ),
      
      // Hugging Face
      LLMProvider(
        id: 'hf-codellama-34b',
        name: 'CodeLlama 34B',
        type: LLMProviderType.huggingface,
        model: 'codellama/CodeLlama-34b-Instruct-hf',
        baseUrl: 'https://api-inference.huggingface.co',
        isFree: true,
        description: 'Code-specialized Llama model',
      ),
      LLMProvider(
        id: 'hf-mistral-7b',
        name: 'Mistral 7B',
        type: LLMProviderType.huggingface,
        model: 'mistralai/Mistral-7B-Instruct-v0.3',
        baseUrl: 'https://api-inference.huggingface.co',
        isFree: true,
        description: 'Efficient Mistral model',
      ),
      
      // OpenRouter (Access to multiple providers)
      LLMProvider(
        id: 'openrouter-gpt4-turbo',
        name: 'GPT-4 Turbo (OpenRouter)',
        type: LLMProviderType.openrouter,
        model: 'openai/gpt-4-turbo',
        baseUrl: 'https://openrouter.ai/api/v1',
        description: 'GPT-4 Turbo via OpenRouter',
      ),
      LLMProvider(
        id: 'openrouter-claude-opus',
        name: 'Claude Opus (OpenRouter)',
        type: LLMProviderType.openrouter,
        model: 'anthropic/claude-3-opus',
        baseUrl: 'https://openrouter.ai/api/v1',
        description: 'Claude Opus via OpenRouter',
      ),
      
      // Together AI (Free tier available)
      LLMProvider(
        id: 'together-llama2-70b',
        name: 'Llama 2 70B (Together)',
        type: LLMProviderType.together,
        model: 'meta-llama/Llama-2-70b-chat-hf',
        baseUrl: 'https://api.together.xyz/v1',
        isFree: true,
        description: 'Llama 2 70B on Together AI',
      ),
      
      // Replicate
      LLMProvider(
        id: 'replicate-llama2-13b',
        name: 'Llama 2 13B (Replicate)',
        type: LLMProviderType.replicate,
        model: 'meta/llama-2-13b-chat',
        baseUrl: 'https://api.replicate.com/v1',
        description: 'Llama 2 13B on Replicate',
      ),
    ];
  }
}