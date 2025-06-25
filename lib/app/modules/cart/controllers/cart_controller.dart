import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:food_courier/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CartController extends GetxController with GetTickerProviderStateMixin {
  final isVisibleList = <bool>[].obs;

  late AnimationController animationController;
  late List<Animation<double>> fadeAnimations;

  final HomeController homeController = Get.find();

  Map<int, GlobalKey> buttonDeleteKeys = {};

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

    //animateItems();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  Future<void> createCheckoutSession() async {
    print('HEY');
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

    // Encode the username and password for basic auth
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
          // [
          //   {
          //     'currency': 'PHP',
          //     'images': [
          //       'https://media.istockphoto.com/id/1350560575/photo/pair-of-blue-running-sneakers-on-white-background-isolated.jpg?s=612x612&w=0&k=20&c=A3w_a9q3Gz-tWkQL6K00xu7UHdN5LLZefzPDp-wNkSU=',
          //     ],
          //     'amount': 1000 * 100,
          //     'description': 'Checkout Payment',
          //     'name': 'Product Name',
          //     'quantity': 1,
          //   }
          // ],
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
      // 'data': {
      //   'attributes': {
      //     'billing': {
      //       'address': {
      //         'line1': 'Cebu City',
      //         'city': 'Talisay City',
      //         'postal_code': '6045',
      //         'state': 'Cebu',
      //         'country': 'PH',
      //       },
      //       'name': 'James Lebron',
      //       'email': 'james@gmail.com',
      //       'phone': '09165622771',
      //     },
      //     'send_email_receipt': true,
      //     'show_description': true,
      //     'show_line_items': true,
      //     'description': 'Sample Description',
      //     'line_items': [
      //       {
      //         'currency': 'PHP',
      //         'images': [
      //           'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
      //         ],
      //         'amount': 1000 * 100,
      //         'description': 'Sample Description',
      //         'name': 'Name Product',
      //         'quantity': 1,
      //       }
      //     ],
      //     'payment_method_types': ['gcash', 'paymaya', 'grab_pay', 'card'],
      //     'reference_number': '123456',
      //     'success_url': 'https://www.google.com/',
      //     'cancel_url': 'https://www.youtube.com/',
      //   },
      // },
    };

    final String body = jsonEncode(data);

    try {
      final http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // Handle successful response

        String checkoutUrl = responseBody['data']['attributes']['checkout_url'];
        String id = responseBody['data']['id'];
        debugPrint('Checkout session created successfully: $id');

        if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(
            Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication,
          );
        }

        // Get.toNamed(
        //   AppPages.WEBVIEW,
        //   arguments: {
        //     'checkout_url': checkoutUrl,
        //     'id': id,
        //   },
        // );
      } else {
        // Handle error
        print('Error creating checkout session: ${response.body}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
    }
  }

  Future<void> animateItems() async {
    isVisibleList.assignAll(
      List.generate(homeController.cartProducts.length, (_) => false),
    );
    for (int i = 0; i < homeController.cartProducts.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      isVisibleList[i] = true;
    }
  }
}
