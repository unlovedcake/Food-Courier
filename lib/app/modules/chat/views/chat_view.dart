import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/message_model.dart';
import 'package:food_courier/app/widgets/emoji_reaction_bar.dart';
import 'package:food_courier/app/widgets/floating_emoji.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});
  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
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
                  () => ListView.builder(
                    controller: controller.scrollController,
                    itemCount: controller.messages.length,
                    itemBuilder: (_, index) {
                      final MessageModel msg = controller.messages[index];
                      final isMe = msg.senderId == controller.currentUserId;

                      return GestureDetector(
                        onLongPress: () async {
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
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => EmojiReactionBar(
                                onReactionSelected: (emoji) {
                                  controller.floatingEmoji.value = emoji;
                                  controller.toggleReaction(msg.id, emoji);
                                  Future.delayed(
                                    const Duration(milliseconds: 800),
                                    () => controller.floatingEmoji.value = null,
                                  );
                                },
                              ),
                            );
                          }
                          // showModalBottomSheet(
                          //   context: context,
                          //   builder: (_) => EmojiReactionBar(
                          //     onReactionSelected: (emoji) {
                          //       controller.floatingEmoji.value = emoji;
                          //       controller.toggleReaction(
                          //         msg.id,
                          //         emoji,
                          //       );
                          //       Future.delayed(
                          //         const Duration(milliseconds: 800),
                          //         () => controller.floatingEmoji.value = null,
                          //       );
                          //     },
                          //   ),
                          // );
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Align(
                            key: ValueKey(msg.timestamp.toIso8601String()),
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.all(isMe ? 1 : 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blue[100] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (msg.imageUrl != null)
                                    Image.network(msg.imageUrl!)
                                  else
                                    Text(msg.text),
                                  if (msg.reactions.isNotEmpty)
                                    Wrap(
                                      children: msg.reactions.values
                                          .toSet()
                                          .map((e) => Text(' $e '))
                                          .toList(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: controller.sendImage,
                    icon: const Icon(Icons.image),
                  ),
                  Expanded(
                    child: Obx(() {
                      final isEditing =
                          controller.editingMessageId.value != null;
                      return Column(
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
                            maxLines: null, // ✅ Allows unlimited lines
                            textInputAction: TextInputAction
                                .newline, // ✅ Keeps Enter key as newline
                            decoration: const InputDecoration(
                              hintText: 'Type message...',
                            ),
                          ),
                        ],
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
                  IconButton(
                    onPressed: controller.sendMessage,
                    icon: const Icon(Icons.send),
                  ),
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
