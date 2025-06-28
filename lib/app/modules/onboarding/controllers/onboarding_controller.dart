import 'package:flutter/material.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  RxInt pageIndex = (-1).obs;

  final PageController pageController = PageController();

  void changePage(int index) {
    pageIndex.value = index;
  }

  Future<void> completeOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  Future<bool> isOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  Future<void> navigateToHome() async {
    await completeOnboarding();

    await Get.toNamed(AppPages.AUTH); // Replace with your HomeScreen
  }

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(milliseconds: 500), () {
      pageIndex.value = 0;
    });
  }

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
  }
}
