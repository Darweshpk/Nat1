import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nativechat/models/llm_provider.dart';
import 'package:nativechat/ai/function_declarations.dart';
import 'package:nativechat/ai/system_prompt.dart';

class LLMService {
  final Dio _dio = Dio();
  late LLMProvider currentProvider;
  GenerativeModel? _geminiModel;

  LLMService({required this.currentProvider}) {
    _initializeProvider();
  }

  void _initializeProvider() {
    if (currentProvider.type == LLMProviderType.gemini) {
      _initializeGemini();
    }
    
    // Configure Dio for other providers
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    
    if (currentProvider.apiKey != null) {
      switch (currentProvider.type) {
        case LLMProviderType.openai:
        case LLMProviderType.groq:
        case LLMProviderType.together:
          _dio.options.headers['Authorization'] = 'Bearer ${currentProvider.apiKey}';
          break;
        case LLMProviderType.anthropic:
          _dio.options.headers['x-api-key'] = currentProvider.apiKey;
          _dio.options.headers['anthropic-version'] = '2023-06-01';
          break;
        case LLMProviderType.huggingface:
          _dio.options.headers['Authorization'] = 'Bearer ${currentProvider.apiKey}';
          break;
        case LLMProviderType.openrouter:
          _dio.options.headers['Authorization'] = 'Bearer ${currentProvider.apiKey}';
          _dio.options.headers['HTTP-Referer'] = 'https://nativechat.app';
          _dio.options.headers['X-Title'] = 'NativeChat';
          break;
        case LLMProviderType.replicate:
          _dio.options.headers['Authorization'] = 'Token ${currentProvider.apiKey}';
          break;
        default:
          break;
      }
    }
  }

  void _initializeGemini() {
    if (currentProvider.apiKey != null) {
      _geminiModel = GenerativeModel(
        model: currentProvider.model,
        apiKey: currentProvider.apiKey!,
        generationConfig: GenerationConfig(
          temperature: currentProvider.temperature,
          maxOutputTokens: currentProvider.maxTokens,
          responseMimeType: 'text/plain',
        ),
        systemInstruction: Content('system', [TextPart(systemPrompt)]),
        tools: [Tool(functionDeclarations: functionDeclarations)],
        toolConfig: ToolConfig(
          functionCallingConfig: FunctionCallingConfig(
            mode: FunctionCallingMode.auto,
          ),
        ),
      );
    }
  }

  // Stream chat response for different providers
  Stream<String> streamChatResponse({
    required String message,
    required List<Map<String, dynamic>> chatHistory,
    Uint8List? imageBytes,
    String? imageMime,
    Uint8List? fileBytes,
    String? fileMime,
  }) async* {
    switch (currentProvider.type) {
      case LLMProviderType.gemini:
        yield* _streamGeminiResponse(
          message: message,
          chatHistory: chatHistory,
          imageBytes: imageBytes,
          imageMime: imageMime,
          fileBytes: fileBytes,
          fileMime: fileMime,
        );
        break;
      case LLMProviderType.openai:
      case LLMProviderType.groq:
      case LLMProviderType.together:
        yield* _streamOpenAICompatibleResponse(
          message: message,
          chatHistory: chatHistory,
          imageBytes: imageBytes,
          imageMime: imageMime,
        );
        break;
      case LLMProviderType.anthropic:
        yield* _streamAnthropicResponse(
          message: message,
          chatHistory: chatHistory,
          imageBytes: imageBytes,
          imageMime: imageMime,
        );
        break;
      case LLMProviderType.huggingface:
        yield* _streamHuggingFaceResponse(
          message: message,
          chatHistory: chatHistory,
        );
        break;
      case LLMProviderType.openrouter:
        yield* _streamOpenRouterResponse(
          message: message,
          chatHistory: chatHistory,
          imageBytes: imageBytes,
          imageMime: imageMime,
        );
        break;
      case LLMProviderType.replicate:
        yield* _streamReplicateResponse(
          message: message,
          chatHistory: chatHistory,
        );
        break;
    }
  }

