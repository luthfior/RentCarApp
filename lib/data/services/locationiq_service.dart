import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LocationIQService {
  static final String _apiKey = dotenv.env['LOCATION_IQ_API_KEY'] ?? '';
  static final _baseUrl = dotenv.env['LOCATION_IQ_URL'] ?? '';

  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final url = Uri.parse(
      "$_baseUrl/v1/autocomplete.php?key=$_apiKey&q=$query&limit=5&format=json",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        final address = item["address"] ?? {};
        return {
          "display_name": item["display_name"],
          "lat": item["lat"],
          "lon": item["lon"],
          "province": address["state"] ?? "",
          "city":
              address["city"] ??
              address["town"] ??
              address["municipality"] ??
              "",
          "district":
              address["city_district"] ??
              address["suburb"] ??
              address["county"] ??
              address["region"] ??
              "",
          "village": address["village"] ?? address["hamlet"] ?? "",
          "street": address["name"] ?? "",
        };
      }).toList();
    } else {
      throw Exception("Lokasi tidak ditemukan. Coba lagi");
    }
  }

  Future<Map<String, dynamic>> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse(
      "https://us1.locationiq.com/v1/reverse.php?key=$_apiKey&lat=$lat&lon=$lon&format=json",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data["address"] ?? {};
      return {
        "display_name": data["display_name"] ?? "",
        "province": address["state"] ?? "",
        "city":
            address["city"] ?? address["town"] ?? address["municipality"] ?? "",
        "district":
            address["city_district"] ??
            address["suburb"] ??
            address["county"] ??
            address["region"] ??
            "",
        "village": address["village"] ?? address["hamlet"] ?? "",
        "street": address["name"] ?? "",
      };
    } else {
      throw Exception("Gagal reverse geocode");
    }
  }
}
