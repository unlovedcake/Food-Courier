import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/message_model.dart';
import 'package:food_courier/app/widgets/emoji_reaction_bar.dart';
import 'package:food_courier/app/widgets/floating_emoji.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});
  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        foregroundColor: Colors.black,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        title: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    backgroundImage: controller.receiverImageUrl.isNotEmpty
                        ? NetworkImage(controller.receiverImageUrl)
                        : const NetworkImage(
                            'https://www.shutterstock.com/image-vector/vector-flat-illustration-grayscale-avatar-600nw-2264922221.jpg',
                          ) as ImageProvider,
                    radius: 20,
                  ),
                  if (controller.isOtherUserOnline.value)
                    Positioned(
                      bottom: 0,
                      right: -2,
                      child: Obx(
                        () => CircleAvatar(
                          radius: 5,
                          backgroundColor: controller.isOtherUserOnline.value
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                controller.receiverName,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     const Text('Chat'),
          //     if (controller.isOtherUserOnline.value)
          //       const Text('🟢 Online', style: TextStyle(fontSize: 12))
          //     else
          //       Text(
          //         'Last seen: ${controller.lastSeenText.value}',
          //         style: const TextStyle(fontSize: 12, color: Colors.white),
          //       ),
          //   ],
          // ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Obx(
                () => controller.otherLastSeen.isNotEmpty
                    ? Text('Last seen: ${controller.otherLastSeen.value}')
                    : const SizedBox(),
              ),
              Obx(
                () => controller.isOtherTyping.value
                    ? const Text('Typing...')
                    : const SizedBox(),
              ),
              Expanded(
                child: Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      controller: controller.scrollController,
                      itemCount: controller.messages.length,
                      itemBuilder: (_, index) {
                        if (index == controller.messages.length) {
                          // 🔄 Loading spinner at the top
                          return Obx(
                            () => controller.isFetchingMoreObs.value
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox(),
                          );
                        }
                        final MessageModel msg = controller.messages[index];
                        final isMe = msg.senderId == controller.currentUserId;

                        String dateString = msg.createAd.toString();
                        DateTime dateTime = DateTime.parse(dateString);
                        int timestampMillis = dateTime.millisecondsSinceEpoch;

                        final lastSeenTime =
                            DateTime.fromMillisecondsSinceEpoch(
                          int.parse(timestampMillis.toString()),
                        );

                        bool isLastOfGroup = true;
                        if (index < controller.messages.length - 1) {
                          final MessageModel nextMsg =
                              controller.messages[index + 1];
                          if (nextMsg.senderId == msg.senderId) {
                            final String currentTime =
                                DateFormat('hh:mm a').format(msg.createAd);
                            final String nextTime =
                                DateFormat('hh:mm a').format(nextMsg.createAd);

                            if (currentTime == nextTime) {
                              isLastOfGroup = false;
                            }
                          } else {
                            isLastOfGroup = true;
                          }
                        }

                        return GestureDetector(
                          onLongPress: () async {
                            if (msg.isDeleted) {
                              return;
                            }
                            if (msg.senderId == controller.currentUserId) {
                              await showModalBottomSheet(
                                context: context,
                                builder: (_) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text('Edit'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        controller.messageText.value = msg.text;
                                        controller.editingMessageId.value =
                                            msg.id;
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Delete'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await controller.deleteMessage(msg.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Show emoji reaction bar
                              unawaited(
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => EmojiReactionBar(
                                    onReactionSelected: (emoji) async {
                                      controller.floatingEmoji.value = emoji;
                                      await controller.toggleReaction(
                                        msg.id,
                                        emoji,
                                      );
                                      Future.delayed(
                                        const Duration(milliseconds: 800),
                                        () => controller.floatingEmoji.value =
                                            null,
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Align(
                                  key: ValueKey(
                                    msg.createAd.toIso8601String(),
                                  ),
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: Get.width * 0.7,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(1.5),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: isMe
                                                ? BorderRadius.only(
                                                    topLeft:
                                                        const Radius.circular(
                                                      14,
                                                    ),
                                                    topRight: Radius.circular(
                                                      isLastOfGroup ? 2 : 14,
                                                    ),
                                                    bottomLeft: isMe
                                                        ? const Radius.circular(
                                                            14,
                                                          )
                                                        : const Radius.circular(
                                                            2,
                                                          ),
                                                    bottomRight:
                                                        Radius.circular(
                                                      isLastOfGroup ? 14 : 2,
                                                    ),
                                                  )
                                                : BorderRadius.only(
                                                    topRight:
                                                        const Radius.circular(
                                                      14,
                                                    ),
                                                    topLeft: Radius.circular(
                                                      isLastOfGroup ? 2 : 14,
                                                    ),
                                                    bottomLeft: isMe
                                                        ? const Radius.circular(
                                                            14,
                                                          )
                                                        : Radius.circular(
                                                            isLastOfGroup
                                                                ? 14
                                                                : 2,
                                                          ),
                                                    bottomRight:
                                                        const Radius.circular(
                                                      14,
                                                    ),
                                                  ),
                                            color: isMe
                                                ? Colors.white
                                                : Colors.grey[300],
                                          ),
                                          child: Column(
                                            children: [
                                              if (msg.imageUrl != null ||
                                                  msg.imageUrl == '')
                                                Image.network(msg.imageUrl!)
                                              else
                                                Text(
                                                  !msg.isDeleted
                                                      ? msg.text
                                                      : isMe
                                                          ? 'You unsent a message'
                                                          : 'User unsent the message',
                                                  style: TextStyle(
                                                    fontStyle: !msg.isDeleted
                                                        ? null
                                                        : FontStyle.italic,
                                                    color: msg.isDeleted
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (msg.reactions.isNotEmpty)
                                        if (msg.reactions.isNotEmpty)
                                          Positioned(
                                            bottom: -8,
                                            left: isMe ? -10 : null,
                                            right: isMe ? null : -10,
                                            child: Wrap(
                                              children: msg.reactions.values
                                                  .toSet()
                                                  .map(
                                                    (e) => InkWell(
                                                      onTap: () async {
                                                        if (!msg.reactions.keys
                                                            .contains(
                                                          controller
                                                              .currentUserId,
                                                        )) {
                                                          return;
                                                        }
                                                        await controller
                                                            .toggleReaction(
                                                          msg.id,
                                                          e,
                                                        );
                                                      },
                                                      child: Obx(() {
                                                        final double scale =
                                                            controller.reactionScales[
                                                                    msg.id] ??
                                                                1.0;
                                                        return AnimatedScale(
                                                          scale: scale,
                                                          duration:
                                                              const Duration(
                                                            milliseconds: 150,
                                                          ),
                                                          curve:
                                                              Curves.easeInOut,
                                                          child: Text(
                                                            ' $e ',
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isLastOfGroup)
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('MMM d, y h:mm a')
                                            .format(msg.createAd),
                                        //controller.formatLastSeen(lastSeenTime),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: controller.sendImage,
                      icon: const Icon(Icons.image),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      final isEditing =
                          controller.editingMessageId.value != null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditing)
                              Row(
                                children: [
                                  const Text(
                                    'Editing...',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      controller.editingMessageId.value = null;
                                      controller.messageText.value = '';
                                    },
                                    child: const Icon(Icons.close, size: 18),
                                  ),
                                ],
                              ),
                            SizedBox(height: isEditing ? 8 : 0),
                            TextField(
                              onChanged: (val) {
                                controller.messageText.value = val;
                                controller.updateTypingStatus(val.isNotEmpty);
                              },
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: controller.messageText.value,
                                  selection: TextSelection.collapsed(
                                    offset: controller.messageText.value.length,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText: 'Type message...',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  // Expanded(
                  //   child: Obx(
                  //     () => TextField(
                  //       onChanged: (val) {
                  //         controller.messageText.value = val;
                  //         controller.updateTypingStatus(val.isNotEmpty);
                  //       },
                  //       controller: TextEditingController.fromValue(
                  //         TextEditingValue(
                  //           text: controller.messageText.value,
                  //           selection: TextSelection.collapsed(
                  //             offset: controller.messageText.value.length,
                  //           ),
                  //         ),
                  //       ),
                  //       decoration: const InputDecoration(
                  //         hintText: 'Type message...',
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: controller.sendMessage,
                      icon: const Icon(Icons.send),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
          Obx(
            () => controller.floatingEmoji.value != null
                ? Positioned(
                    bottom: 80,
                    right: 50,
                    child:
                        FloatingEmoji(emoji: controller.floatingEmoji.value!),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
