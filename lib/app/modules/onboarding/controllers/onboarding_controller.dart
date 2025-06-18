import 'package:flutter/material.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  RxInt pageIndex = 0.obs;

  final OnboardingController controller = Get.put(OnboardingController());
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
    await Get.toNamed(AppPages.INITIAL); // Replace with your HomeScreen
  }
}
