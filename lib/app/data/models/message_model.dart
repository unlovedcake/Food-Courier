class MessageModel {
  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.imageUrl,
    this.isRead = false,
    this.readAt,
    this.reactions = const {},
    this.isEdited = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
      isRead: json['isRead'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      reactions: Map<String, String>.from(json['reactions'] ?? {}),
      isEdited: json['isEdited'] ?? false,
    );
  }
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final bool isRead;
  final DateTime timestamp;
  final DateTime? readAt;
  final Map<String, String> reactions;
  final bool isEdited;

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'isRead': isRead,
        'timestamp': timestamp.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
        'reactions': reactions,
        'isEdited': isEdited,
      };
}
