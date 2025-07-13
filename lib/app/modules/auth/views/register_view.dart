import 'package:flutter/material.dart';
import 'package:food_courier/app/modules/auth/controllers/auth_controller.dart';
import 'package:food_courier/app/modules/auth/views/custom_text_field.dart';
import 'package:get/get.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Create Account'),
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: Colors.black,
      // ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.white,
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
                      const Text(
                        'Get Started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create an account to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 50),
                      Form(
                        key: controller.formKeyRegister,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: controller.nameController,
                              hintText: 'Enter your full name',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nam is required';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
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
                          if (controller.formKeyRegister.currentState!
                              .validate()) {
                            await controller.register();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'REGISTER',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          controller.isLoginPage.value = true;
                        },
                        child: const Text('Already have account? Login'),
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
                          padding: const EdgeInsets.all(16),
                          width: Get.width / 1.4,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 12,
                            children: [
                              CircularProgressIndicator(strokeWidth: 1),
                              Text('Launching your journey, Please wait...'),
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
