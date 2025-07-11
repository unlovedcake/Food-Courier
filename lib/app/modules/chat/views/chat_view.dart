import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
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
          () => Column(
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
                    radius: 15,
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
                              Align(
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
                                        maxWidth: Get.width * 0.8,
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
                                                  bottomRight: Radius.circular(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (msg.imageUrl != '')
                                              !msg.isDeleted
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      spacing: 5,
                                                      children: [
                                                        ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                            maxWidth:
                                                                Get.width / 2,
                                                            minWidth:
                                                                Get.width / 2,
                                                            maxHeight: 200,
                                                            minHeight: 200,
                                                          ),
                                                          child:
                                                              CachedNetworkImage(
                                                            fit: BoxFit.contain,
                                                            imageUrl:
                                                                msg.imageUrl ??
                                                                    '',
                                                            progressIndicatorBuilder: (
                                                              context,
                                                              url,
                                                              downloadProgress,
                                                            ) =>
                                                                CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress,
                                                            ),
                                                            errorWidget: (
                                                              context,
                                                              url,
                                                              error,
                                                            ) =>
                                                                const Icon(
                                                              Icons.error,
                                                            ),
                                                          ),
                                                        ),
                                                        if (msg.text != '')
                                                          Text(
                                                            msg.text,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          )
                                                        else
                                                          const SizedBox
                                                              .shrink(),
                                                      ],
                                                    )
                                                  : Text(
                                                      isMe
                                                          ? 'You unsent a message'
                                                          : 'User unsent the message',
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    )
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
                                                      controller.currentUserId,
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
                                                            1.2;
                                                    return AnimatedScale(
                                                      scale: scale,
                                                      duration: const Duration(
                                                        milliseconds: 150,
                                                      ),
                                                      curve: Curves.easeInOut,
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
              Obx(() {
                return controller.editingMessageId.value != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
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
                      )
                    : controller.imageBytes.value != null
                        ? InkWell(
                            onTap: () {
                              controller.imageBytes.value = null;
                              controller.selectedImageUrl.value = '';
                              controller.fileImage.value = null;
                              controller.imageFile.value = null;
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.memory(
                                  controller.imageBytes.value ?? Uint8List(0),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                const Icon(Icons.close, size: 18),
                              ],
                            ),
                          )
                        : const SizedBox();
              }),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: controller.selectImage,
                      icon: const Icon(Icons.image),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => TextField(
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
                          ),
                        ],
                      ),
                    ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        if (controller.imageBytes.value == null) {
                          await controller.sendMessage(
                            controller.editingMessageId.value ?? '',
                          );
                        } else {
                          await controller.sendImage();
                        }
                      },
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
