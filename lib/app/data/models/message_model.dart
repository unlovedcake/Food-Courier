import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createAd,
    this.imageUrl,
    this.isDeleted = false,
    this.reactions = const {},
    this.isEdited = false,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      isRead: json['isRead'] ?? false,
      createAd: (json['createAd'] as Timestamp?)?.toDate() ?? DateTime.now(),

      //createAd: (json['createAd'] as Timestamp).toDate(),

      reactions: Map<String, String>.from(json['reactions'] ?? {}),
      isEdited: json['isEdited'] ?? false,
    );
  }
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final bool isDeleted;
  final bool isRead;
  final DateTime createAd;

  final Map<String, String> reactions;
  final bool isEdited;

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'isDeleted': isDeleted,
        'isRead': isRead,
        'createAd': createAd,
        'reactions': reactions,
        'isEdited': isEdited,
      };

  MessageModel copyWith({
    String? text,
    String? imageUrl,
    bool? isDeleted,
    DateTime? createAd,
    Map<String, dynamic>? reactions,
    bool? isEdited,
    bool? isRead,
  }) {
    return MessageModel(
      id: id,
      senderId: senderId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      isRead: isRead ?? this.isRead,
      createAd: createAd ?? this.createAd,
      reactions: reactions != null
          ? Map<String, String>.from(reactions)
          : this.reactions,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
