import 'package:flutter/material.dart';
import 'package:food_courier/app/modules/auth/controllers/auth_controller.dart';
import 'package:food_courier/app/modules/auth/views/custom_text_field.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.orange,
            ],
          ),
        ),
        child: Obx(
          () => Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // const Icon(
                      //   Icons.lock_outline,
                      //   size: 80,
                      //   color: Colors.blueAccent,
                      // ),
                      Image.asset(
                        'assets/images/app_logo.png',
                        height: 209,
                        width: 300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      Form(
                        key: controller.formKeyLogin,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: controller.emailController,
                              hintText: 'Enter your email',
                              icon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!GetUtils.isEmail(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => CustomTextField(
                                controller: controller.passwordController,
                                hintText: 'Enter your password',
                                icon: Icons.lock,
                                obscureText: controller.isPasswordVisible.value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password characters is not less than 6 ';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => controller.togglePassword(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (controller.formKeyLogin.currentState!
                              .validate()) {
                            await controller.login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            const Text('LOGIN', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          controller.isLoginPage.value = false;
                        },
                        child: const Text("Don't have an account? Register"),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: controller.isLoading.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: !controller.isLoading.value
                    ? null
                    : Container(
                        width: Get.width,
                        height: Get.height,
                        color: Colors.black.withValues(alpha: 0.5),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: Get.width / 1.5,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 12,
                            children: [
                              CircularProgressIndicator(strokeWidth: 1),
                              Text('Signing you in, please wait...'),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
