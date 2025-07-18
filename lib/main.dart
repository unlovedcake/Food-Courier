import 'dart:convert';
import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_courier/app/core/app_theme.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:food_courier/app/core/persistent_login_controller.dart';
import 'package:food_courier/app/core/theme_controller.dart';
import 'package:food_courier/app/modules/services/notification_service.dart';
import 'package:food_courier/app/modules/services/service_api.dart';
import 'package:food_courier/env.dart';
import 'package:food_courier/firebase_options.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'app/routes/app_pages.dart';

Future<Map<String, dynamic>> loadConfig() async {
  String environment =
      const String.fromEnvironment('env', defaultValue: 'development');

  final String configString =
      await rootBundle.loadString('assets/env/$environment.json');
  return json.decode(configString);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Log.info('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isCompleteOnBoarding =
      prefs.getBool('onboarding_complete') ?? false;

  final notificationService = NotificationService();

  await Future.wait([
    notificationService.init(),
    Supabase.initialize(
      url: Env.url,
      anonKey: Env.apiKey,
    ),
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true),
    ServiceApi().setServiceApi(await loadConfig()),
  ]);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(MyApp(isCompleteOnBoarding: isCompleteOnBoarding));

  // runApp(
  //   Obx(
  //     () => GetMaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       theme: themeController.isDarkMode.value
  //           ? AppTheme.darkTheme
  //           : AppTheme.lightTheme,

  //       themeMode:
  //           themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,

  //       //theme: ThemeData.light(useMaterial3: false),
  //       //darkTheme: ThemeData.light(),

  //       initialRoute: persistentController.isLoggedIn.value
  //           ? AppPages.DASHBOARD
  //           : AppPages.ONBOARDING,
  //       // initialRoute: json['flavor'] == 'Development'
  //       //     ? AppPages.AUTH
  //       //     : AppPages.ONBOARDING,
  //       getPages: AppPages.routes,
  //     ),
  //   ),
  // );
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

class MyApp extends StatelessWidget {
  const MyApp({required this.isCompleteOnBoarding, super.key});

  final bool isCompleteOnBoarding;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final ThemeController themeController = Get.put(ThemeController());
    final PersistentLoginController persistentController =
        Get.put(PersistentLoginController());
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeController.isDarkMode.value
            ? AppTheme.darkTheme
            : AppTheme.lightTheme,
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: isCompleteOnBoarding && user != null
            ? AppPages.DASHBOARD
            : !isCompleteOnBoarding
                ? AppPages.ONBOARDING
                : AppPages.AUTH,
        getPages: AppPages.routes,
      ),
    );
  }
}
