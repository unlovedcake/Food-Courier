import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailProductController extends GetxController {
  RxDouble rotateX = 0.0.obs;
  RxDouble rotateY = 0.0.obs;

  RxBool showReviews = false.obs;

  void updateRotation(DragUpdateDetails details) {
    const sensitivity = 0.01;
    rotateY.value += details.delta.dx * sensitivity; // horizontal drag → Y axis
    rotateX.value -= details.delta.dy * sensitivity; // vertical drag → X axis
  }

  void resetRotation() {
    rotateX.value = 0;
    rotateY.value = 0;
  }

  void toggleReviews() {
    showReviews.value = !showReviews.value;
  }
}
