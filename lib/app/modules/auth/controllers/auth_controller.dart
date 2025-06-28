import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper_functions.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  String get userId => firebaseUser.value?.uid ?? '';

  final isLoginPage = true.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      otherUserId = _auth.currentUser?.uid ?? '';
      await Get.offAllNamed(AppPages.DASHBOARD);
    } catch (e) {
      debugPrint('Error Register $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      otherUserId = _auth.currentUser?.uid ?? '';

      if (otherUserId != 'ataJQe5vGYafW9Ay7QfVbGt2L453') {
        otherUserId = 'ataJQe5vGYafW9Ay7QfVbGt2L453';
      } else {
        otherUserId = '4qYtKhUwkWheyGMeQ4BzeWzSVMq1';
      }

      await Get.offAllNamed(AppPages.DASHBOARD);
    } catch (e) {
      debugPrint('Error Login $e');
    }
  }

  void logout() => _auth.signOut();
}
