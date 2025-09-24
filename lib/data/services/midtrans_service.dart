import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MidtransService {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 3);

  static Future<Map<String, String>?> processPaymentWithMidtrans(
    String userId,
    String firstName,
    String lastName,
    String email,
    String phone,
    String fullAddress,
    String carId,
    String carNameProduct,
    int carPriceProduct,
    int rentDurationInDays,
    int driverCostPerDay,
    int totalInsuranceCost,
    int additionalCost,
    int amount,
    String carTransmissionProduct,
    String carCategory, {
    int attempt = 1,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${dotenv.env['BACKEND_URL']}/create-transaction"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amount,
          "rentDurationInDays": rentDurationInDays,
          "driverCostPerDay": driverCostPerDay,
          "insuranceCost": totalInsuranceCost,
          "additionalCost": additionalCost,
          "customer": {
            "uid": userId.isNotEmpty
                ? userId
                : Random().nextInt(99999).toString(),
            "first_name": firstName.isNotEmpty ? firstName : "Guest",
            "last_name": lastName.isNotEmpty ? lastName : "User",
            "email": email.isNotEmpty ? email : "guest@example.com",
            "phone": phone.isNotEmpty ? phone : "08123456789",
            "address": fullAddress.isNotEmpty
                ? fullAddress
                : "Jl. Default No.1",
          },
          "product": {
            "id": carId,
            "price": carPriceProduct,
            "name": carNameProduct,
            "brand": carTransmissionProduct,
            "category": carCategory,
          },
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final redirectUrl = data['redirect_url'];
        final orderId = data['order_id'];

        if (redirectUrl != null && orderId != null) {
          return {"redirect_url": redirectUrl, "order_id": orderId};
        } else {
          log(
            "Gagal memproses respons backend: redirect_url atau order_id bernilai null.",
          );
          return null;
        }
      } else if ((res.statusCode == 502 || res.statusCode == 503) &&
          attempt < maxRetries) {
        log(
          "Server Midtrans tidak merespons (status: ${res.statusCode}), mencoba lagi... (percobaan ${attempt + 1})",
        );
        await Future.delayed(retryDelay);
        return processPaymentWithMidtrans(
          userId,
          firstName,
          lastName,
          email,
          phone,
          fullAddress,
          carId,
          carNameProduct,
          carPriceProduct,
          rentDurationInDays,
          driverCostPerDay,
          totalInsuranceCost,
          additionalCost,
          amount,
          carTransmissionProduct,
          carCategory,
          attempt: attempt + 1,
        );
      } else {
        log(
          "Gagal membuat transaksi. Status: ${res.statusCode}, body: ${res.body}",
        );
        return null;
      }
    } on SocketException catch (e) {
      if (attempt < maxRetries) {
        log(
          "Gagal terhubung ke server (SocketException), mencoba lagi... (percobaan ${attempt + 1})",
        );
        await Future.delayed(retryDelay);
        return processPaymentWithMidtrans(
          userId,
          firstName,
          lastName,
          email,
          phone,
          fullAddress,
          carId,
          carNameProduct,
          carPriceProduct,
          rentDurationInDays,
          driverCostPerDay,
          totalInsuranceCost,
          additionalCost,
          amount,
          carTransmissionProduct,
          carCategory,
          attempt: attempt + 1,
        );
      } else {
        log(
          'Gagal membuat transaksi setelah $attempt percobaan koneksi: ${e.toString()}',
        );
        return null;
      }
    } catch (e) {
      log("Gagal membuat transaksi. Status: $e");
      return null;
    }
  }
}
