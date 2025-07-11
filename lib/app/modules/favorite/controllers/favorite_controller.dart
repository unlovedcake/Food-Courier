import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  RxList<Map<String, dynamic>> favoriteProducts = <Map<String, dynamic>>[].obs;

  void listenToFavoriteProducts() {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots()
          .listen((snapshot) {
        final List<Map<String, dynamic>> products =
            snapshot.docs.map((doc) => doc.data()).toList();
        favoriteProducts.value = products;
      });
    } catch (e) {
      Log.error('Error fetching favorites product');
    }
  }

  @override
  void onInit() {
    super.onInit();

    listenToFavoriteProducts();
  }
}
