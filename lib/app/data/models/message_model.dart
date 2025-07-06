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
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
      isDeleted: json['isDeleted'] ?? false,

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
  final DateTime createAd;

  final Map<String, String> reactions;
  final bool isEdited;

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'isDeleted': isDeleted,
        'createAd': createAd,
        'reactions': reactions,
        'isEdited': isEdited,
      };
}
