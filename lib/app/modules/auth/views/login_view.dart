import 'package:flutter/material.dart';
import 'package:food_courier/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final email = TextEditingController();
  final password = TextEditingController();
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.login(email.text.trim(), password.text.trim());
                //Get.off(() => ChatPage(chatId: generateChatId(auth.userId, 'otherUserId123')));
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                controller.isLoginPage.value = false;
              },
              child: const Text('Register Instead'),
            ),
          ],
        ),
      ),
    );
  }
}
