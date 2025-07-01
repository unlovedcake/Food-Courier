import 'package:flutter/material.dart';
import 'package:food_courier/app/modules/chat/views/chat_view.dart';
import 'package:food_courier/app/modules/dashboard/views/fade_indexed_stack.dart';
import 'package:food_courier/app/modules/home/views/home_view.dart';
import 'package:food_courier/app/modules/profile/views/profile_view.dart';
import 'package:food_courier/app/modules/transaction/views/transaction_view.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const ChatView(),
      const TransactionView(),
      const Center(child: Text('Favorites')),
      const ProfileView(),
    ];
    return Obx(
      () => Scaffold(
        body: Obx(
          () => FadeIndexedStack(
            index: controller.currentIndex,
            duration: const Duration(milliseconds: 400),
            animationType: AnimationType.fadeScale,
            disableAnimationForIndexes: const [0],

            children: pages, // index 0 (e.g. home) has no animation
          ),
          // FadeIndexedStack(
          //   index: controller.currentIndex,
          //   children: pages,
          // ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.chat),
                  if (controller.isRead.value)
                    const SizedBox()
                  else
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Chat',
            ),

            // BottomNavigationBarItem(
            //   icon: Obx(
            //     () => IconButton(
            //       tooltip: 'Notification',
            //       onPressed: () async {
            //         await controller.markMessageAsRead();
            //         await Get.toNamed(AppPages.CHAT);
            //       },
            //       icon: Badge(
            //         label: controller.isRead.value
            //             ? null
            //             : const CircleAvatar(
            //                 radius: 4,
            //                 backgroundColor: Colors.red,
            //               ),
            //         offset: const Offset(6, -6),
            //         child: Icon(
            //           Icons.chat,
            //           color: Theme.of(context).colorScheme.surface,
            //         ),
            //       ),
            //     ),
            //   ),
            //   label: 'Chat',
            // ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Transaction',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
