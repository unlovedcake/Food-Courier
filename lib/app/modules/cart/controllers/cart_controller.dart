import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:food_courier/app/core/helper/show_loading.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:food_courier/app/data/models/transaction_model.dart';
import 'package:food_courier/app/modules/home/controllers/home_controller.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CartController extends GetxController with GetTickerProviderStateMixin {
  final isVisibleList = <bool>[].obs;

  final isCheckout = false.obs;

  late AnimationController animationController;
  late List<Animation<double>> fadeAnimations;

  final HomeController homeController = Get.find();

  Map<int, GlobalKey> buttonDeleteKeys = {};

  final totalPay = 0.0.obs;

  final String _baseUrl = 'https://api.paymongo.com/v1/checkout_sessions';
  final String _apiKey =
      'c2tfdGVzdF9haWJVdkJycG9vc3BXdHFmbmQ1dXI4VVk6'; // replace with your actual PayMongo API Key

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Create staggered fade animations using Interval
    fadeAnimations = List.generate(homeController.cartProducts.length, (index) {
      final double start = index * 0.15;
      final double end = (start + 0.3).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: animationController,
        curve: Interval(start, end, curve: Curves.easeIn),
      );
    });

    animationController.forward();

    for (final ProductModel product in homeController.cartProducts.values) {
      buttonDeleteKeys[product.id] = GlobalKey();
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  Future<void> createCheckoutSession() async {
    final List<Map<String, Object>> lineItems =
        homeController.cartProducts.values.map((product) {
      return {
        'currency': 'PHP',
        'images': [product.thumbnail],
        'amount': (product.price * 100).round(),
        'description': product.description,
        'name': product.title,
        'quantity': product.countItem.value,
      };
    }).toList();

    final Uri url = Uri.parse(_baseUrl);

    final authHeader = 'Basic $_apiKey';

    final headers = {
      'Authorization': authHeader,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> data = {
      'data': {
        'attributes': {
          'send_email_receipt': true,
          'show_description': true,
          'show_line_items': true,
          'cancel_url': 'https://www.google.com/',
          'line_items': lineItems,
          'payment_method_types': [
            'card',
            'gcash',
            'grab_pay',
            'paymaya',
          ],
          'reference_number': '123',
          'description': 'Checkout Payment',
          'success_url': 'https://www.youtube.com',
        },
      },
    };

    //   "data": {
    //   "attributes": {
    //     "billing": {
    //       "address": {
    //         "line1": "Washingon Street Talisay",
    //         "city": "Talisay City Cebu",
    //         "postal_code": "6045",
    //         "country": "PH"
    //       },
    //       "name": "love",
    //       "email": "love@gmail.com",
    //       "phone": "09165622770"
    //     },
    //     "send_email_receipt": true,
    //     "show_description": true,
    //     "show_line_items": true,
    //     "cancel_url": "https://www.google.com/",
    //     "description": "Checkout",
    //     "line_items": [
    //       {
    //         "currency": "PHP",
    //         "amount": 100000,
    //         "description": "Test Payment",
    //         "name": "Smart Phone",
    //         "quantity": 2
    //       }
    //     ],
    //     "payment_method_types": [
    //       "gcash",
    //       "paymaya",
    //       "card"
    //     ],
    //     "reference_number": "123",
    //     "success_url": "https://www.youtube.com/",
    //     "statement_descriptor": "Click and Get IT"
    //   }
    // }

    final String body = jsonEncode(data);

    try {
      showLoading();
      isCheckout.value = true;
      final http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        String checkoutUrl = responseBody['data']['attributes']['checkout_url'];
        String id = responseBody['data']['id'];
        Print.success('Checkout session created successfully: $id');

        // if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
        //   await launchUrl(
        //     Uri.parse(checkoutUrl),
        //     mode: LaunchMode.externalApplication,
        //   );
        // }
        Get.back();

        unawaited(
          Get.toNamed(
            AppPages.WEBVIEW,
            arguments: {
              'checkout_url': checkoutUrl,
              'id': id,
            },
          ),
        );
      } else {
        Print.error('Error creating checkout session: ${response.body}');
        final Map<String, dynamic> json = jsonDecode(response.body);
        final String message = json['errors']?[0]?['detail'] ?? 'Unknown error';
        Get
          ..back()
          ..snackbar(
            'Error',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white,
          );
      }
    } on Exception catch (error) {
      Print.error('Error: $error');
      Get
        ..back()
        ..snackbar(
          'Error',
          'Failed to create checkout session. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      return;
    }
  }

  Future<void> saveCartItems() async {
    final User? user = FirebaseAuth.instance.currentUser;
    List<Map<String, dynamic>> selectedProductData =
        homeController.cartProducts.values.map((product) {
      return {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'countItem': product.countItem.value,
        'thumbnail': product.thumbnail,
        'category': product.category,
      };
    }).toList();

    final finalPayload = TransactionModel(
      orderId: '',
      customerName: user?.displayName ?? '',
      email: user?.email ?? '',
      products: selectedProductData.map(ProductItem.fromJson).toList(),
      totalItems: homeController.cartProducts.length,
      totalPay: totalPay.toStringAsFixed(2),
      createdAt: DateTime.now(),
      currentStep: [],
    );

    // final Map<String, dynamic> finalPayload = {
    //   'orderId': '',
    //   'customerName': '',
    //   'email': '',
    //   'products': selectedProductData,
    //   'totalItems': homeController.cartProducts.length,
    //   'totalPay': totalPay.toStringAsFixed(2),
    //   'createdAt': DateTime.now().toIso8601String(),
    // };

    // finalPayload.forEach((key, value) {
    //   print('$key: $value');
    // });

    await saveTransactionToFirestore(finalPayload);
  }

  Future<void> saveTransactionToFirestore(
    TransactionModel finalPayload,
  ) async {
    try {
      // Get a reference to the collection

      final DocumentReference<Map<String, dynamic>> docRef =
          FirebaseFirestore.instance.collection('transactions').doc();
      finalPayload.orderId = docRef.id;

      await docRef.set(finalPayload.toJson());

      Print.success('Transaction saved successfully!');
    } catch (e) {
      Print.error('Error saving transaction: $e');
    }
  }
}
