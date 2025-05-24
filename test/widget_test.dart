import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_courier/app/modules/home/controllers/home_controller.dart';
import 'package:food_courier/app/modules/home/views/home_view.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('GetX Counter increments', (tester) async {
    Get.put(HomeController());
    // Wrap your view in GetMaterialApp to provide GetX context
    await tester.pumpWidget(
      const GetMaterialApp(
        home: HomeView(),
      ),
    );

    // Make sure initial state is '0'
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the FloatingActionButton
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // trigger rebuild

    // After tap, the text should update to '1'
    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
