import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/onboarding_model.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

// class OnboardingView extends StatelessWidget {
//   const OnboardingView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;

//     final OnboardingController controller = Get.put(OnboardingController());

//     final List<OnboardingModel> pages = [
//       OnboardingModel(
//         title: 'Welcome to ShopEasy',
//         description: 'Discover the best products at amazing prices!',
//         image: 'assets/images/onboarding_image1.gif',
//       ),
//       OnboardingModel(
//         title: 'Easy Shopping',
//         description: 'Browse, add to cart, and check out in seconds.',
//         image: 'assets/images/onboarding_image2.gif',
//       ),
//       OnboardingModel(
//         title: 'Fast Delivery',
//         description: 'Get your items delivered to your doorstep quickly.',
//         image: 'assets/images/onboarding_image3.gif',
//       ),
//     ];

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: DecoratedBox(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color.fromARGB(255, 233, 180, 5),
//               Color(0xFFE0F7FA),
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             PageView.builder(
//               controller: controller.pageController,
//               itemCount: pages.length,
//               itemBuilder: (_, index) {
//                 final OnboardingModel item = pages[index];

//                 return RepaintBoundary(
//                   child: OnboardingPage(
//                     item: item,
//                     isActive: () => controller.pageIndex.value == index,
//                   ),
//                 );
//               },
//             ),

//             // Skip Button
//             Positioned(
//               top: 20,
//               right: 20,
//               child: TextButton(
//                 onPressed: controller.navigateToHome,
//                 child: const Text('Skip', style: TextStyle(color: Colors.grey)),
//               ),
//             ),

//             // Dot Indicator
//             Positioned(
//               bottom: 20,
//               left: 0,
//               right: 0,
//               child: BouncingDotIndicator(screenWidth: screenWidth),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Obx(() {
//         final isLastPage = controller.pageIndex.value == pages.length - 1;

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//           child: ElevatedButton(
//             onPressed: () async {
//               if (isLastPage) {
//                 await controller.navigateToHome();
//               } else {
//                 await controller.pageController.nextPage(
//                   duration: const Duration(milliseconds: 500),
//                   curve: Curves.easeInOut,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               minimumSize: const Size(100, 40),
//               backgroundColor: Colors.black,
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               transitionBuilder: (child, animation) =>
//                   ScaleTransition(scale: animation, child: child),
//               child: Text(
//                 isLastPage ? 'Get Started' : 'Next',
//                 key: ValueKey<bool>(isLastPage),
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

// class OnboardingPage extends StatelessWidget {
//   const OnboardingPage({
//     required this.item,
//     required this.isActive,
//     super.key,
//   });
//   final OnboardingModel item;
//   final bool Function() isActive;

//   @override
//   Widget build(BuildContext context) {
//     final bool active = isActive();

//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 600),
//             child: active
//                 ? Image.asset(
//                     item.image,
//                     key: ValueKey(item.image),
//                     height: 250,
//                     fit: BoxFit.contain,
//                   )
//                 : const SizedBox.shrink(),
//           ),
//           const SizedBox(height: 30),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 600),
//             child: active
//                 ? Column(
//                     key: ValueKey(item.title),
//                     children: [
//                       Text(
//                         item.title,
//                         style: const TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         item.description,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   )
//                 : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class BouncingDotIndicator extends StatelessWidget {
//   BouncingDotIndicator({required this.screenWidth, super.key});
//   final double screenWidth;
//   final OnboardingController controller = Get.find();

//   final double dotSize = 12;
//   final double spacing = 24;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 40,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(controller.dotCount, (index) {
//               return Container(
//                 margin: EdgeInsets.symmetric(
//                   horizontal: spacing / 2 - dotSize / 2,
//                 ),
//                 width: dotSize,
//                 height: dotSize,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[400],
//                   shape: BoxShape.circle,
//                 ),
//               );
//             }),
//           ),
//           AnimatedBuilder(
//             animation: controller.animation,
//             builder: (context, child) {
//               final int from = controller.previousPageIndex.value;
//               final int to = controller.pageIndex.value;
//               final double progress = controller.animation.value;

//               final double totalSpacing = spacing;
//               final double fromX = (from - 1) * totalSpacing;
//               final double toX = (to - 1) * totalSpacing;
//               final double currentX = lerpDouble(fromX, toX, progress)!;
//               final double centerX = screenWidth / 2;
//               final double arcY = -20 * sin(progress * pi);
//               final double offsetX = centerX + currentX;

//               return Positioned(
//                 left: offsetX - dotSize / 2,
//                 top: arcY + 14,
//                 child: Transform.scale(
//                   scale: 1.0 + 0.3 * sin(progress * pi),
//                   child: Container(
//                     width: dotSize,
//                     height: dotSize,
//                     decoration: const BoxDecoration(
//                       color: Colors.black,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) {
    final List<OnboardingModel> pages = [
      OnboardingModel(
        title: 'Welcome to ShopEasy',
        description: 'Discover the best products at amazing prices!',
        image: 'assets/images/onboarding_image1.gif',
      ),
      OnboardingModel(
        title: 'Easy Shopping',
        description: 'Browse, add to cart, and check out in seconds.',
        image: 'assets/images/onboarding_image2.gif',
      ),
      OnboardingModel(
        title: 'Fast Delivery',
        description: 'Get your items delivered to your doorstep quickly.',
        image: 'assets/images/onboarding_image3.gif',
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.pageIndex.value = 0;
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: Get.height * 0.20,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white,
                    Colors.orange,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: Get.height * 0.25,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.orange,
                  ],
                ),
              ),
            ),
          ),
          PageView.builder(
            controller: controller.pageController,
            itemCount: pages.length,
            onPageChanged: controller.changePage,
            itemBuilder: (_, index) {
              final OnboardingModel item = pages[index];

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() {
                      bool isActive = controller.pageIndex.value == index;

                      return RepaintBoundary(
                        key: const ValueKey(int),
                        child: AnimatedSlide(
                          offset: isActive ? Offset.zero : const Offset(0.2, 0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          child: AnimatedScale(
                            scale: isActive ? 1.0 : 0.5,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            child: AnimatedRotation(
                              turns: isActive
                                  ? 0.0
                                  : 0.25, // 0.25 turns = 90 degrees
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOut,
                              child: AnimatedOpacity(
                                opacity: isActive ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 600),
                                child: Image.asset(
                                  item.image,
                                  height: 250,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                    Obx(() {
                      bool isActive = controller.pageIndex.value == index;
                      return AnimatedOpacity(
                        opacity: isActive ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        child: AnimatedSlide(
                          offset: isActive ? Offset.zero : const Offset(0, 0.3),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          child: Column(
                            spacing: 8,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // Skip
          Positioned(
            top: 20,
            right: 20,
            child: TextButton(
              onPressed: controller.navigateToHome,
              child: const Text('Skip', style: TextStyle(color: Colors.grey)),
            ),
          ),

          // Dots
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: RepaintBoundary(child: BouncingDotIndicator()),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Obx(() {
              final isLastPage = controller.pageIndex.value == pages.length - 1;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ElevatedButton(
                  onPressed: () async {
                    if (isLastPage) {
                      await controller.navigateToHome();
                    } else {
                      await controller.pageController.nextPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.bounceInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      isLastPage ? 'Get Started' : 'Next',
                      key: ValueKey<bool>(
                        isLastPage,
                      ), // Key to animate text change
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      // bottomNavigationBar: Obx(() {
      //   final isLastPage = controller.pageIndex.value == pages.length - 1;

      //   return Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 18),
      //     child: ElevatedButton(
      //       onPressed: () async {
      //         if (isLastPage) {
      //           await controller.navigateToHome();
      //         } else {
      //           await controller.pageController.nextPage(
      //             duration: const Duration(milliseconds: 500),
      //             curve: Curves.bounceInOut,
      //           );
      //         }
      //       },
      //       style: ElevatedButton.styleFrom(
      //         minimumSize: const Size(150, 50),
      //         backgroundColor: Colors.black,
      //         padding: const EdgeInsets.symmetric(horizontal: 24),
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(30),
      //         ),
      //       ),
      //       child: AnimatedSwitcher(
      //         duration: const Duration(milliseconds: 400),
      //         transitionBuilder: (child, animation) {
      //           return ScaleTransition(scale: animation, child: child);
      //         },
      //         child: Text(
      //           isLastPage ? 'Get Started' : 'Next',
      //           key: ValueKey<bool>(isLastPage), // Key to animate text change
      //           style: const TextStyle(fontSize: 16),
      //         ),
      //       ),
      //     ),
      //   );
      // }),
    );
  }
}

class BouncingDotIndicator extends StatelessWidget {
  BouncingDotIndicator({super.key});
  final OnboardingController controller = Get.find();

  final double dotSize = 12;
  final double spacing = 24;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(controller.dotCount, (index) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: spacing / 2 - dotSize / 2,
                ),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          // Animated active dot
          AnimatedBuilder(
            animation: controller.animation,
            builder: (context, child) {
              final int from = controller.previousPageIndex.value;
              final int to = controller.pageIndex.value;
              final double progress = controller.animation.value;

              final double centerX = MediaQuery.of(context).size.width / 2;
              final double totalSpacing = spacing;

              final double fromX = (from - 1) * totalSpacing;
              final double toX = (to - 1) * totalSpacing;

              final double currentX = lerpDouble(fromX, toX, progress)!;

              // Arc: bounce along sine wave
              final double arcHeight = -20 * sin(progress * pi);
              final double offsetX = centerX + currentX;
              final offsetY = arcHeight;

              return Positioned(
                left: offsetX - dotSize / 2,
                top: offsetY + 14,
                child: Transform.scale(
                  scale: 1.0 +
                      0.3 * sin(progress * pi), // 👈 Bounce scale (0.7 to 1.3)
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
