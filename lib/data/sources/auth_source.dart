import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_session/d_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_car_app/core/utils/result.dart';
import 'package:rent_car_app/data/models/account.dart';

class AuthSource {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<Result<Account>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return Result.failure('UID tidak ditemukan');
      final account = Account(uid: uid, name: name, email: email);
      await _firestore
          .collection('Users')
          .doc(account.uid)
          .set(account.toJson());
      return Result.success(account);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return Result.failure('Kata sandi yang diberikan terlalu lemah');
      } else if (e.code == 'email-already-in-use') {
        return Result.failure(
          'Akun tersebut sudah ada untuk alamat email tersebut',
        );
      }
      log(e.toString());
      return Result.failure('Terjadi kesalahan');
    } catch (e) {
      log(e.toString());
      return Result.failure(e.toString());
    }
  }

  Future<Result<Account>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return Result.failure('UID tidak ditemukan');

      final accountDoc = await _firestore.collection('Users').doc(uid).get();
      if (!accountDoc.exists) {
        return Result.failure('Pengguna tidak ditemukan di database');
      }

      final account = Account.fromJson(accountDoc.data()!);

      await DSession.setUser(account.toJson());
      return Result.success(account);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return Result.failure('Email/Kata Sandi yang Anda masukkan salah');
      }
      log(e.toString());
      return Result.failure('Terjadi kesalahan');
    } catch (e) {
      log(e.toString());
      return Result.failure(e.toString());
    }
  }
}
