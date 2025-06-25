// models/product_model.dart

import 'package:get/get_rx/src/rx_types/rx_types.dart';

class ProductModel {
  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.dimensions,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.reviews,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.meta,
    required this.images,
    required this.thumbnail,
    RxList? isAdded,
    RxBool? isLike,
    RxInt? countItem,
  })  : isAdded = isAdded ?? [].obs,
        isLike = isLike ?? false.obs,
        countItem = countItem ?? 0.obs;

  /// ✅ fromJson remains unchanged (non-observable fields only)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'],
      tags: List<String>.from(json['tags']),
      brand: json['brand'] ?? '',
      sku: json['sku'],
      weight: (json['weight'] as num).toDouble(),
      dimensions: Dimensions.fromJson(json['dimensions']),
      warrantyInformation: json['warrantyInformation'],
      shippingInformation: json['shippingInformation'],
      availabilityStatus: json['availabilityStatus'],
      reviews: List<Review>.from(
        json['reviews'].map((x) => Review.fromJson(x)),
      ),
      returnPolicy: json['returnPolicy'],
      minimumOrderQuantity: json['minimumOrderQuantity'],
      meta: Meta.fromJson(json['meta']),
      images: List<String>.from(json['images']),
      thumbnail: json['thumbnail'],
    );
  }
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final double weight;
  final Dimensions dimensions;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<Review> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final Meta meta;
  final List<String> images;
  final String thumbnail;

  /// ✅ Optional observable fields
  final RxList isAdded;
  final RxBool isLike;
  final RxInt countItem;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'tags': tags,
        'brand': brand,
        'sku': sku,
        'weight': weight,
        'dimensions': dimensions.toJson(),
        'warrantyInformation': warrantyInformation,
        'shippingInformation': shippingInformation,
        'availabilityStatus': availabilityStatus,
        'reviews': reviews.map((x) => x.toJson()).toList(),
        'returnPolicy': returnPolicy,
        'minimumOrderQuantity': minimumOrderQuantity,
        'meta': meta.toJson(),
        'images': images,
        'thumbnail': thumbnail,
      };

  ProductModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    List<String>? tags,
    String? brand,
    String? sku,
    double? weight,
    Dimensions? dimensions,
    String? warrantyInformation,
    String? shippingInformation,
    String? availabilityStatus,
    List<Review>? reviews,
    String? returnPolicy,
    int? minimumOrderQuantity,
    Meta? meta,
    List<String>? images,
    String? thumbnail,
    RxList? isAdded,
    RxBool? isLike,
    RxInt? countItem,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      tags: tags ?? this.tags,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      warrantyInformation: warrantyInformation ?? this.warrantyInformation,
      shippingInformation: shippingInformation ?? this.shippingInformation,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      reviews: reviews ?? this.reviews,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      meta: meta ?? this.meta,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail,
      isAdded: isAdded ?? this.isAdded,
      isLike: isLike ?? this.isLike,
      countItem: countItem ?? this.countItem,
    );
  }
}

class Dimensions {
  Dimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        depth: (json['depth'] as num).toDouble(),
      );
  final double width;
  final double height;
  final double depth;

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'depth': depth,
      };
}

class Review {
  Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        rating: json['rating'],
        comment: json['comment'],
        date: DateTime.parse(json['date']),
        reviewerName: json['reviewerName'],
        reviewerEmail: json['reviewerEmail'],
      );
  final int rating;
  final String comment;
  final DateTime date;
  final String reviewerName;
  final String reviewerEmail;

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
        'date': date.toIso8601String(),
        'reviewerName': reviewerName,
        'reviewerEmail': reviewerEmail,
      };
}

class Meta {
  Meta({
    required this.createdAt,
    required this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        barcode: json['barcode'],
        qrCode: json['qrCode'],
      );
  final DateTime createdAt;
  final DateTime updatedAt;
  final String barcode;
  final String qrCode;

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'barcode': barcode,
        'qrCode': qrCode,
      };
}





// import 'dart:convert';

// ProductResponse productResponseFromJson(String str) =>
//     ProductResponse.fromJson(json.decode(str));

// class ProductResponse {
//   ProductResponse({
//     required this.products,
//     required this.total,
//     required this.skip,
//     required this.limit,
//   });

//   factory ProductResponse.fromJson(Map<String, dynamic> json) =>
//       ProductResponse(
//         products: List<Product>.from(
//             json['products'].map((x) => Product.fromJson(x))),
//         total: json['total'],
//         skip: json['skip'],
//         limit: json['limit'],
//       );
//   final List<Product> products;
//   final int total;
//   final int skip;
//   final int limit;
// }

