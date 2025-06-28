import 'package:flutter/material.dart';
import 'package:food_courier/app/modules/auth/views/login_view.dart';
import 'package:food_courier/app/modules/auth/views/register_view.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
          () => controller.isLoginPage.value ? LoginView() : RegisterView()),
    );
  }
}
