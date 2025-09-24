import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PushNotificationService {
  static final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 3);

  static Future<void> sendToOne(
    String token,
    String title,
    String body, {
    Map<String, String>? data,
    int attempt = 1,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/send-notification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "title": title,
          "body": body,
          "data": data,
        }),
      );

      if (res.statusCode == 200) {
        log("Notifikasi tunggal berhasil dikirim.");
      } else if ((res.statusCode == 502 || res.statusCode == 503) &&
          attempt < maxRetries) {
        log(
          "Server tidak merespons (status: ${res.statusCode}), mencoba lagi... (percobaan ${attempt + 1})",
        );
        await Future.delayed(retryDelay);
        return sendToOne(token, title, body, attempt: attempt + 1);
      } else {
        log("Gagal kirim notif setelah $attempt percobaan: ${res.body}");
      }
    } on SocketException catch (e) {
      if (attempt < maxRetries) {
        log(
          "Gagal terhubung ke server (SocketException), mencoba lagi... (percobaan ${attempt + 1})",
        );
        await Future.delayed(retryDelay);
        return sendToOne(token, title, body, attempt: attempt + 1);
      } else {
        log(
          'Gagal mengirim notifikasi multi-role setelah $attempt percobaan koneksi: ${e.toString()}',
        );
      }
    } catch (e) {
      log('Gagal mengirim notifikasi tunggal: ${e.toString()}');
    }
  }

  static Future<void> sendToMany(
    List<String> tokens,
    String title,
    String body, {
    Map<String, String>? data,
    int attempt = 1,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/send-multi"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tokens": tokens,
          "title": title,
          "body": body,
          "data": data,
        }),
      );

      if (res.statusCode == 200) {
        log("Notifikasi multicast berhasil dikirim.");
      } else if ((res.statusCode == 502 || res.statusCode == 503) &&
          attempt < maxRetries) {
        log(
          "Server tidak merespons (status: ${res.statusCode}), mencoba lagi... (percobaan ${attempt + 1})",
        );
        await Future.delayed(retryDelay);
        return sendToMany(tokens, title, body, attempt: attempt + 1);
      } else {
        log("Gagal multicast setelah $attempt percobaan: ${res.body}");
      }
    } on SocketException catch (e) {
      if (attempt < maxRetries) {
        log(
          "Gagal terhubung ke server (SocketException), mencoba lagi... (percobaan ${attempt + 1})",
        );
        await Future.delayed(retryDelay);
        return sendToMany(tokens, title, body, attempt: attempt + 1);
      } else {
        log(
          'Gagal mengirim notifikasi multi-role setelah $attempt percobaan koneksi: ${e.toString()}',
        );
      }
    } catch (e) {
      log(
        'Gagal mengirim notifikasi (sendToMany) ke banyak akun: ${e.toString()}',
      );
    }
  }

  static Future<void> sendToRoles(
    List<String> roles,
    String title,
    String body, {
    Map<String, String>? data,
    int attempt = 1,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/send-to-roles"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "roles": roles,
          "title": title,
          "body": body,
          "data": data ?? {},
        }),
      );

      if ((res.statusCode == 502 || res.statusCode == 503) &&
          attempt < maxRetries) {
        log(
          "Server tidak merespons (status: ${res.statusCode}), mencoba lagi... (percobaan ${attempt + 1})",
        );
        await Future.delayed(retryDelay);
        return sendToRoles(roles, title, body, attempt: attempt + 1);
      }

      if (res.statusCode != 200) {
        log("Gagal kirim multi-role setelah $attempt percobaan: ${res.body}");
      } else {
        log("Notifikasi multi-role berhasil dikirim.");
      }
    } on SocketException catch (e) {
      if (attempt < maxRetries) {
        log(
          "Gagal terhubung ke server (SocketException), mencoba lagi... (percobaan ${attempt + 1})",
        );
        await Future.delayed(retryDelay);
        return sendToRoles(roles, title, body, attempt: attempt + 1);
      } else {
        log(
          'Gagal mengirim notifikasi multi-role setelah $attempt percobaan koneksi: ${e.toString()}',
        );
      }
    } catch (e) {
      log(
        'Terjadi error tidak terduga saat mengirim notifikasi berdasarkan roles: ${e.toString()}',
      );
    }
  }
}
