import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_session/d_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rent_car_app/core/utils/result.dart';
import 'package:rent_car_app/data/models/account.dart';

class AuthSource {
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final fcm = FirebaseMessaging.instance;

  Future<void> saveFcmToken(String uid, {bool isAdmin = false}) async {
    final token = await fcm.getToken();
    if (token == null) return;
    final userCollection = isAdmin ? 'Admin' : 'Users';
    await FirebaseFirestore.instance.collection(userCollection).doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));

    FirebaseMessaging.instance.onTokenRefresh.listen((newTkn) {
      FirebaseFirestore.instance.collection(userCollection).doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([newTkn]),
      }, SetOptions(merge: true));
    });
  }

  Future<Result<Account>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? storeName,
  }) async {
    try {
      if (fullName.toLowerCase().contains('admin')) {
        return Result.failure('Nama pengguna telah digunakan');
      }

      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) return Result.failure('UID tidak ditemukan');

      String username = '';
      String finalStoreName = '';

      if (role == 'customer') {
        final cleanUsername = fullName.trim().toLowerCase().replaceAll(
          ' ',
          '_',
        );
        final suffix = uid.substring(0, 3);
        username = "$cleanUsername#$suffix";
        finalStoreName = '';
      } else if (role == 'seller') {
        if (storeName == null || storeName.trim().isEmpty) {
          return Result.failure('Nama toko wajib diisi');
        }

        final snapshot = await fireStore
            .collection('Users')
            .where('storeName', isEqualTo: storeName)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return Result.failure('Nama Toko sudah digunakan, coba nama lain');
        }
        final cleanUsername = fullName.trim().toLowerCase().replaceAll(
          ' ',
          '_',
        );
        final suffix = uid.substring(0, 3);
        username = "$cleanUsername#$suffix";
        finalStoreName = storeName;
      }

      final account = Account(
        uid: uid,
        fullName: fullName,
        email: email,
        role: role,
        username: username,
        storeName: finalStoreName,
      );

      await fireStore
          .collection('Users')
          .doc(account.uid)
          .set(account.toJson());

      return Result.success(account);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return Result.failure('Kata sandi yang diberikan terlalu lemah');
      } else if (e.code == 'email-already-in-use') {
        return Result.failure('Alamat Email tersebut telah digunakan');
      }
      log(e.toString());
      return Result.failure('Terjadi kesalahan');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal Daftar Akun $e');
      return Result.failure(e.toString());
    }
  }

  Future<Result<Account>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return Result.failure('UID tidak ditemukan');
      }

      final userDoc = await fireStore.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        final account = Account.fromJson(userDoc.data()!);
        await DSession.setUser(account.toJson());
        log('Login berhasil sebagai User');
        saveFcmToken(uid, isAdmin: false);
        return Result.success(account);
      }

      final adminDoc = await fireStore.collection('Admin').doc(uid).get();
      if (adminDoc.exists) {
        final account = Account.fromJson(adminDoc.data()!);
        await DSession.setUser(account.toJson());
        log('Login berhasil sebagai Admin');
        saveFcmToken(uid, isAdmin: true);
        return Result.success(account);
      }

      return Result.failure('Pengguna tidak ditemukan di database');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return Result.failure('Email/Kata Sandi yang Anda masukkan salah');
      }
      log(e.toString());
      return Result.failure('Terjadi kesalahan');
    } on FirebaseException catch (e) {
      log('Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Gagal login $e');
      return Result.failure(e.toString());
    }
  }

  Future<void> removeFcmToken(String uid, {bool isAdmin = false}) async {
    final token = await fcm.getToken();
    if (token == null) return;
    final userCollection = isAdmin ? 'Admin' : 'Users';
    await FirebaseFirestore.instance.collection(userCollection).doc(uid).update(
      {
        'fcmTokens': FieldValue.arrayRemove([token]),
      },
    );
  }
}
