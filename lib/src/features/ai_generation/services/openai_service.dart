import 'package:dio/dio.dart';
import 'dart:typed_data';

/// Service for interacting with OpenAI DALL-E 3 API
class OpenAIService {
  final Dio _dio;
  final String apiKey;

  OpenAIService({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
  }

  /// Generate an image using DALL-E 3
  /// 
  /// [prompt] - Text description of the image to generate
  /// [size] - Image size (1024x1024, 1792x1024, or 1024x1792)
  /// [quality] - Image quality ('standard' or 'hd')
  Future<Uint8List> generateImage({
    required String prompt,
    String size = '1024x1024',
    String quality = 'standard',
  }) async {
    try {
      // Call DALL-E 3 API
      final response = await _dio.post(
        '/images/generations',
        data: {
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': size,
          'quality': quality,
          'response_format': 'url',
        },
      );

      // Extract image URL from response
      final imageUrl = response.data['data'][0]['url'] as String;

      // Download the image
      final imageResponse = await _dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      return Uint8List.fromList(imageResponse.data!);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'];
        throw Exception('OpenAI API Error: ${error['message']}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to generate image: $e');
    }
  }

  /// Validate API key by making a test request
  Future<bool> validateApiKey() async {
    try {
      await _dio.get('/models');
      return true;
    } catch (e) {
      return false;
    }
  }
}
