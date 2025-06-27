import 'package:food_courier/app/core/app_theme.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;

    Get.changeTheme(
      isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme,
    );
  }
  // Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  // bool get isDarkMode => themeMode.value == ThemeMode.dark;

  // void toggleTheme() {
  //   //themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  //   // Get.changeThemeMode(themeMode.value); // Apply globally

  //   Get.changeTheme(
  //     Get.isDarkMode
  //         ? ThemeData.light(useMaterial3: false)
  //         : ThemeData.dark(useMaterial3: false),
  //   );
  // }
}
