import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/message_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  final messages = <MessageModel>[].obs;
  final messageText = ''.obs;
  final isOtherTyping = false.obs;
  final otherLastSeen = ''.obs;
  final floatingEmoji = Rxn<String>();
  final ScrollController scrollController = ScrollController();
  final chatId = 'buyer_seller_123'; // Replace with real chatId
  final currentUserId = 'seller123'; // Replace with auth ID

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  Timer? _typingTimer;

  final editingMessageId = RxnString(); // null if not editing

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
    _listenToTyping();
    _listenToLastSeen();
    _startLastSeenTimer();
    ever(messages, (_) => scrollToBottom());
  }

  void _listenToMessages() {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
          snapshot.docs;

      for (final doc in docs) {
        final msg = MessageModel.fromJson(doc.data());
        if (msg.senderId != currentUserId && !msg.isRead) {
          doc.reference.update({
            'isRead': true,
            'readAt': DateTime.now().toIso8601String(),
          });
        }
      }

      messages.value =
          docs.map((doc) => MessageModel.fromJson(doc.data())).toList();
    });
  }

  // Future<void> sendMessage() async {
  //   final timestamp = DateTime.now();

  //   // Step 1: Create Firestore doc reference (but don’t set data yet)
  //   final DocumentReference<Map<String, dynamic>> docRef = _firestore
  //       .collection('chats')
  //       .doc(chatId)
  //       .collection('messages')
  //       .doc(); // generates a new ID but doesn’t save yet

  //   // Step 2: Create the message model with the generated ID
  //   final msg = MessageModel(
  //     id: docRef.id, // ✅ use generated Firestore ID
  //     senderId: currentUserId,
  //     text: messageText.value,
  //     timestamp: timestamp,
  //   );

  //   // Step 3: Save message to Firestore
  //   await docRef.set(msg.toJson());

  //   messageText.value = '';
  //   scrollToBottom();
  // }

  Future<void> sendMessage() async {
    final String text = messageText.value.trim();
    if (text.isEmpty) return;

    if (editingMessageId.value != null) {
      // Editing existing message
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(editingMessageId.value)
          .update({
        'text': text,
        'isEdited': true,
      });
      editingMessageId.value = null; // reset edit mode
    } else {
      // Sending new message
      final DocumentReference<Map<String, dynamic>> docRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(); // get new ID

      final msg = MessageModel(
        id: docRef.id,
        senderId: currentUserId,
        text: text,
        timestamp: DateTime.now(),
      );

      await docRef.set(msg.toJson());
    }

    messageText.value = '';
    scrollToBottom();
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final Reference ref = _storage.ref(
      'chat_images/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile(File(picked.path));
    final String imageUrl = await ref.getDownloadURL();

    // Step 1: Create Firestore doc reference (but don’t set data yet)
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(); // generates a new ID but doesn’t save yet

    // Step 2: Create the message model with the generated ID
    final msg = MessageModel(
      id: docRef.id, // ✅ use generated Firestore ID
      senderId: currentUserId,
      text: '',
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    // Step 3: Save message to Firestore
    await docRef.set(msg.toJson());
  }

  void updateTypingStatus(bool isTyping) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('status')
        .doc('typing')
        .set({currentUserId: isTyping}, SetOptions(merge: true));

    _typingTimer?.cancel();

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _firestore
            .collection('chats')
            .doc(chatId)
            .collection('status')
            .doc('typing')
            .set({currentUserId: false}, SetOptions(merge: true));
      });
    }
  }

  void _listenToTyping() {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('status')
        .doc('typing')
        .snapshots()
        .listen((doc) {
      final String? otherId = doc.data()?.keys.firstWhere(
            (k) => k != currentUserId,
            orElse: () => '',
          );
      if (otherId!.isNotEmpty) {
        isOtherTyping.value = doc.data()![otherId] == true;
      }
    });
  }

  Future<void> toggleReaction(String messageId, String emoji) async {
    try {
      final DocumentReference<Map<String, dynamic>> ref = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);
      final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();

      final reactions = Map<String, String>.from(snap['reactions'] ?? {});
      if (reactions[currentUserId] == emoji) {
        reactions.remove(currentUserId);
      } else {
        reactions[currentUserId] = emoji;
      }

      await ref.update({'reactions': reactions});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'text': newText,
      'isEdited': true,
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  void _listenToLastSeen() {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('status')
        .doc('presence')
        .snapshots()
        .listen((doc) {
      final Map<String, dynamic>? data = doc.data();
      final String? otherId =
          data?.keys.firstWhere((k) => k != currentUserId, orElse: () => '');
      if (otherId!.isNotEmpty) otherLastSeen.value = data![otherId];
    });
  }

  void _startLastSeenTimer() {
    Timer.periodic(const Duration(seconds: 30), (_) {
      _firestore
          .collection('chats')
          .doc(chatId)
          .collection('status')
          .doc('presence')
          .set(
        {currentUserId: DateTime.now().toIso8601String()},
        SetOptions(merge: true),
      );
    });
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
