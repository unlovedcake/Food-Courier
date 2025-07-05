import 'package:flutter/material.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController
    with GetTickerProviderStateMixin {
  RxInt pageIndex = (-1).obs;

  final PageController pageController = PageController();

  late AnimationController animationController;
  late Animation<double> animation;

  final int dotCount = 3;
  final RxInt previousPageIndex = 0.obs;

  void changePage(int index) {
    pageIndex.value = index;
    animationController.forward(from: 0);
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

    await Get.offAllNamed(AppPages.AUTH); // Replace with your HomeScreen
  }

  @override
  void onInit() {
    super.onInit();

    // Future.delayed(const Duration(milliseconds: 500), () {
    //   pageIndex.value = 0;
    // });
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    pageController.addListener(() {
      final int newPage = pageController.page?.round() ?? 0;
      if (newPage != pageIndex.value) {
        previousPageIndex.value = pageIndex.value;
        pageIndex.value = newPage;
        animationController.forward(from: 0);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    animationController.dispose();
    pageController.dispose();
  }
}

// class OnboardingController extends GetxController
//     with GetTickerProviderStateMixin {
//   final PageController pageController = PageController();

//   late final AnimationController animationController;
//   late final Animation<double> animation;

//   final RxInt pageIndex = 0.obs;
//   final RxInt previousPageIndex = 0.obs;

//   final int dotCount = 3;

//   /// Computed helper
//   bool get isLastPage => pageIndex.value == dotCount - 1;

//   @override
//   void onInit() {
//     super.onInit();

//     animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );

//     animation = CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeInOut,
//     );

//     // Listen to page changes
//     pageController.addListener(_handlePageChange);
//   }

//   void _handlePageChange() {
//     final int newPage = pageController.page?.round() ?? 0;

//     if (newPage != pageIndex.value) {
//       previousPageIndex.value = pageIndex.value;
//       pageIndex.value = newPage;
//       animationController.forward(from: 0);
//     }
//   }

//   Future<void> completeOnboarding() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('onboarding_complete', true);
//   }

//   Future<bool> isOnboardingComplete() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('onboarding_complete') ?? false;
//   }

//   Future<void> navigateToHome() async {
//     await completeOnboarding();
//     await Get.offAllNamed(AppPages.AUTH); // Replace with actual route
//   }

//   Future<void> onNextPressed() async {
//     if (isLastPage) {
//       await navigateToHome();
//     } else {
//       await pageController.nextPage(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   void onClose() {
//     animationController.dispose();
//     pageController.dispose();
//     super.onClose();
//   }
// }
