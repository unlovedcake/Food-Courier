import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:food_courier/app/core/helper/helper_functions.dart'
    show generateChatId, otherUserId;
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  // Getter to access currentIndex without .value
  int get currentIndex => _currentIndex.value;

  Future<void> changeTab(int index) async {
    _currentIndex.value = index;

    // if (index == 1) {
    //   await markMessageAsRead();
    // }
  }

  final isRead = false.obs;
  String messageId = '';
  String currentUserId = '';
  String chatId = '';

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 100), countUnreadMessages);
  }

  void geUserIdAndChatId() {
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    otherUserId = '39oFpwnrhNdygpKnNTJPlNzuYhi1';

    chatId = generateChatId(currentUserId, otherUserId);
  }

  Future<void> getLastMessage() async {
    geUserIdAndChatId();

    final DocumentReference<Map<String, dynamic>> chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

// Check if chat document exists
    final DocumentSnapshot<Map<String, dynamic>> chatDoc =
        await chatDocRef.get();

    if (chatDoc.exists) {
      final CollectionReference<Map<String, dynamic>> messagesRef =
          FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('messages');

      // Get last message based on timestamp
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await messagesRef
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final QueryDocumentSnapshot<Map<String, dynamic>> doc =
            querySnapshot.docs.first;
        final Map<String, dynamic> data = doc.data();

        messageId = data['id'] ?? '';
        final String messageText = data['text'] ?? '';
        isRead.value = data['isRead'] ?? false;
      } else {
        Log.warn('No messages found.');
      }
    } else {
      // ❌ chatId does not exist
      Log.error('Chat with ID $chatId does not exist');
      return;
    }
  }

  final RxInt unreadMessagesCount = 0.obs;

  Future<void> countUnreadMessages() async {
    try {
      currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final QuerySnapshot<Map<String, dynamic>> chatSnapshots =
          await FirebaseFirestore.instance
              .collection('chats')
              .where('users', arrayContains: currentUserId)
              .get();

      if (chatSnapshots.docs.isEmpty) {
        return;
      }

      int unreadCount = 0;

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in chatSnapshots.docs) {
        final Map<String, dynamic> data = doc.data();

        // Check if last message is unread by current user
        if (data['isRead'] == false) {
          unreadCount++;
        }
      }

      // Log or use unread count
      Log.info('Total unread: $unreadCount');
      unreadMessagesCount.value =
          unreadCount; // Make sure you define it as RxInt
    } catch (e) {
      Log.error('Error fetching count unread messages chatted users: $e');
    }
  }
}
