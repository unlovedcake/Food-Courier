import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

// class NotificationService {
//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   final RxString fcmToken = ''.obs;

//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     await _requestPermission();
//     await _initFCM();
//     await _initializeLocalNotifications();
//   }

//   Future<void> _requestPermission() async {
//     await _fcm.requestPermission();
//   }

//   Future<void> _initFCM() async {
//     // Get the token
//     final String? token = await _fcm.getToken();
//     if (token != null) {
//       fcmToken.value = token;
//       Log.info('FCM Token: $token');
//     }

//     // Listen to foreground messages
//     FirebaseMessaging.onMessage.listen((message) async {
//       Log.info('🔔 Foreground message: ${message.notification?.title}');
//       await _showLocalNotification(message);
//     });

//     // On background click
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       Log.info('On background click Notification Clicked!');
//     });
//   }

//   /// Initialize Local Notification Plugin
//   Future<void> _initializeLocalNotifications() async {
//     const AndroidInitializationSettings androidInit =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings iOSInit = DarwinInitializationSettings();

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidInit,
//       iOS: iOSInit,
//     );

//     await _localNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: handleNotificationResponse,
//     );
//   }

//   Future<void> handleNotificationResponse(NotificationResponse response) async {
//     final String? actionId = response.actionId;
//     final int? notificationId = response.id;
//     final String? payload = response.payload;

//     Log.warn('🔔 Notification $actionId');
//     if (actionId != null) {
//       if (actionId == 'open_chat') {
//         Log.info("🔗 User tapped 'Open Chat' $payload");
//       } else if (actionId == 'mark_read') {
//         // ✅ Dismiss notification
//         if (notificationId != null) {
//           await _localNotificationsPlugin.cancel(notificationId);
//           Log.info("✅ User tapped 'Mark as Read'");
//         }
//       } else {
//         Log.info('🟡 Unknown action tapped: $actionId');
//       }
//     } else {
//       Log.info('🔔 Notification tapped (no action)');
//     }
//   }

//   /// Show notification using flutter_local_notifications
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     final RemoteNotification? notification = message.notification;
//     final AndroidNotification? android = message.notification?.android;
//     final Map<String, dynamic> data = message.data;

//     if (notification != null && android != null) {
//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         'fcm_channel', // ID
//         'FCM Notifications', // Name
//         sound: RawResourceAndroidNotificationSound('notification_tone'),
//         importance: Importance.max,
//         priority: Priority.high,
//         actions: <AndroidNotificationAction>[
//           AndroidNotificationAction(
//             'open_chat',
//             'Open Chat',
//             showsUserInterface: true, // set to true to work action button
//           ),
//           AndroidNotificationAction(
//             'mark_read',
//             'Mark as Read',
//             showsUserInterface: true,
//           ),
//         ],
//       );

//       const NotificationDetails platformDetails =
//           NotificationDetails(android: androidDetails);

//       await _localNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         payload: jsonEncode(data),
//         platformDetails,
//       );
//     }
//   }
// }

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final RxString fcmToken = ''.obs;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'fcm_channel',
    'FCM Notifications',
    description: 'Channel for FCM notifications',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification_tone'),
  );

  Future<void> init() async {
    await _requestPermission();
    await _initializeLocalNotifications();
    await _initFCM();
  }

  Future<void> _requestPermission() async {
    await _fcm.requestPermission();
    if (Platform.isAndroid) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _initFCM() async {
    final String? token = await _fcm.getToken();
    if (token != null) {
      fcmToken.value = token;
      Log.info('FCM Token: $token');
    }

    FirebaseMessaging.onMessage.listen((message) async {
      Log.info('🔔 Foreground message: ${message.notification?.title}');
      await _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Log.info('📨 Notification clicked (background/terminated)');
    });
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSInit = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
    );

    // ✅ Create the notification channel (important for Android 8+)
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> handleNotificationResponse(NotificationResponse response) async {
    final String? actionId = response.actionId;
    final int? notificationId = response.id;
    final String? payload = response.payload;

    Log.warn('🔔 Notification $actionId');
    if (actionId != null) {
      if (actionId == 'open_chat') {
        Log.info("🔗 User tapped 'Open Chat' $payload");
      } else if (actionId == 'mark_read') {
        if (notificationId != null) {
          await _localNotificationsPlugin.cancel(notificationId);
          Log.info("✅ User tapped 'Mark as Read'");
        }
      } else {
        Log.info('🟡 Unknown action tapped: $actionId');
      }
    } else {
      Log.info('🔔 Notification tapped (no action)');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;
    final Map<String, dynamic> data = message.data;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'fcm_channel', // Must match channel ID
        'FCM Notifications',
        channelDescription: 'Channel for FCM notifications',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification_tone'),
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'open_chat',
            'Open Chat',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'mark_read',
            'Mark as Read',
            showsUserInterface: true,
          ),
        ],
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: jsonEncode(data),
      );
    }
  }
}

class FCM {
  Future<AccessCredentials> _getAccessToken() async {
    // final serviceAccountPath = dotenv.env['PATH_TO_SECRET'];

    //   String serviceAccountJson = await rootBundle.loadString(
    //   serviceAccountPath!,
    // );

    String environment =
        const String.fromEnvironment('env', defaultValue: 'development');
    final String serviceAccountJson =
        await rootBundle.loadString('assets/env/$environment.json');

    final serviceAccount = ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final AutoRefreshingAuthClient client =
        await clientViaServiceAccount(serviceAccount, scopes);
    Log.info('Client Credentials: ${client.credentials}');
    return client.credentials;
  }

  Future<bool> sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (deviceToken.isEmpty) return false;

    final AccessCredentials credentials = await _getAccessToken();
    final String accessToken = credentials.accessToken.data;
    const projectId = 'phone-auth-ed201';

    Log.info('AccessToken: $accessToken ');

    final Uri url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final Map<String, Map<String, Object>> message = {
      'message': {
        'token': deviceToken,
        'notification': {'title': title, 'body': body},
        'data': data ?? {},
      },
    };

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      Log.info('Notification sent successfully. ${response.body}');
      return true;
    } else {
      Log.error('Failed to send notification: ${response.body}');
      return false;
    }
  }
}
