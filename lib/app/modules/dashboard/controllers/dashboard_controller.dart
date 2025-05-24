import 'package:get/get.dart';

class DashboardController extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;
}
