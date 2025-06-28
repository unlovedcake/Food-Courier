import 'package:flutter/material.dart';
import 'package:food_courier/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final email = TextEditingController();
  final password = TextEditingController();
  final AuthController auth = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                await auth.register(email.text.trim(), password.text.trim());
                // Get.off(() => ChatPage(
                //     chatId: generateChatId(auth.userId, 'otherUserId123')));
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                auth.isLoginPage.value = true;
              },
              child: const Text('Login Instead'),
            ),
          ],
        ),
      ),
    );
  }
}
