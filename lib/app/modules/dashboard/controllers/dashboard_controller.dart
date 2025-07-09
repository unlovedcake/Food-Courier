import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  // Getter to access currentIndex without .value
  int get currentIndex => _currentIndex.value;

  Future<void> changeBottomNav(int index) async {
    _currentIndex.value = index;
  }

  String currentUserId = '';

  late StreamSubscription unreadSubscription;

  final RxInt unreadMessagesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    //Future.delayed(const Duration(milliseconds: 100), countUnreadMessages);
    countUnreadMessages();
  }

  @override
  Future<void> onClose() async {
    await unreadSubscription.cancel(); // clean up properly
    super.onClose();
  }

  void countUnreadMessages() {
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    unreadSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .snapshots()
        .listen(
      (snapshot) {
        int unreadCount = 0;

        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in snapshot.docs) {
          final Map<String, dynamic> data = doc.data();

          // Adjust this logic depending on how messages are structured
          if (data['isRead'] == false &&
              data['sender']['senderId'] != currentUserId) {
            unreadCount++;
          }
        }

        unreadMessagesCount.value = unreadCount;
        Log.info('Unread Messages: $unreadCount');
      },
      onError: (e) {
        Log.error('Error listening to unread messages: $e');
      },
    );
  }

  // Future<void> countUnreadMessages() async {
  //   try {
  //     currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  //     final QuerySnapshot<Map<String, dynamic>> chatSnapshots =
  //         await FirebaseFirestore.instance
  //             .collection('chats')
  //             .where('users', arrayContains: currentUserId)
  //             .get();

  //     if (chatSnapshots.docs.isEmpty) {
  //       return;
  //     }

  //     int unreadCount = 0;

  //     for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
  //         in chatSnapshots.docs) {
  //       final Map<String, dynamic> data = doc.data();

  //       // Check if last message is unread by current user
  //       if (data['isRead'] == false) {
  //         unreadCount++;
  //       }
  //     }

  //     // Log or use unread count
  //     Log.info('Total unread: $unreadCount');
  //     unreadMessagesCount.value =
  //         unreadCount; // Make sure you define it as RxInt
  //   } catch (e) {
  //     Log.error('Error fetching count unread messages chatted users: $e');
  //   }
  // }
}
