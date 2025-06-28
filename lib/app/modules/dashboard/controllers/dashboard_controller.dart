import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper_functions.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  // Getter to access currentIndex without .value
  int get currentIndex => _currentIndex.value;

  Future<void> changeTab(int index) async {
    _currentIndex.value = index;

    if (index == 1) {
      await markMessageAsRead();
    }
  }

  final isRead = false.obs;
  String messageId = '';
  String currentUserId = '';
  String chatId = '';

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 100), getLastMessage);
  }

  void geUserIdAndChatId() {
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    chatId = generateChatId(currentUserId, otherUserId);
  }

  Future<void> getLastMessage() async {
    geUserIdAndChatId();
    print('chatId: $chatId');
    print('currentUserId: $currentUserId');
    print('otherUserId: $otherUserId');

    final CollectionReference<Map<String, dynamic>> messagesRef =
        FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages');

    // Get last message based on timestamp
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await messagesRef.orderBy('timestamp', descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final QueryDocumentSnapshot<Map<String, dynamic>> doc =
          querySnapshot.docs.first;
      final Map<String, dynamic> data = doc.data();

      messageId = data['id'] ?? '';
      final String messageText = data['text'] ?? '';
      isRead.value = data['isRead'] ?? false;

      print('messageId: $messageId');
      print('Last Message: $messageText');
      print('Is Read: $isRead');
    } else {
      print('No messages found.');
    }
  }

  Future<void> markMessageAsRead() async {
    if (isRead.value) {
      return;
    }
    try {
      final DocumentReference<Map<String, dynamic>> messageRef =
          FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .doc(messageId);

      await messageRef.update({'isRead': true});
      isRead.value = true;
      debugPrint('Mark As Read Successfully Updated');
    } catch (e) {
      debugPrint('Mark As Read Error $e');
    }
  }
}
