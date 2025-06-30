import 'package:flutter_test/flutter_test.dart';
import 'package:food_courier/app/modules/home/controllers/home_controller.dart';

void main() {
  group('HomeController', () {
    late HomeController controller;

    test('fetchProducts loads and updates products', () async {
      // final Map<String, List<Map<String, Object>>> fakeProducts = {
      //   'products': List.generate(
      //     10,
      //     (i) => {
      //       'id': i + 1,
      //       'title': 'Product ${i + 1}',
      //       'price': 100 + i,
      //     },
      //   ),
      // };

      controller = HomeController();
      await controller.fetchProducts();

      expect(controller.products.isNotEmpty, true);
      expect(controller.products.length, 10);
      expect(controller.skip, controller.limit);
    });

    // test('fetchProducts with increased limit loads more products', () async {
    //   final controller = HomeController()..limit = 20;

    //   await controller.fetchProducts();

    //   expect(controller.products.length, 20);
    //   expect(controller.skip, 20);
    // });

    test('fetchProducts continues with increased limit until no more data',
        () async {
      final controller = HomeController();

      // Start with initial limit
      //controller.limit = 10;

      // Loop until there's no more data
      while (controller.hasMoreData.value) {
        await controller.fetchProducts();
        print('Fetched ${controller.products.length} products');

        // Increase limit after each successful fetch
        //controller.limit += 10;
      }

      expect(controller.hasMoreData.value, false);
      print('All products fetched. Final count: ${controller.products.length}');
    });

    test('fetchProducts sets hasMoreData to false on empty list', () async {
      controller = HomeController()..skip = 2000;
      await controller.fetchProducts();

      expect(controller.products.isEmpty, true);
      expect(controller.hasMoreData.value, false);
    });
  });
}
