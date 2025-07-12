import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:food_courier/app/data/models/message_model.dart';
import 'package:food_courier/app/modules/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class ChatController extends GetxController {
  final messages = <MessageModel>[].obs;
  final messageText = ''.obs;
  final isOtherTyping = false.obs;
  final otherLastSeen = ''.obs;
  final floatingEmoji = Rxn<String>();
  final ScrollController scrollController = ScrollController();
  String chatId = ''; // Replace with real chatId

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  Timer? _typingTimer;

  final editingMessageId = RxnString(); // null if not editing

  final lastSeenText = ''.obs;

  final isLoading = false.obs;

  final isScrolling = false.obs;

  // final String receiverId =
  //     '4qYtKhUwkWheyGMeQ4BzeWzSVMq1'; //ataJQe5vGYafW9Ay7QfVbGt2L453';

  StreamSubscription<DatabaseEvent>? _presenceSub;

  DocumentSnapshot? lastDocument;

  bool hasMore = true;

  final isFetchingMoreObs = false.obs;

  final arguments = Get.arguments as Map<String, dynamic>;

  String receiverImageUrl = '';
  String receiverName = '';
  String receiverId = '';
  String receiverDeviceToken = '';
  String currentUserId = '';

  final User? user = FirebaseAuth.instance.currentUser;

  final supabase = supa.Supabase.instance.client;

  final selectedImageUrl = ''.obs;

  final _db = FirebaseDatabase.instance.ref();

  @override
  void onInit() {
    super.onInit();

    currentUserId = user?.uid ?? '';

    chatId = arguments['chatId'];
    receiverId = arguments['receiverId'];
    receiverName = arguments['receiverName'];
    receiverImageUrl = arguments['receiverImageUrl'];
    receiverDeviceToken = arguments['receiverDeviceToken'];

    //Future.microtask(loadInitialMessages);
    loadInitialMessages();

    isUserInChatPage(true);

    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
              scrollController.position.minScrollExtent &&
          !isFetchingMoreObs.value) {
        // User scrolled to top
        await loadMoreMessages(scrollController: scrollController);
      }
    });
    _listenToOtherUserPresence();
    _listenToMessages();
    _listenToTyping();

    //_listenToLastSeen();
    //_startLastSeenTimer();
    //ever(messages, (_) => scrollToBottom());
    // Start smart message scroll tracker
    // debounce(
    //   messages,
    //   (_) => _onMessagesChanged(),
    //   time: const Duration(milliseconds: 100),
    // );
  }

  @override
  Future<void> onClose() async {
    await _presenceSub?.cancel(); // ✅ Stop listening

    await isUserInChatPage(false);

    debugPrint('OnCLose');
    super.onClose();
  }

  final RxBool isChatPage = false.obs;
  final RxBool isOnline = false.obs;

  Future<void> isUserInChatPage(bool isUserInChatPage) async {
    final DatabaseReference userRef = _db.child('status/$currentUserId');

    await userRef.update({
      'isChatPage': isUserInChatPage,
    });
  }

  void _listenToOtherUserPresence() {
    _presenceSub?.cancel().ignore(); // cleanup before subscribing again

    final DatabaseReference otherRef =
        FirebaseDatabase.instance.ref('status/$receiverId');
    _presenceSub = otherRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      isChatPage.value = data['isChatPage'] ?? false;
      isOnline.value = data['online'] ?? false;
    });
  }

  String formatLastSeen(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hr ago';
    }
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  Future<void> loadInitialMessages() async {
    isLoading.value = true;
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createAd', descending: true)
          .limit(10)
          .get();

      if (snapshot.docs.isEmpty) {
        Log.error('No messages found for chatId: $chatId');
        return;
      }

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;

        final List<MessageModel> msgs = snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList();

        messages.assignAll(msgs.reversed.toList());

        // ✅ Wait for layout then scroll
        // Future.delayed(const Duration(milliseconds: 100), () {
        //   if (scrollController.hasClients) {
        //     scrollController.jumpTo(scrollController.position.maxScrollExtent);
        //   }
        // });
        scrollToBottom();
        Log.success(
          'Initial Messages Loaded...',
        );
      } else {
        hasMore = false;
      }

      // // Real-time listener for new messages after initial load
      // _firestore
      //     .collection('chats')
      //     .doc(chatId)
      //     .collection('messages')
      //     .orderBy('createAd', descending: true)
      //     .limit(1)
      //     .snapshots()
      //     .listen((snapshot) {
      //   if (snapshot.docs.isNotEmpty) {
      //     final latest = MessageModel.fromJson(snapshot.docs.first.data());
      //     if (!messages.any((m) => m.id == latest.id)) {
      //       messages.add(latest);
      //     }
      //   }
      // });
    } catch (e) {
      Log.error('Error Fetch Initial Mesages $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreMessages({ScrollController? scrollController}) async {
    if (isFetchingMoreObs.value || !hasMore || lastDocument == null) {
      return;
    }

    isFetchingMoreObs.value = true;

    final double beforeHeight = scrollController?.position.extentAfter ?? 0;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createAd', descending: true)
        .startAfterDocument(lastDocument!)
        .limit(10)
        .get();

    if (snapshot.docs.isEmpty) {
      hasMore = false;

      Log.info(
        'No more messages to load for chatId: $chatId',
      );

      isFetchingMoreObs.value = false;
    } else {
      lastDocument = snapshot.docs.last;

      final List<MessageModel> more = snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();

      messages.insertAll(0, more.reversed.toList());

      // 🔁 Scroll offset compensation
      // await Future.delayed(const Duration(milliseconds: 50)); // wait layout
      // final double afterHeight = scrollController?.position.extentAfter ?? 0;
      // final double diff = afterHeight - beforeHeight;
      // scrollController?.jumpTo(scrollController.offset + diff);
      await Future.delayed(const Duration(milliseconds: 50)); // wait layout
      scrollController?.jumpTo(scrollController.offset + Get.height / 2);
    }

    Log.info(
      'Loaded ${messages.length} more messages for chatId: $chatId',
    );

    isFetchingMoreObs.value = false;
  }

  void _listenToMessages() {
    // // Real-time listener for new messages after initial load
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createAd', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final latest = MessageModel.fromJson(snapshot.docs.first.data());
        if (!messages.any((m) => m.id == latest.id)) {
          messages.add(latest);
          scrollToBottom();
        }
      }
    });
    // _firestore
    //     .collection('chats')
    //     .doc(chatId)
    //     .collection('messages')
    //     .orderBy('createAd', descending: false)
    //     .snapshots()
    //     .listen((snapshot) {
    //   final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
    //       snapshot.docs;

    //   messages.value =
    //       docs.map((doc) => MessageModel.fromJson(doc.data())).toList();
    // });
  }

  Future<void> sendMessage(String messageId) async {
    try {
      isScrolling.value = false; // reset toggle reaction state
      final String text = messageText.value.trim();
      if (text.isEmpty) {
        return;
      }

      if (editingMessageId.value != null) {
        isScrolling.value = true;
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

        // Update the message in local list
        int index = messages.indexWhere((msg) => msg.id == messageId);
        if (index != -1) {
          final MessageModel updatedMessage =
              messages[index].copyWith(text: text);
          messages[index] = updatedMessage;
        }
      } else {
        final DocumentReference<Map<String, dynamic>> chatDoc =
            _firestore.collection('chats').doc(chatId);
        // Sending new message
        final DocumentReference<Map<String, dynamic>> docRef = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(); // get new ID

        await docRef.set({
          'id': docRef.id,
          'senderId': currentUserId,
          'text': text,
          'imageUrl': '',
          'isRead': isChatPage.value,
          'isEdited': false,
          'isDeleted': false,
          'reactions': {},
          'createAd': FieldValue.serverTimestamp(),
        });

        await chatDoc.set(
          {
            'chatId': chatId,
            'users': [currentUserId, receiverId],
            'lastMessage': text,
            'isRead': isChatPage.value,
            'deviceToken': receiverDeviceToken,
            'isDeleted': false,
            'createdAt': FieldValue.serverTimestamp(),
            'sender': {
              'senderId': currentUserId,
              'senderName': user?.displayName ?? '',
              'senderImage': user?.photoURL ??
                  'https://militaryhealthinstitute.org/wp-content/uploads/sites/37/2021/08/blank-profile-picture-png.png',
            },
            'receiver': {
              'receiverId': receiverId,
              'receiverName': receiverName,
              'receiverImage': receiverImageUrl,
            },
          },
          SetOptions(merge: true),
        );
      }

      messageText.value = '';
      //scrollToBottom();

      // if receiver is offline trigger notification
      if (!isOnline.value) {
        if (receiverDeviceToken != '') {
          await FCM().sendPushNotification(
            deviceToken: receiverDeviceToken,
            title: user?.displayName ?? '',
            body: text,
            data: {
              'chatId': chatId,
              'senderId': currentUserId,
              'receiverId': receiverId,
              'type': 'private chat',
            },
          );
        }
      }
    } on Exception catch (e) {
      Log.error('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
  }

  Rx<File?> imageFile = Rx<File?>(null);

  Rx<XFile?> fileImage = Rx<XFile?>(null);
  Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);

  Future<void> selectImage() async {
    final picker = ImagePicker();
    fileImage.value = await picker.pickImage(source: ImageSource.gallery);

    final XFile? file = fileImage.value;
    if (file != null) {
      imageBytes.value = await file.readAsBytes();
    }

    Log.info('Selected image: ${fileImage.value?.path}');
  }

  Future<void> sendImage() async {
    isScrolling.value = false; // reset toggle reaction state
    try {
      if (fileImage.value == null) {
        return;
      }

      String filePath = fileImage.value?.path ?? '';
      // Get full path

// Get file name with extension
      String fileName = filePath.split('/').last;

// Get extension
      String extension = fileName.contains('.') ? fileName.split('.').last : '';

      imageFile.value = File(fileImage.value?.path ?? '');

      await supabase.storage.from('bucket-shop-swift').upload(
            'chat/$fileName',
            imageFile.value ?? File(''),
            fileOptions: supa.FileOptions(
              contentType: 'image/$extension',
            ),
          );

      // Get public URL
      selectedImageUrl.value = supabase.storage
          .from('bucket-shop-swift')
          .getPublicUrl('chat/$fileName');
      selectedImageUrl.value = Uri.parse(selectedImageUrl.value).replace(
        queryParameters: {
          't': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      ).toString();

      final String text = messageText.value.trim();
      // await ref.putFile(File(fileImage.path));
      // final String imageUrl = await ref.getDownloadURL();

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
        text: text,
        imageUrl: selectedImageUrl.value,
        createAd: DateTime.now(),
      );

      // Step 3: Save message to Firestore
      await docRef.set(msg.toJson());
      messageText.value = '';
      imageFile.value = null;
      imageBytes.value = null;
      selectedImageUrl.value = '';
      fileImage.value = null;
    } catch (e) {
      Log.error('Error sending image: $e');
      Get.snackbar(
        'Error',
        'Failed to send image. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
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

  final RxMap<String, double> reactionScales = <String, double>{}.obs;

  Future<void> toggleReaction(String messageId, String emoji) async {
    isScrolling.value = true;
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

        reactionScales[messageId] = 1.5;
      }

      await ref.update({'reactions': reactions});

      final int index = messages.indexWhere((msg) => msg.id == messageId);
      if (index == -1) {
        Log.error('OIY');
        return;
      }

      final MessageModel message = messages[index];

      final updatedReactions = Map<String, dynamic>.from(message.reactions);

      // If current user's reaction matches the tapped emoji, remove it
      if (updatedReactions[currentUserId] == emoji) {
        updatedReactions.remove(currentUserId);
      } else {
        // Optional: Set a new emoji
        updatedReactions[currentUserId] = emoji;
      }

      final MessageModel updatedMessage =
          message.copyWith(reactions: updatedReactions);
      messages[index] = updatedMessage;
    } on Exception catch (e) {
      Log.error('Error: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 200), () {
        reactionScales[messageId] = 1.2;
      });
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
    try {
      // await _firestore
      //     .collection('chats')
      //     .doc(chatId)
      //     .collection('messages')
      //     .doc(messageId)
      //     .delete();

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isDeleted': true,
      });

      await _firestore.collection('chats').doc(chatId).update({
        'isDeleted': true,
      });
    } on Exception catch (e) {
      Log.error('Error deleting message: $e');
      Get.snackbar(
        'Error',
        'Failed to delete message. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
  }

  // void _listenToLastSeen() {
  //   _firestore
  //       .collection('chats')
  //       .doc(chatId)
  //       .collection('status')
  //       .doc('presence')
  //       .snapshots()
  //       .listen((doc) {
  //     final Map<String, dynamic>? data = doc.data();
  //     final String? otherId =
  //         data?.keys.firstWhere((k) => k != currentUserId, orElse: () => '');
  //     if (otherId!.isNotEmpty) {
  //       otherLastSeen.value = data![otherId];

  //       Log.info('otherLastSeen $otherLastSeen');
  //     }

  //     String dateString = otherLastSeen.toString();
  //     DateTime dateTime = DateTime.parse(dateString);
  //     int timestampMillis = dateTime.millisecondsSinceEpoch;

  //     final lastSeenTime = DateTime.fromMillisecondsSinceEpoch(
  //       int.parse(timestampMillis.toString()),
  //     );

  //     otherLastSeen.value = formatLastSeen(lastSeenTime);
  //   });
  // }

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
      if (scrollController.hasClients && !isScrolling.value) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
