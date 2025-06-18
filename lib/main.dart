import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_courier/firebase_options.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

Future<Map<String, dynamic>> loadConfig() async {
  String environment =
      const String.fromEnvironment('env', defaultValue: 'development');

  final String configString =
      await rootBundle.loadString('assets/env/$environment.json');
  return json.decode(configString);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final Map<String, dynamic> json = await loadConfig();

  runApp(
    GetMaterialApp(
      title: json['flavor'] ?? '',
      initialRoute: AppPages.ONBOARDING,
      getPages: AppPages.routes,
    ),
  );
}
