import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_courier/app/core/helper/custom_log.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final cartKey = GlobalKey();
  late AnimationController cartIconAnimationController;
  late Animation<double> cartScaleAnimation;

  final PageController pageController = PageController();

  final products = <ProductModel>[].obs;
  final productsCategory = <ProductModel>[].obs;
  final productsSearch = <ProductModel>[].obs;
  final searchQuery = ''.obs;
  RxBool isLoading = false.obs;
  RxBool hasMoreData = true.obs;
  int limit = 10;
  int skip = 0;

  RxSet<int> likedProductIds = <int>{}.obs;

  static const _key = 'liked_products';

  // final List<String> carouselImages = [
  //   'https://media.istockphoto.com/id/1266459481/vector/shopping-online-in-smartphone-application-digital-marketing-vector-illustration.jpg?s=612x612&w=0&k=20&c=yFTkURyuo4e0qxfCBgISPps6MwYLNAqShj_lxPs2IrQ=',
  //   'https://media.istockphoto.com/id/941302930/vector/online-shopping-smartphone-turned-into-internet-shop-concept-of-mobile-marketing-and-e.jpg?s=612x612&w=0&k=20&c=oEaIaAVRL6w7juxEIVwFPISjW_XkoYbLmK_VRWjNaEk=',
  //   'https://static.vecteezy.com/system/resources/thumbnails/023/309/702/small/ai-generative-e-commerce-concept-shopping-cart-with-boxes-on-a-wooden-table-photo.jpg',
  // ];

  final List<String> carouselImages = [
    'assets/images/corousel1.jpg',
    'assets/images/corousel2.jpg',
    'assets/images/corousel3.jpg',
  ];

  OverlayEntry? overlayEntry;

  final cartItems = <int>[].obs;

  final RxList<bool> animatedFlags = <bool>[].obs;

  // RxMap<int, int> isAdded = <int, int>{}.obs;

  RxMap<int, ProductModel> cartProducts = <int, ProductModel>{}.obs;

  RxInt countIncrement = 1.obs;

  void addToCart(ProductModel product) {
    cartItems.add(product.id);

    final ProductModel? existingProduct = cartProducts[product.id];

    if (existingProduct == null) {
      product.countItem.value = 1;
      cartProducts[product.id] = product;
    } else {
      existingProduct.countItem.value++;
    }
  }

  void startAnimation(
    GlobalKey imageKey,
    BuildContext context,
    String imageUrl,
    int index,
  ) {
    final renderBoxImage =
        imageKey.currentContext?.findRenderObject() as RenderBox?;
    final renderBoxCart =
        cartKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBoxImage == null || renderBoxCart == null) return;

    final Offset startOffset = renderBoxImage.localToGlobal(Offset.zero);
    final Offset endOffset = renderBoxCart.localToGlobal(Offset.zero);
    final Size imageSize = renderBoxImage.size;

    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final scaleTween =
        Tween<double>(begin: 1.5, end: 0.1); // from full to smaller

    final overlay = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            final double scale = scaleTween.evaluate(animationController);
            final Offset offset =
                Offset.lerp(startOffset, endOffset, animationController.value)!;

            return Positioned(
              top: offset.dy,
              left: offset.dx,
              child: Transform.scale(
                scale: scale,
                //   AnimatedScale(
                // scale: cartItems.contains(index) ? 0.5 : 1.5,
                // duration: const Duration(milliseconds: 1000),
                // curve: Curves.easeInOut,
                child: Opacity(
                  opacity: 1, //1 - animationController.value,
                  child: Image.network(
                    imageUrl,
                    width: imageSize.width / 3,
                    height: imageSize.height / 3,
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(overlay);
    animationController.forward().whenComplete(() {
      overlay.remove();
      animationController.dispose();

      // trigger cart icon animation

      try {
        cartIconAnimationController.forward().then((_) {
          cartIconAnimationController.reverse();
        });
      } catch (e) {
        Print.error(e.toString());
      }
    });
  }

  final count = 0.obs;

  void increment() => count.value++;

  final ScrollController scrollController = ScrollController();
  final showScrollToTop = false.obs;

  RxString selectedCategory = 'All'.obs;

  final Map<String, String> categories = {
    'all': 'All',
    'beauty': 'Beauty',
    'fragrances': 'Fragrances',
    'furniture': 'Furniture',
    'groceries': 'Groceries',
    'home-decoration': 'Home Decoration',
    'kitchen-accessories': 'Kitchen Accessories',
    'laptops': 'Laptops',
    'mens-shirts': 'Mens Shirts',
    'mens-shoes': 'Mens Shoes',
    'mens-watches': 'Mens Watches',
    'mobile-accessories': 'Mobile Accessories',
    'motorcycle': 'Motorcycle',
    'skin-care': 'Skin Care',
    'smartphones': 'Smartphones',
    'sports-accessories': 'Sports Accessories',
    'sunglasses': 'Sunglasses',
    'tablets': 'Tablets',
    'tops': 'Tops',
    'vehicle': 'Vehicle',
    'womens-bags': 'Womens Bags',
    'womens-dresses': 'Womens Dresses',
    'womens-jewellery': 'Womens Jewellery',
    'womens-shoes': 'Womens Shoes',
    'womens-watches': 'Womens Watches',
  };

  final RxInt currentPage = 0.obs;

  Future<void> toggleLike(int productId) async {
    //await toggleFavoriteProduct(productId: productId);
    if (likedProductIds.contains(productId)) {
      likedProductIds.remove(productId);
    } else {
      likedProductIds.add(productId);
    }
    // await _saveToPrefs();
  }

  Future<void> fetchFavoriteProductIds() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    final List<int> ids =
        snapshot.docs.map((doc) => doc.data()['id'] as int).toList();

    likedProductIds.value = Set<int>.from(ids ?? []);
  }

  Future<void> addFavoriteProductToCollectionUsersWithSubCollectionFavorites(
    ProductModel product,
  ) async {
    await toggleLike(product.id);
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final productId = product.id.toString(); // ensure string key
    final DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    try {
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await docRef.get();

      if (docSnapshot.exists) {
        // 🔴 REMOVE favorite
        await docRef.delete();
        Print.info('Removed from favorites: $productId');
      } else {
        // ✅ ADD favorite
        await docRef.set({
          'id': product.id,
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'category': product.category,
          'thumbnail': product.thumbnail,
          'stock': product.stock,
          'rating': product.rating,
          'createdAt': FieldValue.serverTimestamp(), // optional
        });
        Print.success('Added to favorites: $productId');
      }
    } catch (e) {
      Print.error('Toggle Favorite Product error: $e');
    }
  }

  // Future<void> toggleFavoriteProduct({int productId = 0}) async {
  //   final User? user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     throw Exception('User not logged in');
  //   }

  //   final DocumentReference<Map<String, dynamic>> docRef =
  //       FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites').doc();

  //   try {
  //     final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
  //         await docRef.get();
  //     final Map<String, dynamic>? data = docSnapshot.data();

  //     if (data == null) {
  //       throw Exception('User data not found');
  //     }
  //     likedProductIds.value = Set<int>.from(data['favoriteProducts'] ?? []);

  //     if (productId == 0) return;

  //     if (likedProductIds.contains(productId)) {
  //       // REMOVE product
  //       await docRef.update({
  //         'favoriteProducts': FieldValue.arrayRemove([productId]),
  //       });
  //       debugPrint('❌ Removed product $productId from favorites');
  //     } else {
  //       // ADD product
  //       await docRef.update({
  //         'favoriteProducts': FieldValue.arrayUnion([productId]),
  //       });
  //       debugPrint('✅ Added product $productId to favorites');
  //     }
  //   } catch (e) {
  //     debugPrint('❌ toggleFavoriteProduct error: $e');
  //   }
  // }

  Future<void> _saveToPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      likedProductIds.map((e) => e.toString()).toList(),
    );
  }

  RxBool isLiked(int productId) {
    return likedProductIds.contains(productId).obs;
  }

  @override
  void onInit() {
    super.onInit();

    animatedFlags.value = List.generate(categories.length, (_) => false);

    // Animate one by one
    for (int i = 0; i < animatedFlags.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        animatedFlags[i] = true;
      });
    }

    //Future.microtask(loadAllData);
    Future.delayed(const Duration(milliseconds: 100), loadAllData);

    // Start auto-slide
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageController.hasClients) {
        final int nextPage = (pageController.page?.round() ?? 0) + 1;
        pageController.animateToPage(
          nextPage % carouselImages.length,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          hasMoreData.value) {
        if (selectedCategory.value == 'All') {
          await fetchProducts();
        }
      }

      if (scrollController.offset > 100 && !showScrollToTop.value) {
        showScrollToTop.value = true;
      } else if (scrollController.offset <= 100 && showScrollToTop.value) {
        showScrollToTop.value = false;
      }
    });

    cartIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    cartScaleAnimation = Tween<double>(begin: 1, end: 1.3)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(cartIconAnimationController);

    debounce<String>(
      searchQuery,
      fetchSearchProducts,
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    super.onClose();
    cartIconAnimationController.dispose();
    pageController.dispose();
    scrollController.dispose();
    overlayEntry?.remove();
    cartKey.currentState?.dispose();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      fetchProducts(),
      fetchFavoriteProductIds(),
    ]);
  }

  final animatedIndexes = <int>{};

  Future<void> changeCategory(String category, String key) async {
    searchQuery.value = '';
    selectedCategory.value = category;
    if (category != 'All') {
      await fetchCategoriesProducts(key);
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  final Map<String, List<ProductModel>> _categoryCache = {};

  Future<void> fetchCategoriesProducts(String category) async {
    if (_categoryCache.containsKey(category)) {
      // Use cached data
      productsCategory.assignAll(_categoryCache[category] ?? []);

      return;
    }
    try {
      isLoading.value = true;
      final http.Response response = await http
          .get(Uri.parse('https://dummyjson.com/products/category/$category'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<ProductModel> productList = (data['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();

        if (productList.isEmpty) {
          Print.info('Empty products ');
          productsCategory.clear();
          return;
        }

        _categoryCache[category] = productList;

        productsCategory.assignAll(productList);
      }
    } on Exception catch (e) {
      productsCategory.clear();
      Print.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSearchProducts(String query) async {
    if (query.isEmpty) {
      productsSearch.clear();
      return;
    }

    try {
      isLoading.value = true;
      final http.Response response = await http
          .get(Uri.parse('https://dummyjson.com/products/search?q=$query'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<ProductModel> productList = (data['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();

        if (productList.isEmpty) {
          Print.info('Empty products');
          productsSearch.clear();

          return;
        }

        productsSearch.assignAll(productList);
      }
    } on Exception catch (e) {
      productsSearch.clear();
      Print.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProducts() async {
    if (isLoading.value || !hasMoreData.value) return;
    try {
      isLoading.value = true;
      final http.Response response = await http.get(
        Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<ProductModel> productList = (data['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();

        if (productList.isEmpty) {
          Print.info('Empty products ');
          // Get.snackbar(
          //   backgroundColor: Colors.black,
          //   colorText: Colors.white,
          //   'Empty',
          //   'No more products available.',
          //   snackPosition: SnackPosition.BOTTOM,
          // );
          hasMoreData.value = false;
        }

        products.addAll(productList);

        skip += limit;
      }
    } catch (e) {
      Print.error('Failed to Fetch Products $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool shouldAnimate(int index) {
    if (!animatedIndexes.contains(index)) {
      animatedIndexes.add(index);
      return true;
    }
    return false;
  }
}
