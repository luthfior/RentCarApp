import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserSource {
  final _firestore = FirebaseFirestore.instance;

  String _hasPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> createPin(String userId, String pin) async {
    final userRef = _firestore.collection('Users').doc(userId);
    final hashedPin = _hasPin(pin);

    try {
      await userRef.update({'pin': hashedPin});
      log('PIN berhasil dibuat dan disimpan');
    } catch (e) {
      log('Gagal membuat PIN: $e');
      rethrow;
    }
  }

  Future<bool> verifyPin(String userId, String enteredPin) async {
    final userRef = _firestore.collection('Users').doc(userId);
    final userSnapshot = await userRef.get();

    if (!userSnapshot.exists || userSnapshot.data()?['pin'] == null) {
      log('Error: PIN belum dibuat');
      return false;
    }

    final storedHashedPin = userSnapshot.data()?['pin'];
    final enteredHashedPin = _hasPin(enteredPin);
    return storedHashedPin == enteredHashedPin;
  }

  Future<void> updateUserBalance(String userId, double amount) async {
    final userRef = _firestore.collection('Users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('User tidak ditemukan');
        }

        final currentBalance = (userSnapshot.data()?['balance'] as num)
            .toDouble();
        final newBalance = currentBalance - amount;

        if (newBalance < 0) {
          throw Exception('Saldo tidak mencukupi');
        }

        transaction.update(userRef, {'balance': newBalance});
      });
    } catch (e) {
      log('Gagal memperbarui saldo: $e');
      rethrow;
    }
  }
}
