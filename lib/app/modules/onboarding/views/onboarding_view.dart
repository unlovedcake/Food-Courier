import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/onboarding_model.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) {
    final List<OnboardingModel> pages = [
      OnboardingModel(
        title: 'Order Delicious Food',
        description: 'Quickly order from top restaurants near you.',
        image: 'https://cdn-icons-png.flaticon.com/512/3595/3595455.png',
      ),
      OnboardingModel(
        title: 'Track Your Order',
        description: 'Get updates as your food is prepared and delivered.',
        image: 'https://cdn-icons-png.flaticon.com/512/4280/4280770.png',
      ),
      OnboardingModel(
        title: 'Enjoy Your Meal',
        description: 'Sit back and enjoy fresh meals at your doorstep!',
        image: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png',
      ),
    ];

    Widget buildDotIndicator(int index) {
      return Obx(() {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: controller.pageIndex.value == index ? 12 : 8,
          height: controller.pageIndex.value == index ? 12 : 8,
          decoration: BoxDecoration(
            color: controller.pageIndex.value == index
                ? Colors.deepOrange
                : Colors.grey[400],
            shape: BoxShape.circle,
          ),
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: pages.length,
              onPageChanged: controller.changePage,
              itemBuilder: (_, index) {
                final OnboardingModel item = pages[index];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() {
                        bool isActive = controller.pageIndex.value == index;
                        return AnimatedScale(
                          scale: isActive ? 1.0 : 0.8,
                          duration: const Duration(milliseconds: 500),
                          child: AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.3,
                            duration: const Duration(milliseconds: 500),
                            child: Image.network(item.image, height: 250),
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // // Skip
          // Positioned(
          //   top: 20,
          //   right: 20,
          //   child: TextButton(
          //     onPressed: controller.navigateToHome,
          //     child: const Text('Skip', style: TextStyle(color: Colors.grey)),
          //   ),
          // ),

          // // Dots
          // Positioned(
          //   bottom: 100,
          //   left: 0,
          //   right: 0,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: List.generate(pages.length, buildDotIndicator),
          //   ),
          // ),

          // // Button
          // Positioned(
          //   bottom: 40,
          //   right: 20,
          //   child: Obx(() {
          //     final isLastPage = controller.pageIndex.value == pages.length - 1;
          //     return ElevatedButton(
          //       onPressed: () {
          //         if (isLastPage) {
          //           controller.navigateToHome();
          //         } else {
          //           controller.pageController.nextPage(
          //             duration: const Duration(milliseconds: 500),
          //             curve: Curves.easeInOut,
          //           );
          //         }
          //       },
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.deepOrange,
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 24,
          //           vertical: 12,
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30),
          //         ),
          //       ),
          //       child: Text(isLastPage ? 'Get Started' : 'Next'),
          //     );
          //   }),
          // ),
        ],
      ),
    );
  }
}
