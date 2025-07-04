import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/chatted_user_model.dart';
import 'package:get/get.dart';

class ChatListedController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<ChattedUserModel> chattedUsers = <ChattedUserModel>[].obs;

  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> fetchAllUsersExceptCurrent() async {
    try {
      isLoading.value = true;
      print('Current User ID: $currentUserId');

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isNotEqualTo: currentUserId)
              .get();

      allUsers.assignAll(snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      debugPrint('Error fetching all users: $e');
      Get.snackbar(
        'Error',
        'Failed to load users. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getChattedUsers() async {
    try {
      isLoading.value = true;

      final QuerySnapshot<Map<String, dynamic>> chatSnapshots =
          await FirebaseFirestore.instance
              .collection('chats')
              .where('users', arrayContains: currentUserId)
              .orderBy('createdAt', descending: true)
              .get();

      if (chatSnapshots.docs.isEmpty) {
        return;
      }

      final List<ChattedUserModel> usersList = chatSnapshots.docs
          .map(
            (doc) => ChattedUserModel.fromFirestore(doc.data(), currentUserId),
          )
          .toList();

      chattedUsers.assignAll(usersList);
    } catch (e) {
      debugPrint('Error fetching chatted users: $e');
      Get.snackbar(
        'Error',
        'Failed to load chatted users. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  void onInit() {
    super.onInit();

    Future.wait([
      fetchAllUsersExceptCurrent(),
      getChattedUsers(),
    ]);
  }
}
