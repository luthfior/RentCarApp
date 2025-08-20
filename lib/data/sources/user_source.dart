import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:rent_car_app/data/models/car.dart';

class UserSource {
  final _firestore = FirebaseFirestore.instance;
  final cloudinary = CloudinaryPublic(
    'dodjmyloc',
    'user_profiles',
    cache: true,
  );

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

  Future<void> updatePin(String userId, String newPin) async {
    final userRef = _firestore.collection('Users').doc(userId);
    final hashedPin = _hasPin(newPin);

    try {
      await userRef.update({'pin': hashedPin});
      log('PIN berhasil diperbarui');
    } catch (e) {
      log('Gagal memperbarui PIN: $e');
      rethrow;
    }
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

  Future<void> updateProfilePicture(String userId, XFile file) async {
    final userRef = _firestore.collection('Users').doc(userId);
    String? imageUrl;
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      imageUrl = response.secureUrl;
      // ignore: unnecessary_null_comparison
      if (imageUrl == null) {
        log('Gagal mengunggah gambar ke Cloudinary.');
        throw Exception('Gagal mengunggah gambar');
      }
      await userRef.update({'photoUrl': imageUrl});
      log('Gambar profil berhasil diperbarui: $imageUrl');
    } on CloudinaryException catch (e) {
      log('Cloudinary Error: ${e.message}');
      throw Exception('Gagal mengunggah gambar');
    } catch (e) {
      log('Gagal mengunggah gambar.');
      rethrow;
    }
  }

  Future<void> updateUserName(String userId, String newName) async {
    final userRef = _firestore.collection('Users').doc(userId);
    try {
      await userRef.update({'name': newName});
      log('Nama berhasil diperbarui menjadi: $newName');
    } catch (e) {
      log('Gagal memperbarui nama: $e');
      rethrow;
    }
  }

  Future<void> toggleFavoriteProduct(String userId, Car car) async {
    final favProductRef = _firestore
        .collection('Users')
        .doc(userId)
        .collection('favProducts')
        .doc(car.id);

    final docSnapshot = await favProductRef.get();

    if (docSnapshot.exists) {
      await favProductRef.delete();
      log('Produk berhasil dihapus dari favorit');
    } else {
      await favProductRef.set({
        ...car.toJson(),
        'timeStamp': FieldValue.serverTimestamp(),
      });
      log('Produk berhasil ditambahkan ke favorit');
    }
  }

  Future<bool> isProductFavorited(String userId, String productId) async {
    final favProductRef = _firestore
        .collection('Users')
        .doc(userId)
        .collection('favProducts')
        .doc(productId);

    final docSnapshot = await favProductRef.get();
    return docSnapshot.exists;
  }
}
