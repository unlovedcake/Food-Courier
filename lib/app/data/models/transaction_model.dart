import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  TransactionModel({
    required this.orderId,
    required this.customerName,
    required this.email,
    required this.products,
    required this.totalItems,
    required this.totalPay,
    required this.createdAt,
    required this.currentStep,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      orderId: json['orderId'] ?? '',
      customerName: json['customerName'] ?? '',
      email: json['email'] ?? '',
      products: (json['products'] as List)
          .map((item) => ProductItem.fromJson(item))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      totalPay: json['totalPay'] ?? '0.00',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      currentStep: List<String>.from(json['currentStep'] ?? []),
    );
  }

  String orderId;
  final String customerName;
  final String email;
  final List<ProductItem> products;
  final int totalItems;
  final String totalPay;
  final DateTime createdAt;
  final List<String> currentStep; // 👈 New property

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'email': email,
      'products': products.map((e) => e.toJson()).toList(),
      'totalItems': totalItems,
      'totalPay': totalPay,
      'createdAt': createdAt,
      'currentStep': currentStep, // 👈 Include in JSON
    };
  }
}

class ProductItem {
  ProductItem({
    required this.id,
    required this.title,
    required this.price,
    required this.countItem,
    required this.thumbnail,
    required this.category,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      countItem: json['countItem'],
      thumbnail: json['thumbnail'],
      category: json['category'],
    );
  }
  final int id;
  final String title;
  final double price;
  final int countItem;
  final String thumbnail;
  final String category;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'countItem': countItem,
      'thumbnail': thumbnail,
      'category': category,
    };
  }
}
