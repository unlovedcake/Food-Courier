import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  // Getter to access currentIndex without .value
  int get currentIndex => _currentIndex.value;

  void changeTab(int index) {
    _currentIndex.value = index;
  }
}
