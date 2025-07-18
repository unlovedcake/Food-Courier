import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.email,
    required this.deviceToken,
    required this.createdAt,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromJson(
    DocumentSnapshot<Map<String, dynamic>> data,
  ) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      email: data['email'] ?? '',
      deviceToken: data['deviceToken'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  final String uid;
  final String name;
  final String imageUrl;
  final String email;
  final String deviceToken;
  final DateTime createdAt;

  // Method to convert UserModel to a map for writing to Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'imageUrl': imageUrl,
      'email': email,
      'deviceToken': deviceToken,
      'createdAt': createdAt,
    };
  }
}
