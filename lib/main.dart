import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_courier/app/core/app_theme.dart';
import 'package:food_courier/app/core/theme_controller.dart';
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

  // await Supabase.initialize(
  //   url: 'https://rtkgbywhaojrradplusv.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0a2dieXdoYW9qcnJhZHBsdXN2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NDg3NjQ2OSwiZXhwIjoyMDYwNDUyNDY5fQ.H1-HfaTJZEMiEypZLd4Ve-aVZ-d672pKoPidVMM_jds',
  // );

  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  final Map<String, dynamic> json = await loadConfig();
  final ThemeController themeController = Get.put(ThemeController());

  runApp(
    Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeController.isDarkMode.value
            ? AppTheme.darkTheme
            : AppTheme.lightTheme,

        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,

        //theme: ThemeData.light(useMaterial3: false),
        //darkTheme: ThemeData.light(),
        title: json['flavor'] ?? '',
        initialRoute: AppPages.ONBOARDING,
        // initialRoute: json['flavor'] == 'Development'
        //     ? AppPages.AUTH
        //     : AppPages.ONBOARDING,
        getPages: AppPages.routes,
      ),
    ),
  );
  // DevicePreview(
  //     builder: (context) {
  //       return Obx(
  //         () => GetMaterialApp(
  //           useInheritedMediaQuery: true,
  //           locale: DevicePreview.locale(context),
  //           builder: DevicePreview.appBuilder,
  //           debugShowCheckedModeBanner: false,
  //           theme: themeController.isDarkMode.value
  //               ? AppTheme.darkTheme
  //               : AppTheme.lightTheme,

  //           themeMode: themeController.isDarkMode.value
  //               ? ThemeMode.dark
  //               : ThemeMode.light,

  //           //theme: ThemeData.light(useMaterial3: false),
  //           //darkTheme: ThemeData.light(),
  //           title: json['flavor'] ?? '',
  //           initialRoute: AppPages.ONBOARDING,
  //           getPages: AppPages.routes,
  //         ),
  //       );
  //     },
  //   ),
}
