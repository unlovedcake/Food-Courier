import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showLoading() {
  Get.dialog(
    const Center(
      child: CircularProgressIndicator(),
    ),
    barrierDismissible:
        false, // User cannot dismiss the dialog by tapping outside
  );
}
