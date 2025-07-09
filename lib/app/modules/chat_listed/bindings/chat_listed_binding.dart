import 'package:get/get.dart';

import '../controllers/chat_listed_controller.dart';

class ChatListedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatListedController>(
      ChatListedController.new,
    );
  }
}
