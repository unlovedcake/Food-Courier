import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper/helper_functions.dart';
import 'package:food_courier/app/data/models/chatted_user_model.dart';
import 'package:food_courier/app/data/models/user_model.dart';
import 'package:food_courier/app/modules/home/controllers/home_controller.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../controllers/chat_listed_controller.dart';

class ChatListedView extends GetView<ChatListedController> {
  const ChatListedView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.lazyPut<ChatListedController>(
      ChatListedController.new,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const AllUsersHorizontalView(),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.chattedUsers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    if (controller.chattedUsers.isEmpty) {
                      return const Center(child: Text('No conversations yet'));
                    }

                    final ChattedUserModel chat =
                        controller.chattedUsers[index];

                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.secondary,
                      contentPadding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: chat.sender.senderImage.isNotEmpty
                            ? NetworkImage(
                                chat.sender.senderId == controller.currentUserId
                                    ? chat.receiver.receiverImage
                                    : chat.sender.senderImage,
                              )
                            : const NetworkImage(
                                'https://militaryhealthinstitute.org/wp-content/uploads/sites/37/2021/08/blank-profile-picture-png.png',
                              ) as ImageProvider,
                        radius: 25,
                      ),
                      title: Text(
                        chat.sender.senderId == controller.currentUserId
                            ? chat.receiver.receiverName
                            : chat.sender.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chat.isDeleted
                            ? chat.sender.senderId == controller.currentUserId
                                ? 'You unsent the message'
                                : '${chat.sender.senderName} unsent the message'
                            : chat.sender.senderId == controller.currentUserId
                                ? 'You: ${chat.lastMessage}'
                                : chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: chat.isRead ? Colors.grey : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        controller.timeAgo(chat.createdAt), // format nicely
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                      onTap: () async {
                        String currentUserId =
                            FirebaseAuth.instance.currentUser?.uid ?? '';

                        String chatId = generateChatId(
                          currentUserId,
                          chat.sender.senderId == controller.currentUserId
                              ? chat.receiver.receiverId
                              : chat.sender.senderId,
                        );

                        try {
                          if (!chat.isRead &&
                              chat.sender.senderId !=
                                  controller.currentUserId) {
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(chatId)
                                .update({
                              'isRead': true,
                            });
                          }

                          String receiverId =
                              chat.sender.senderId == controller.currentUserId
                                  ? chat.receiver.receiverId
                                  : chat.sender.senderId;

                          String receiverName =
                              chat.sender.senderId == controller.currentUserId
                                  ? chat.receiver.receiverName
                                  : chat.sender.senderName;

                          String receiverImageUrl =
                              chat.sender.senderId == controller.currentUserId
                                  ? chat.receiver.receiverImage
                                  : chat.sender.senderImage;

                          await Get.toNamed(
                            AppPages.CHAT,
                            arguments: {
                              'chatId': chatId,
                              'receiverId': receiverId,
                              'receiverName': receiverName,
                              'receiverImageUrl': receiverImageUrl,
                              'receiverDeviceToken': chat.deviceTOken,
                            },
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to load chat. Please try again later.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // await Get.toNamed(
                        //   AppPages.CHAT,
                        //   arguments: {
                        //     'chatId': chat.chatId,
                        //     'receiverId': chat.r,
                        //     'receiverName': chat.receiverName,
                        //     'receiverImageUrl': chat.profileImage,
                        //   },
                        // );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class AllUsersHorizontalView extends StatelessWidget {
  const AllUsersHorizontalView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatListedController controller =
        Get.put(ChatListedController()); // Make sure fetch is triggered

    final HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      //final RxList<Map<String, dynamic>> users = controller.allUsers;
      final RxList<UserModel> users = controller.allUsers;

      if (users.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(child: Text('No users found')),
        );
      }

      return SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final UserModel user = users[index];

            return Column(
              children: [
                InkWell(
                  onTap: () async {
                    String receiverId = user.uid;
                    String receiverName = user.name;
                    String receiverDeviceToken = user.deviceToken;

                    String receiverImageUrl = user.imageUrl;

                    String currentUserId =
                        FirebaseAuth.instance.currentUser?.uid ?? '';

                    String chatId = generateChatId(currentUserId, receiverId);
                    await Get.toNamed(
                      AppPages.CHAT,
                      arguments: {
                        'chatId': chatId,
                        'receiverId': receiverId,
                        'receiverName': receiverName,
                        'receiverImageUrl': receiverImageUrl,
                        'receiverDeviceToken': receiverDeviceToken,
                      },
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: user.imageUrl != ''
                            ? NetworkImage(user.imageUrl)
                            : const NetworkImage(
                                'https://sm.ign.com/ign_ap/cover/a/avatar-gen/avatar-generations_hugw.jpg',
                              ) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: -2,
                        child: Obx(
                          () => homeController.onlineUsers.contains(user.uid)
                              ? const CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.green,
                                )
                              : const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 70,
                  child: Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
