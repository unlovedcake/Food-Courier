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
        () {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            transitionBuilder: (child, animation) {
              final Animation<Offset> slideIn = Tween<Offset>(
                begin: const Offset(1, 0), // Slide from right
                //begin: const Offset(-1, 0), // 👈 Slide in from LEFT
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              );

              return SlideTransition(
                position: slideIn,
                child: child,
              );
            },
            child: controller.isLoginPage.value
                ? const LoginPage(key: ValueKey('LoginPage'))
                : const RegisterPage(key: ValueKey('RegisterPage')),
          );
        },
      ),
    );
  }
}
