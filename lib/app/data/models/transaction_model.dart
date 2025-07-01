class TransactionModel {
  TransactionModel({
    required this.customerName,
    required this.email,
    required this.products,
    required this.totalItems,
    required this.totalPay,
    required this.createdAt,
  });
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      customerName: json['customerName'] ?? '',
      email: json['email'] ?? '',
      products: (json['products'] as List)
          .map((item) => ProductItem.fromJson(item))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      totalPay: json['totalPay'] ?? '0.00',
      createdAt: json['createdAt'] ?? '',
    );
  }
  final String customerName;
  final String email;
  final List<ProductItem> products;
  final int totalItems;
  final String totalPay;
  final String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'email': email,
      'products': products.map((e) => e.toJson()).toList(),
      'totalItems': totalItems,
      'totalPay': totalPay,
      'createdAt': createdAt,
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