  // Gemini streaming (existing functionality)
  Stream<String> _streamGeminiResponse({
    required String message,
    required List<Map<String, dynamic>> chatHistory,
    Uint8List? imageBytes,
    String? imageMime,
    Uint8List? fileBytes,
    String? fileMime,
  }) async* {
    if (_geminiModel == null) return;

    final List<Content> chatHistoryContent = chatHistory
        .map<Content>((msg) => Content.text(msg['content'] as String))
        .toList();

    Content content;
    if ((imageBytes != null || fileBytes != null)) {
      Uint8List attachmentData = fileBytes ?? imageBytes!;
      String attachmentMime = fileMime ?? imageMime!;
      
      content = Content.multi([
        TextPart(message),
        DataPart(attachmentMime, attachmentData),
      ]);
    } else {
      content = Content.text(message);
    }

    try {
      final chat = _geminiModel!.startChat(history: chatHistoryContent);
      final stream = chat.sendMessageStream(content);
      
      await for (final response in stream) {
        if (response.text != null && response.text!.isNotEmpty) {
          yield response.text!;
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  // OpenAI/Groq/Together compatible streaming
  Stream<String> _streamOpenAICompatibleResponse({
    required String message,
    required List<Map<String, dynamic>> chatHistory,
    Uint8List? imageBytes,
    String? imageMime,
  }) async* {
    try {
      final messages = _buildOpenAIMessages(chatHistory, message, imageBytes, imageMime);
      
      final response = await _dio.post(
        '${currentProvider.baseUrl}/chat/completions',
        data: {
          'model': currentProvider.model,
          'messages': messages,
          'stream': true,
          'max_tokens': currentProvider.maxTokens,
          'temperature': currentProvider.temperature,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      await for (final chunk in response.data.stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            
            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  // Anthropic Claude streaming
  Stream<String> _streamAnthropicResponse({
    required String message,
    required List<Map<String, dynamic>> chatHistory,
    Uint8List? imageBytes,
    String? imageMime,
  }) async* {
    try {
      final messages = _buildAnthropicMessages(chatHistory, message, imageBytes, imageMime);
      
      final response = await _dio.post(
        '${currentProvider.baseUrl}/v1/messages',
        data: {
          'model': currentProvider.model,
          'max_tokens': currentProvider.maxTokens,
          'messages': messages,
          'stream': true,
          'system': systemPrompt,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      await for (final chunk in response.data.stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            
            try {
              final json = jsonDecode(data);
              if (json['type'] == 'content_block_delta') {
                final content = json['delta']?['text'];
                if (content != null) {
                  yield content;
                }
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  // Hugging Face streaming
  Stream<String> _streamHuggingFaceResponse({
    required String message,
    required List<Map<String, dynamic>> chatHistory,
  }) async* {
    try {
      final prompt = _buildHuggingFacePrompt(chatHistory, message);
      
      final response = await _dio.post(
        '${currentProvider.baseUrl}/models/${currentProvider.model}',
        data: {
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': currentProvider.maxTokens,
            'temperature': currentProvider.temperature,
            'stream': true,
          },
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      await for (final chunk in response.data.stream) {
        final data = utf8.decode(chunk);
        try {
          final json = jsonDecode(data);
          if (json is List && json.isNotEmpty) {
            final content = json[0]['generated_text'];
            if (content != null) {
              // Extract only the new part after the prompt
              final newContent = content.toString().replaceFirst(prompt, '').trim();
              if (newContent.isNotEmpty) {
                yield newContent;
              }
            }
          }
        } catch (e) {
          // Skip invalid JSON
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  // OpenRouter streaming
  Stream<String> _streamOpenRouterResponse({
    required String message,
    required List<Map<String, dynamic>> chatHistory,
    Uint8List? imageBytes,
    String? imageMime,
  }) async* {
    yield* _streamOpenAICompatibleResponse(
      message: message,
      chatHistory: chatHistory,
      imageBytes: imageBytes,
      imageMime: imageMime,
    );
  }

  // Replicate streaming (simplified)
  Stream<String> _streamReplicateResponse({
    required String message,
    required List<Map<String, dynamic>> chatHistory,
  }) async* {
    try {
      final prompt = _buildSimplePrompt(chatHistory, message);
      
      final response = await _dio.post(
        '${currentProvider.baseUrl}/predictions',
        data: {
          'version': currentProvider.model,
          'input': {
            'prompt': prompt,
            'max_tokens': currentProvider.maxTokens,
            'temperature': currentProvider.temperature,
          },
        },
      );

      final predictionUrl = response.data['urls']['get'];
      
      // Poll for completion (simplified)
      while (true) {
        await Future.delayed(Duration(seconds: 1));
        final statusResponse = await _dio.get(predictionUrl);
        final status = statusResponse.data['status'];
        
        if (status == 'succeeded') {
          final output = statusResponse.data['output'];
          if (output != null) {
            yield output.join('');
          }
          break;
        } else if (status == 'failed') {
          yield 'Error: Prediction failed';
          break;
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  // Helper methods for building messages
  List<Map<String, dynamic>> _buildOpenAIMessages(
    List<Map<String, dynamic>> chatHistory,
    String message,
    Uint8List? imageBytes,
    String? imageMime,
  ) {
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt}
    ];
    
    for (final msg in chatHistory) {
      messages.add({
        'role': msg['from'] == 'user' ? 'user' : 'assistant',
        'content': msg['content'],
      });
    }
    
    if (imageBytes != null && imageMime != null) {
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': message},
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:$imageMime;base64,${base64Encode(imageBytes)}'
            }
          }
        ]
      });
    } else {
      messages.add({'role': 'user', 'content': message});
    }
    
    return messages;
  }

  List<Map<String, dynamic>> _buildAnthropicMessages(
    List<Map<String, dynamic>> chatHistory,
    String message,
    Uint8List? imageBytes,
    String? imageMime,
  ) {
    final messages = <Map<String, dynamic>>[];
    
    for (final msg in chatHistory) {
      messages.add({
        'role': msg['from'] == 'user' ? 'user' : 'assistant',
        'content': msg['content'],
      });
    }
    
    if (imageBytes != null && imageMime != null) {
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': message},
          {
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': imageMime,
              'data': base64Encode(imageBytes),
            }
          }
        ]
      });
    } else {
      messages.add({'role': 'user', 'content': message});
    }
    
    return messages;
  }

  String _buildHuggingFacePrompt(
    List<Map<String, dynamic>> chatHistory,
    String message,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(systemPrompt);
    buffer.writeln();
    
    for (final msg in chatHistory) {
      if (msg['from'] == 'user') {
        buffer.writeln('Human: ${msg['content']}');
      } else {
        buffer.writeln('Assistant: ${msg['content']}');
      }
    }
    
    buffer.writeln('Human: $message');
    buffer.write('Assistant: ');
    
    return buffer.toString();
  }

  String _buildSimplePrompt(
    List<Map<String, dynamic>> chatHistory,
    String message,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(systemPrompt);
    buffer.writeln();
    
    for (final msg in chatHistory) {
      buffer.writeln('${msg['from'] == 'user' ? 'User' : 'Assistant'}: ${msg['content']}');
    }
    
    buffer.writeln('User: $message');
    
    return buffer.toString();
  }

  // Update provider
  void updateProvider(LLMProvider provider) {
    currentProvider = provider;
    _initializeProvider();
  }
}