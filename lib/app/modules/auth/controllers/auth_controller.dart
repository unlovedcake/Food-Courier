import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:food_courier/app/data/models/user_model.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final formKeyLogin = GlobalKey<FormState>();
  final formKeyRegister = GlobalKey<FormState>();

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoginPage = true.obs;
  final isPasswordVisible = true.obs;

  final isLoading = false.obs;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void togglePassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> _addUserToFirestore(User firebaseUser) async {
    try {
      final String? deviceToken = await FirebaseMessaging.instance.getToken();
      final newUser = UserModel(
        uid: firebaseUser.uid,
        name: nameController.text,
        imageUrl:
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png',
        email: firebaseUser.email ?? '',
        deviceToken: deviceToken ?? '',
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toJson());
    } on Exception catch (e) {
      Log.error('Error Add User $e');
      Get
        ..back()
        ..snackbar('Error', 'An unknown error occurred $e.');
    }
  }

  Future<void> register() async {
    isLoading.value = true;
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        await user.updateProfile(
          displayName: nameController.text,
          photoURL:
              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png',
        );

        // Add user data to Firestore
        await _addUserToFirestore(user);
        isLoading.value = false;
        await Future.delayed(const Duration(milliseconds: 100));
        await Get.offAllNamed(AppPages.DASHBOARD);
      }
    } on FirebaseAuthException catch (e) {
      Log.error('Error Register $e');
      Get
        ..back()
        // Show error snackbar
        ..snackbar(
          'Registration Failed',
          _handleFirebaseAuthError(e.code),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
    } on Exception catch (e) {
      Log.error('Error Register $e');
      Get
        ..back()
        ..snackbar('Error', 'An unknown error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    isLoading.value = true;

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      isLoading.value = false;
      await Future.delayed(const Duration(milliseconds: 100));

      await Get.offAllNamed(AppPages.DASHBOARD);
    } on FirebaseAuthException catch (e) {
      Log.error('Error Login $e');
      Get.snackbar(
        'Login Failed',
        _handleFirebaseAuthError(e.code),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      isLoading.value = false;
    } catch (e) {
      Log.error('Error Login $e');
      Get.snackbar('Error', 'An unknown error occurred.');
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- Error Handling Helper ---
  String _handleFirebaseAuthError(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'You entered invalid credential.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Rx<User?> firebaseUser = Rx<User?>(null);
  // String get userId => firebaseUser.value?.uid ?? '';

  // final isLoginPage = true.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   firebaseUser.bindStream(_auth.authStateChanges());
  // }

  // Future<void> register(String email, String password) async {
  //   try {
  //     await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     otherUserId = _auth.currentUser?.uid ?? '';
  //     await Get.offAllNamed(AppPages.DASHBOARD);
  //   } catch (e) {
  //     debugLog('Error Register $e');
  //   }
  // }

  // Future<void> login(String email, String password) async {
  //   try {
  //     await _auth.signInWithEmailAndPassword(email: email, password: password);

  //     otherUserId = _auth.currentUser?.uid ?? '';

  //     if (otherUserId != 'ataJQe5vGYafW9Ay7QfVbGt2L453') {
  //       otherUserId = 'ataJQe5vGYafW9Ay7QfVbGt2L453';
  //     } else {
  //       otherUserId = '4qYtKhUwkWheyGMeQ4BzeWzSVMq1';
  //     }

  //     await Get.offAllNamed(AppPages.DASHBOARD);
  //   } catch (e) {
  //     debugLog('Error Login $e');
  //   }
  // }

  // void logout() => _auth.signOut();
}
