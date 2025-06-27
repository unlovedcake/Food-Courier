import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/presence_service.dart';
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
  final currentUserId = 'buyer123'; // Replace with auth ID

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  Timer? _typingTimer;

  final editingMessageId = RxnString(); // null if not editing

  final isOtherUserOnline = false.obs;
  final lastSeenText = ''.obs;

  final String otherUserId = 'seller123';

  StreamSubscription<DatabaseEvent>? _presenceSub;

  DocumentSnapshot? lastDocument;
  bool isFetchingMore = false;
  bool hasMore = true;

  final isFetchingMoreObs = false.obs;

  MessageModel? _lastObservedMessage;

  @override
  void onInit() {
    super.onInit();
    loadInitialMessages();

    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        // User scrolled to top
        await loadMoreMessages(scrollController: scrollController);
      }
    });
    // _listenToMessages();
    _listenToTyping();
    _listenToLastSeen();
    //_startLastSeenTimer();
    //ever(messages, (_) => scrollToBottom());
    // Start smart message scroll tracker
    debounce(
      messages,
      (_) => _onMessagesChanged(),
      time: const Duration(milliseconds: 100),
    );

    _startPresenceTracking();
    _listenToOtherUserPresence();
  }

  @override
  void onClose() {
    _presenceSub?.cancel(); // ✅ Stop listening
    super.onClose();
  }

  void _onMessagesChanged() {
    if (messages.isEmpty) return;

    final MessageModel latest = messages.last;

    // If last message is newer than previous
    if (_lastObservedMessage == null || latest.id != _lastObservedMessage!.id) {
      final isMyMessage = latest.senderId == currentUserId;

      // ✅ Only scroll if it's a new message at the bottom (not from top prepend)
      if (isMyMessage || _isNearBottom()) {
        scrollToBottom();
      }

      _lastObservedMessage = latest;
    }
  }

  bool _isNearBottom({double threshold = 100}) {
    if (!scrollController.hasClients) return false;
    final ScrollPosition position = scrollController.position;
    return position.maxScrollExtent - position.pixels <= threshold;
  }

  void _startPresenceTracking() {
    PresenceService(userId: currentUserId).setupPresenceTracking();
  }

  void _listenToOtherUserPresence() {
    _presenceSub?.cancel(); // cleanup before subscribing again

    final DatabaseReference otherRef =
        FirebaseDatabase.instance.ref('status/$otherUserId');
    _presenceSub = otherRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      isOtherUserOnline.value = data['online'] ?? false;

      if (data['lastSeen'] != null) {
        final lastSeenMs = data['lastSeen'];
        final lastSeenTime = DateTime.fromMillisecondsSinceEpoch(
          lastSeenMs is int ? lastSeenMs : int.parse(lastSeenMs.toString()),
        );
        lastSeenText.value = _formatLastSeen(lastSeenTime);
      }
    });
  }

  String _formatLastSeen(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  Future<void> loadInitialMessages() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;

        final List<MessageModel> msgs = snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList();

        messages.assignAll(msgs.reversed.toList());
        // ✅ Wait for layout then scroll
        Future.delayed(const Duration(milliseconds: 100), () {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });
      } else {
        hasMore = false;
      }

      // Real-time listener for new messages after initial load
      _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final latest = MessageModel.fromJson(snapshot.docs.first.data());
          if (!messages.any((m) => m.id == latest.id)) {
            messages.add(latest);
          }
        }
      });
    } catch (e) {
      debugPrint('Fetch Initial Mesages $e');
    }
  }

  Future<void> loadMoreMessages({ScrollController? scrollController}) async {
    if (isFetchingMore || !hasMore || lastDocument == null) return;
    isFetchingMore = true;
    isFetchingMoreObs.value = true;

    final double beforeHeight = scrollController?.position.extentAfter ?? 0;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument!)
        .limit(20)
        .get();

    if (snapshot.docs.isEmpty) {
      hasMore = false;
    } else {
      lastDocument = snapshot.docs.last;

      final List<MessageModel> more = snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();

      messages.insertAll(0, more.reversed.toList());

      // 🔁 Scroll offset compensation
      await Future.delayed(const Duration(milliseconds: 50)); // wait layout
      final double afterHeight = scrollController?.position.extentAfter ?? 0;
      final double diff = afterHeight - beforeHeight;
      scrollController?.jumpTo(scrollController.offset + diff);
    }

    isFetchingMore = false;
    isFetchingMoreObs.value = false;
  }

  // Future<void> loadMoreMessages() async {
  //   if (isFetchingMore || !hasMore || lastDocument == null) {
  //     print('NO more');
  //     return;
  //   }
  //   isFetchingMore = true;

  //   final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
  //       .collection('chats')
  //       .doc(chatId)
  //       .collection('messages')
  //       .orderBy('timestamp', descending: true)
  //       .startAfterDocument(lastDocument!)
  //       .limit(10)
  //       .get();

  //   if (snapshot.docs.isEmpty) {
  //     hasMore = false;
  //   } else {
  //     lastDocument = snapshot.docs.last;

  //     final List<MessageModel> more = snapshot.docs
  //         .map((doc) => MessageModel.fromJson(doc.data()))
  //         .toList();

  //     // Prepend to current messages
  //     messages.insertAll(0, more.reversed.toList());
  //   }

  //   isFetchingMore = false;
  // }

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
      if (otherId!.isNotEmpty) {
        otherLastSeen.value = data![otherId];

        print('otherLastSeen $otherLastSeen');
      }

      String dateString = otherLastSeen.toString();
      DateTime dateTime = DateTime.parse(dateString);
      int timestampMillis = dateTime.millisecondsSinceEpoch;

      final lastSeenTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(timestampMillis.toString()),
      );

      otherLastSeen.value = _formatLastSeen(lastSeenTime);
    });
  }

  // void _startLastSeenTimer() {
  //   Timer.periodic(const Duration(seconds: 30), (_) {
  //     _firestore
  //         .collection('chats')
  //         .doc(chatId)
  //         .collection('status')
  //         .doc('presence')
  //         .set(
  //       {currentUserId: DateTime.now().toIso8601String()},
  //       SetOptions(merge: true),
  //     );
  //   });
  // }

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
