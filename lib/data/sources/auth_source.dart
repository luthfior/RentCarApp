import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_session/d_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_car_app/core/utils/result.dart';
import 'package:rent_car_app/data/models/account.dart';

class AuthSource {
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;

  Future<Result<Account>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final querySnapshot = await fireStore
          .collection('Users')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Result.failure('Nama pengguna telah digunakan');
      }

      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return Result.failure('UID tidak ditemukan');
      final account = Account(uid: uid, name: name, email: email, role: role);
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
      log('Gagal daftar akun $e');
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
        return Result.success(account);
      }

      final adminDoc = await fireStore.collection('Admin').doc(uid).get();
      if (adminDoc.exists) {
        final account = Account.fromJson(adminDoc.data()!);
        await DSession.setUser(account.toJson());
        log('Login berhasil sebagai Admin');
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
}
