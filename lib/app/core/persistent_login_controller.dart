import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PersistentLoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoggedIn = false.obs;

  @override
  void onReady() {
    super.onReady();
    _checkLogin();
  }

  void _checkLogin() {
    final User? user = _auth.currentUser;
    if (user != null) {
      isLoggedIn.value = true;
    } else {
      isLoggedIn.value = false;
    }
  }
}
