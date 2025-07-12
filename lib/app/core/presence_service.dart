import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PresenceService {
  PresenceService({required this.userId});
  final String userId;
  final _db = FirebaseDatabase.instance.ref();

  Future<void> setupPresenceTracking() async {
    try {
      final DatabaseReference userRef = _db.child('status/$userId');

      final Map<String, Object> onlineStatus = {
        'online': true,
        'isChatPage': false,
        'lastSeen': ServerValue.timestamp,
      };

      final Map<String, Object> offlineStatus = {
        'online': false,
        'isChatPage': false,
        'lastSeen': ServerValue.timestamp,
      };

      final DatabaseReference connectedRef = _db.child('.info/connected');
      connectedRef.onValue.listen((event) async {
        final connected = event.snapshot.value == true;
        if (connected) {
          await userRef.onDisconnect().set(offlineStatus);
          await userRef.set(onlineStatus);
        }
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
