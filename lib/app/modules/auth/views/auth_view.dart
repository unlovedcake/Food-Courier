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
            // The transitionBuilder defines how the animation occurs
            transitionBuilder: (child, animation) {
              return FadeTransition(
                // It's often best to keep the fade linear for a smooth opacity change.
                opacity: animation,
                child: child,
              );
              // final curvedAnimation = CurvedAnimation(
              //   parent: animation,
              //   curve: Curves.easeOutBack, // This curve creates the 'pop'
              // );

              // return ScaleTransition(
              //   // Use the curved animation for the scale effect.
              //   scale: curvedAnimation,
              //   child: FadeTransition(
              //     // It's often best to keep the fade linear for a smooth opacity change.
              //     opacity: animation,
              //     child: child,
              //   ),
              // );
            },
            // The key is crucial. It tells AnimatedSwitcher that the child
            // has changed, triggering the animation.
            child: controller.isLoginPage.value
                ? const LoginPage(key: ValueKey('LoginPage'))
                : const RegisterPage(key: ValueKey('RegisterPage')),
          );
        },
      ),
    );
  }
}
