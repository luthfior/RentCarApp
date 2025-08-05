import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SerpApiService {
  static final String _apiKey = dotenv.env['API_KEY'] ?? '';
  static const _baseUrl = 'https://serpapi.com/search.json';

  static Future<String?> fetchImageForCar(
    String nameProduct,
    String releaseProduct,
  ) async {
    try {
      final query = '$nameProduct $releaseProduct';
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'engine': 'google_images',
          'q': query,
          'location': 'Indonesia',
          'api_key': _apiKey,
          'num': '1',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('error')) {
          log('serpAPI error: ${data['error']}');
          return null;
        }
        final images = data['images_results'] as List<dynamic>?;

        if (images != null && images.isNotEmpty) {
          return images[0]['original'] as String?;
        } else {
          log('No image results found for: $query');
        }
      } else {
        log('HTTP request failed: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception during SerpAPI call: $e');
    }

    return null;
  }
}
