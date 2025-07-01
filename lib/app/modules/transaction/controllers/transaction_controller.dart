import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/transaction_model.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  final transactions = <TransactionModel>[].obs;

  final isLoading = false.obs;

  Future<void> fetchTransactionsForUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      isLoading.value = true;
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('email', isEqualTo: user.email)
              .get();

      transactions.value = snapshot.docs.map((doc) {
        return TransactionModel.fromJson(doc.data());
      }).toList();
    } on Exception catch (e) {
      debugPrint('Error fetching transaction $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTransactionsForUser();
  }
}
