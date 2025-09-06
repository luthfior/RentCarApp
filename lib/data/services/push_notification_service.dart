import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PushNotificationService {
  static final String baseUrl =
      dotenv.env['BACKEND_URL'] ?? "http://localhost:3000";

  static Future<void> sendToOne(String token, String title, String body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/send-notification"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": token, "title": title, "body": body}),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal kirim notif: ${res.body}");
    }
  }

  static Future<void> sendToMany(
    List<String> tokens,
    String title,
    String body,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/send-multi"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tokens": tokens, "title": title, "body": body}),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal multicast: ${res.body}");
    }
  }

  static Future<void> sendToRole(String role, String title, String body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/send-to-role"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"role": role, "title": title, "body": body}),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal kirim role-based: ${res.body}");
    }
  }

  static Future<void> sendToAll(String title, String body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/send-all"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "body": body}),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal broadcast: ${res.body}");
    }
  }
}
