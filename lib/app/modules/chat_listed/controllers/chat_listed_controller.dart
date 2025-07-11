import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:food_courier/app/data/models/chatted_user_model.dart';
import 'package:get/get.dart';

class ChatListedController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<ChattedUserModel> chattedUsers = <ChattedUserModel>[].obs;

  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  late StreamSubscription _chattedUsersSub;

  Future<void> fetchAllUsersExceptCurrent() async {
    try {
      isLoading.value = true;
      Log.info('Current User ID: $currentUserId');

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isNotEqualTo: currentUserId)
              .get();

      allUsers.assignAll(snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      Log.error('Error fetching all users: $e');
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

  void getChattedUsers() {
    isLoading.value = true;

    _chattedUsersSub = FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final List<ChattedUserModel> usersList = snapshot.docs
            .map(
              (doc) =>
                  ChattedUserModel.fromFirestore(doc.data(), currentUserId),
            )
            .toList();

        chattedUsers.assignAll(usersList);
        isLoading.value = false;
      },
      onError: (e) {
        isLoading.value = false;
        Log.error('Error listening to chatted users: $e');
        Get.snackbar(
          'Error',
          'Failed to load chatted users. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      },
    );
  }

  // Future<void> getChattedUsers() async {
  //   try {
  //     isLoading.value = true;

  //     final QuerySnapshot<Map<String, dynamic>> chatSnapshots =
  //         await FirebaseFirestore.instance
  //             .collection('chats')
  //             .where('users', arrayContains: currentUserId)
  //             .orderBy('createdAt', descending: true)
  //             .get();

  //     if (chatSnapshots.docs.isEmpty) {
  //       return;
  //     }

  //     final List<ChattedUserModel> usersList = chatSnapshots.docs
  //         .map(
  //           (doc) => ChattedUserModel.fromFirestore(doc.data(), currentUserId),
  //         )
  //         .toList();

  //     chattedUsers.assignAll(usersList);
  //   } catch (e) {
  //     Log.error('Error fetching chatted users: $e');
  //     Get.snackbar(
  //       'Error',
  //       'Failed to load chatted users. Please try again later.',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red.withOpacity(0.8),
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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

    getChattedUsers();
    Future.wait([
      fetchAllUsersExceptCurrent(),
    ]);
  }
}
