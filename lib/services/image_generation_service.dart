import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class ImageGenerationService {
  static ImageGenerationService? _instance;
  static ImageGenerationService get instance => _instance ??= ImageGenerationService._();
  
  ImageGenerationService._();

  final Dio _dio = Dio();
  
  // Multiple free image generation APIs
  final Map<String, Map<String, String>> _providers = {
    'fal_flux': {
      'name': 'Flux (Fal.ai)',
      'url': 'https://fal.run/fal-ai/flux/dev',
      'free': 'true',
    },
    'fal_sd': {
      'name': 'Stable Diffusion (Fal.ai)', 
      'url': 'https://fal.run/fal-ai/stable-diffusion-v3-medium',
      'free': 'true',
    },
    'replicate_flux': {
      'name': 'Flux (Replicate)',
      'url': 'https://api.replicate.com/v1/predictions',
      'free': 'limited',
    },
    'huggingface': {
      'name': 'Stable Diffusion (HF)',
      'url': 'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-dev',
      'free': 'true',
    },
  };

  // Get available providers
  List<Map<String, String>> getProviders() {
    return _providers.entries.map((e) => {
      'id': e.key,
      ...e.value,
    }).toList();
  }

  // Generate image using selected provider
  Future<Map<String, dynamic>> generateImage({
    required String prompt,
    String provider = 'huggingface',
    Map<String, dynamic>? options,
  }) async {
    try {
      switch (provider) {
        case 'fal_flux':
          return await _generateWithFal(prompt, 'fal-ai/flux/dev', options);
        case 'fal_sd':
          return await _generateWithFal(prompt, 'fal-ai/stable-diffusion-v3-medium', options);
        case 'replicate_flux':
          return await _generateWithReplicate(prompt, options);
        case 'huggingface':
        default:
          return await _generateWithHuggingFace(prompt, options);
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Hugging Face (Free)
  Future<Map<String, dynamic>> _generateWithHuggingFace(
    String prompt, 
    Map<String, dynamic>? options
  ) async {
    try {
      final response = await _dio.post(
        'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-dev',
        data: {
          'inputs': prompt,
          'options': {
            'wait_for_model': true,
            'use_cache': false,
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final imageBytes = Uint8List.fromList(response.data);
        return {
          'success': true,
          'imageBytes': imageBytes,
          'provider': 'Hugging Face',
          'model': 'FLUX.1-dev',
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'HuggingFace error: $e',
      };
    }
  }

  // Fal.ai (Free tier available)
  Future<Map<String, dynamic>> _generateWithFal(
    String prompt, 
    String model,
    Map<String, dynamic>? options
  ) async {
    try {
      // Get API key from storage
      Box settingsBox = await Hive.openBox("settings");
      final falApiKey = settingsBox.get("fal_api_key", defaultValue: "");
      await settingsBox.close();

      if (falApiKey.isEmpty) {
        return {
          'success': false,
          'error': 'Fal.ai API key required. Get free key from fal.ai/dashboard/keys',
          'needsApiKey': true,
        };
      }

      final response = await _dio.post(
        'https://fal.run/$model',
        data: {
          'prompt': prompt,
          'image_size': options?['size'] ?? 'square_hd',
          'num_inference_steps': options?['steps'] ?? 28,
          'guidance_scale': options?['guidance'] ?? 3.5,
          'num_images': 1,
          'enable_safety_checker': true,
        },
        options: Options(
          headers: {
            'Authorization': 'key $falApiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['images'] != null && data['images'].isNotEmpty) {
          final imageUrl = data['images'][0]['url'];
          
          // Download the image
          final imageResponse = await _dio.get(
            imageUrl,
            options: Options(responseType: ResponseType.bytes),
          );
          
          return {
            'success': true,
            'imageBytes': Uint8List.fromList(imageResponse.data),
            'imageUrl': imageUrl,
            'provider': 'Fal.ai',
            'model': model,
          };
        }
      }
      
      return {
        'success': false,
        'error': 'No image generated',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Fal.ai error: $e',
      };
    }
  }

  // Replicate (Limited free tier)
  Future<Map<String, dynamic>> _generateWithReplicate(
    String prompt,
    Map<String, dynamic>? options
  ) async {
    try {
      Box settingsBox = await Hive.openBox("settings");
      final replicateApiKey = settingsBox.get("replicate_api_key", defaultValue: "");
      await settingsBox.close();

      if (replicateApiKey.isEmpty) {
        return {
          'success': false,
          'error': 'Replicate API key required',
          'needsApiKey': true,
        };
      }

      final response = await _dio.post(
        'https://api.replicate.com/v1/predictions',
        data: {
          'version': 'black-forest-labs/flux-schnell',
          'input': {
            'prompt': prompt,
            'num_outputs': 1,
            'aspect_ratio': options?['aspect_ratio'] ?? '1:1',
            'output_format': 'webp',
            'output_quality': 80,
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Token $replicateApiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        final predictionId = response.data['id'];
        
        // Poll for completion
        for (int i = 0; i < 30; i++) {
          await Future.delayed(Duration(seconds: 2));
          
          final statusResponse = await _dio.get(
            'https://api.replicate.com/v1/predictions/$predictionId',
            options: Options(
              headers: {
                'Authorization': 'Token $replicateApiKey',
              },
            ),
          );
          
          final status = statusResponse.data['status'];
          if (status == 'succeeded') {
            final imageUrl = statusResponse.data['output'][0];
            
            // Download image
            final imageResponse = await _dio.get(
              imageUrl,
              options: Options(responseType: ResponseType.bytes),
            );
            
            return {
              'success': true,
              'imageBytes': Uint8List.fromList(imageResponse.data),
              'imageUrl': imageUrl,
              'provider': 'Replicate',
              'model': 'Flux Schnell',
            };
          } else if (status == 'failed') {
            return {
              'success': false,
              'error': 'Generation failed',
            };
          }
        }
        
        return {
          'success': false,
          'error': 'Generation timeout',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to start generation',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Replicate error: $e',
      };
    }
  }

  // Save API keys
  Future<void> saveApiKey(String provider, String apiKey) async {
    Box settingsBox = await Hive.openBox("settings");
    
    switch (provider) {
      case 'fal':
        await settingsBox.put("fal_api_key", apiKey);
        break;
      case 'replicate':
        await settingsBox.put("replicate_api_key", apiKey);
        break;
    }
    
    await settingsBox.close();
  }

  // Get saved API keys status
  Future<Map<String, bool>> getApiKeyStatus() async {
    Box settingsBox = await Hive.openBox("settings");
    
    final status = {
      'fal': (settingsBox.get("fal_api_key", defaultValue: "") as String).isNotEmpty,
      'replicate': (settingsBox.get("replicate_api_key", defaultValue: "") as String).isNotEmpty,
    };
    
    await settingsBox.close();
    return status;
  }
}