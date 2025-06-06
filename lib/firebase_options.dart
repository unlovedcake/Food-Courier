// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA442UvR2SmQGpS2hwBqQDac8rMCVaky2g',
    appId: '1:321435872473:web:1a3d580f96c23c7ecba2c8',
    messagingSenderId: '321435872473',
    projectId: 'phone-auth-ed201',
    authDomain: 'phone-auth-ed201.firebaseapp.com',
    databaseURL: 'https://phone-auth-ed201-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'phone-auth-ed201.appspot.com',
    measurementId: 'G-1EFQW5WF4K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKNJVccejyRLixZ-qkdW7NOk800Hx8A_g',
    appId: '1:321435872473:android:12626d319667106fcba2c8',
    messagingSenderId: '321435872473',
    projectId: 'phone-auth-ed201',
    databaseURL: 'https://phone-auth-ed201-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'phone-auth-ed201.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB76nEd4lCeSNW8zA1Cbkclc8tUjuvd3OQ',
    appId: '1:321435872473:ios:ba1493ee2a6bcd5ecba2c8',
    messagingSenderId: '321435872473',
    projectId: 'phone-auth-ed201',
    databaseURL: 'https://phone-auth-ed201-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'phone-auth-ed201.appspot.com',
    iosBundleId: 'com.foodCourier',
  );
}
