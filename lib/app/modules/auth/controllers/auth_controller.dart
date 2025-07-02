import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper/helper_functions.dart'
    show otherUserId;
import 'package:food_courier/app/core/helper/show_loading.dart';
import 'package:food_courier/app/data/models/user_model.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final formKey = GlobalKey<FormState>();

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reactive variables
  final Rxn<User> _firebaseUser = Rxn<User>();
  User? get user => _firebaseUser.value;

  // Text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoginPage = true.obs;
  final isPasswordVisible = true.obs;

  // @override
  // void onReady() {
  //   super.onReady();
  //   _firebaseUser.bindStream(_auth.authStateChanges());
  //   // This listener will automatically navigate the user
  //   ever(_firebaseUser, _setInitialScreen);
  // }

  // _setInitialScreen(User? user) {
  //   if (user == null) {
  //     // if the user is not found then the user is navigated to the Login Screen
  //     Get.offAllNamed(Routes.AUTH);
  //   } else {
  //     // if the user exists and is logged in the the user is navigated to the Home Screen
  //     Get.offAllNamed(Routes.DASHBOARD);
  //   }
  // }

  void togglePassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> _addUserToFirestore(User firebaseUser) async {
    try {
      final newUser = UserModel(
        uid: firebaseUser.uid,
        name: nameController.text,
        imageUrl: '',
        email: firebaseUser.email!,
        favoriteProducts: [],
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toJson());
    } on Exception catch (e) {
      debugPrint('Error Add User $e');
      Get
        ..back()
        ..snackbar('Error', 'An unknown error occurred.');
    }
  }

  Future<void> register() async {
    showLoading(); // Helper to show a loading dialog
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await userCredential.user?.updateDisplayName(nameController.text);
        // Add user data to Firestore
        await _addUserToFirestore(userCredential.user!);
        otherUserId = _auth.currentUser?.uid ?? '';
        await Get.offAllNamed(AppPages.DASHBOARD);
      }
    } on FirebaseAuthException catch (e) {
      // Hide loading dialog
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
    } catch (e) {
      Get
        ..back()
        ..snackbar('Error', 'An unknown error occurred.');
    }
  }

  Future<void> login() async {
    showLoading();
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      otherUserId = _auth.currentUser?.uid ?? '';

      if (otherUserId != 'ataJQe5vGYafW9Ay7QfVbGt2L453') {
        otherUserId = 'ataJQe5vGYafW9Ay7QfVbGt2L453';
      } else {
        otherUserId = '4qYtKhUwkWheyGMeQ4BzeWzSVMq1';
      }

      await Get.offAllNamed(AppPages.DASHBOARD);
    } on FirebaseAuthException catch (e) {
      debugPrint('Error $e');
      Get
        ..back()
        ..snackbar(
          'Login Failed',
          _handleFirebaseAuthError(e.code),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
    } catch (e) {
      debugPrint('Error $e');
      Get
        ..back()
        ..snackbar('Error', 'An unknown error occurred.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // Clear text controllers on sign out
    emailController.clear();
    passwordController.clear();
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
  //     debugPrint('Error Register $e');
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
  //     debugPrint('Error Login $e');
  //   }
  // }

  // void logout() => _auth.signOut();
}
