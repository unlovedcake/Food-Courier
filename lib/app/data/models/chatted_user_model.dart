// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChattedUserModel {
//   ChattedUserModel({
//     required this.chatId,
//     required this.receiverId,
//     required this.senderId,
//     required this.receiverName,
//     required this.isRead,
//     required this.profileImage,
//     required this.lastMessage,
//     required this.createdAt,
//   });
//   final String chatId;
//   final String receiverId;
//   final String senderId;
//   final String receiverName;
//   final bool isRead;
//   final String profileImage;
//   final String lastMessage;
//   final Timestamp createdAt;
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class ChattedUserModel {
  ChattedUserModel({
    required this.users,
    required this.sender,
    required this.receiver,
    required this.deviceTOken,
    required this.chatId,
    required this.isRead,
    required this.lastMessage,
    required this.createdAt,
    this.isDeleted = false, // Default value, can be updated later
  });

  factory ChattedUserModel.fromFirestore(
    Map<String, dynamic> data,
    String currentUserId,
  ) {
    final users = List<String>.from(data['users'] ?? []);
    final String otherUserId =
        users.firstWhere((id) => id != currentUserId, orElse: () => '');

    final senderData = Map<String, dynamic>.from(data['sender'] ?? {});
    final receiverData = Map<String, dynamic>.from(data['receiver'] ?? {});

    return ChattedUserModel(
      users: users,
      chatId: data['chatId'] as String? ?? '',
      deviceTOken: data['deviceTOken'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sender: Sender(
        senderId: senderData['senderId'] ?? '',
        senderName: senderData['senderName'] ?? '',
        senderImage: senderData['senderImage'] ?? '',
      ),
      receiver: Receiver(
        receiverId: receiverData['receiverId'] ?? '',
        receiverName: receiverData['receiverName'] ?? '',
        receiverImage: receiverData['receiverImage'] ?? '',
      ),
    );
  }
  final List<String> users;
  final Sender sender;
  final Receiver receiver;
  final String chatId;
  final String deviceTOken;
  final bool isRead;
  bool isDeleted; // Default value, can be updated later
  final String lastMessage;
  final DateTime createdAt;
}

class Sender {
  Sender({
    required this.senderId,
    required this.senderName,
    required this.senderImage,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderImage: json['senderImage'] ?? '',
    );
  }
  final String senderId;
  final String senderName;
  final String senderImage;

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
    };
  }
}

class Receiver {
  Receiver({
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverImage: json['receiverImage'] ?? '',
    );
  }
  final String receiverId;
  final String receiverName;
  final String receiverImage;

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverImage': receiverImage,
    };
  }
}
