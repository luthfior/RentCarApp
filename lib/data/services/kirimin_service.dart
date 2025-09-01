import 'dart:convert';
import 'package:http/http.dart' as http;

class KiriminService {
  final String baseUrl = "https://api.kirimin.id/api";
  Future<List<Map<String, dynamic>>> fetchProvinces() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/province"));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return List<Map<String, dynamic>>.from(body['data']);
      } else {
        throw Exception("Gagal load provinsi");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCities(int provinceId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/city/$provinceId"));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return List<Map<String, dynamic>>.from(body['data']);
      } else {
        throw Exception("Gagal load kota");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSubDistricts(int cityId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/sub_district/$cityId"));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return List<Map<String, dynamic>>.from(body['data']);
      } else {
        throw Exception("Gagal load kecamatan");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchVillages(int subDistrictId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/village/$subDistrictId"));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return List<Map<String, dynamic>>.from(body['data']);
      } else {
        throw Exception("Gagal load kelurahan");
      }
    } catch (e) {
      rethrow;
    }
  }
}