// class Product {
//   Product({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.price,
//     required this.discountPercentage,
//     required this.rating,
//     required this.stock,
//     required this.tags,
//     required this.brand,
//     required this.sku,
//     required this.weight,
//     required this.dimensions,
//     required this.warrantyInformation,
//     required this.shippingInformation,
//     required this.availabilityStatus,
//     required this.reviews,
//     required this.returnPolicy,
//     required this.minimumOrderQuantity,
//     required this.meta,
//     required this.images,
//     required this.thumbnail,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) => Product(
//         id: json['id'],
//         title: json['title'],
//         description: json['description'],
//         category: json['category'],
//         price: (json['price'] as num).toDouble(),
//         discountPercentage: (json['discountPercentage'] as num).toDouble(),
//         rating: (json['rating'] as num).toDouble(),
//         stock: json['stock'],
//         tags: List<String>.from(json['tags']),
//         brand: json['brand'],
//         sku: json['sku'],
//         weight: json['weight'],
//         dimensions: Dimensions.fromJson(json['dimensions']),
//         warrantyInformation: json['warrantyInformation'],
//         shippingInformation: json['shippingInformation'],
//         availabilityStatus: json['availabilityStatus'],
//         reviews:
//             List<Review>.from(json['reviews'].map((x) => Review.fromJson(x))),
//         returnPolicy: json['returnPolicy'],
//         minimumOrderQuantity: json['minimumOrderQuantity'],
//         meta: Meta.fromJson(json['meta']),
//         images: List<String>.from(json['images']),
//         thumbnail: json['thumbnail'],
//       );
//   final int id;
//   final String title;
//   final String description;
//   final String category;
//   final double price;
//   final double discountPercentage;
//   final double rating;
//   final int stock;
//   final List<String> tags;
//   final String brand;
//   final String sku;
//   final int weight;
//   final Dimensions dimensions;
//   final String warrantyInformation;
//   final String shippingInformation;
//   final String availabilityStatus;
//   final List<Review> reviews;
//   final String returnPolicy;
//   final int minimumOrderQuantity;
//   final Meta meta;
//   final List<String> images;
//   final String thumbnail;

//   Product copyWith({
//     int? id,
//     String? title,
//     String? description,
//     String? category,
//     double? price,
//     double? discountPercentage,
//     double? rating,
//     int? stock,
//     List<String>? tags,
//     String? brand,
//     String? sku,
//     int? weight,
//     Dimensions? dimensions,
//     String? warrantyInformation,
//     String? shippingInformation,
//     String? availabilityStatus,
//     List<Review>? reviews,
//     String? returnPolicy,
//     int? minimumOrderQuantity,
//     Meta? meta,
//     List<String>? images,
//     String? thumbnail,
//   }) {
//     return Product(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       category: category ?? this.category,
//       price: price ?? this.price,
//       discountPercentage: discountPercentage ?? this.discountPercentage,
//       rating: rating ?? this.rating,
//       stock: stock ?? this.stock,
//       tags: tags ?? this.tags,
//       brand: brand ?? this.brand,
//       sku: sku ?? this.sku,
//       weight: weight ?? this.weight,
//       dimensions: dimensions ?? this.dimensions,
//       warrantyInformation: warrantyInformation ?? this.warrantyInformation,
//       shippingInformation: shippingInformation ?? this.shippingInformation,
//       availabilityStatus: availabilityStatus ?? this.availabilityStatus,
//       reviews: reviews ?? this.reviews,
//       returnPolicy: returnPolicy ?? this.returnPolicy,
//       minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
//       meta: meta ?? this.meta,
//       images: images ?? this.images,
//       thumbnail: thumbnail ?? this.thumbnail,
//     );
//   }
// }

// class Dimensions {
//   Dimensions({
//     required this.width,
//     required this.height,
//     required this.depth,
//   });

//   factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
//         width: (json['width'] as num).toDouble(),
//         height: (json['height'] as num).toDouble(),
//         depth: (json['depth'] as num).toDouble(),
//       );
//   final double width;
//   final double height;
//   final double depth;
// }

// class Review {
//   Review({
//     required this.rating,
//     required this.comment,
//     required this.date,
//     required this.reviewerName,
//     required this.reviewerEmail,
//   });

//   factory Review.fromJson(Map<String, dynamic> json) => Review(
//         rating: json['rating'],
//         comment: json['comment'],
//         date: DateTime.parse(json['date']),
//         reviewerName: json['reviewerName'],
//         reviewerEmail: json['reviewerEmail'],
//       );
//   final int rating;
//   final String comment;
//   final DateTime date;
//   final String reviewerName;
//   final String reviewerEmail;
// }

// class Meta {
//   Meta({
//     required this.createdAt,
//     required this.updatedAt,
//     required this.barcode,
//     required this.qrCode,
//   });

//   factory Meta.fromJson(Map<String, dynamic> json) => Meta(
//         createdAt: DateTime.parse(json['createdAt']),
//         updatedAt: DateTime.parse(json['updatedAt']),
//         barcode: json['barcode'],
//         qrCode: json['qrCode'],
//       );
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final String barcode;
//   final String qrCode;
// }

