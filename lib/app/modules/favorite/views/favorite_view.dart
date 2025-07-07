import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';

class FavoriteView extends GetView<FavoriteController> {
  const FavoriteView({super.key});
  @override
  Widget build(BuildContext context) {
    final FavoriteController controller = Get.put(FavoriteController());

    // Sort favorites by 'title' ascending (case-insensitive)

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Favorites'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Obx(() {
        final RxList<Map<String, dynamic>> favorites =
            controller.favoriteProducts
              ..sort(
                (a, b) => (a['title'] ?? '')
                    .toString()
                    .toLowerCase()
                    .compareTo((b['title'] ?? '').toString().toLowerCase()),
              );

        if (favorites.isEmpty) {
          return const Center(
            child: Text('No favorite products yet.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> product = favorites[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['thumbnail'] ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ),
                title: Text(
                  product['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('₱${product['price']}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: Colors.red.shade400),
                    const SizedBox(height: 4),
                    Text(
                      '★ ${product['rating'] ?? 0}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
