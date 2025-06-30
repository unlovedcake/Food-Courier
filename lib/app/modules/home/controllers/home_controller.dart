import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final cartKey = GlobalKey();
  late AnimationController cartIconAnimationController;
  late Animation<double> cartScaleAnimation;

  final PageController pageController = PageController();

  // RxList products = [].obs;

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

  final List<String> carouselImages = [
    'https://media.istockphoto.com/id/1266459481/vector/shopping-online-in-smartphone-application-digital-marketing-vector-illustration.jpg?s=612x612&w=0&k=20&c=yFTkURyuo4e0qxfCBgISPps6MwYLNAqShj_lxPs2IrQ=',
    'https://media.istockphoto.com/id/941302930/vector/online-shopping-smartphone-turned-into-internet-shop-concept-of-mobile-marketing-and-e.jpg?s=612x612&w=0&k=20&c=oEaIaAVRL6w7juxEIVwFPISjW_XkoYbLmK_VRWjNaEk=',
    'https://static.vecteezy.com/system/resources/thumbnails/023/309/702/small/ai-generative-e-commerce-concept-shopping-cart-with-boxes-on-a-wooden-table-photo.jpg',
  ];

  OverlayEntry? overlayEntry;

  final cartItems = <int>[].obs;

  final RxList<bool> animatedFlags = <bool>[].obs;

  // RxMap<int, int> isAdded = <int, int>{}.obs;

  RxMap<int, ProductModel> cartProducts = <int, ProductModel>{}.obs;

  RxInt countIncrement = 1.obs;

  void addToCart(ProductModel product) {
    cartItems.add(product.id);

    // cartProducts.putIfAbsent(
    //   product.id,
    //   () => product,
    // );

    // isAdded.update(
    //   product.id,
    //   (qty) {
    //     product.countItem.value++;
    //     return qty + 1;
    //   },
    //   ifAbsent: () => 1,
    // );

    final ProductModel? existingProduct = cartProducts[product.id];

    if (existingProduct == null) {
      product.countItem.value = 1;
      cartProducts[product.id] = product;
    } else {
      existingProduct.countItem.value++;
    }
    // cartProducts.update(
    //   product.id,
    //   (existing) => existing.copyWith(countItem: countIncrement++),
    //   ifAbsent: () {
    //     product.countItem.value = 1;

    //     return product;
    //   },
    // );
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
        debugPrint(e.toString());
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

  // List<String> categories = [
  //   'All',
  //   'beauty',
  //   'fragrances',
  //   'furniture',
  //   'groceries',
  //   'home-decoration',
  //   'kitchen-accessories',
  //   'laptops',
  //   'mens-shirts',
  //   'mens-shoes',
  //   'mens-watches',
  //   'mobile-accessories',
  //   'motorcycle',
  //   'skin-care',
  //   'smartphones',
  //   'sports-accessories',
  //   'sunglasses',
  //   'tablets',
  //   'tops',
  //   'vehicle',
  //   'womens-bags',
  //   'womens-dresses',
  //   'womens-jewellery',
  //   'womens-shoes',
  //   'womens-watches',
  // ];

  List<Map<String, String>> allFoods = [
    {
      'name': 'Cheese Pizza',
      'category': 'Pizza',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Veg Burger',
      'category': 'Burger',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Coke',
      'category': 'Drinks',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Chocolate Cake',
      'category': 'Dessert',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Pepsi',
      'category': 'Drinks',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Cheese Pizza',
      'category': 'Pizza',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Veg Burger',
      'category': 'Burger',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Coke',
      'category': 'Drinks',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Chocolate Cake',
      'category': 'Dessert',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Pepsi',
      'category': 'Drinks',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Cheese Pizza',
      'category': 'Pizza',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Veg Burger',
      'category': 'Burger',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Coke',
      'category': 'Drinks',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Chocolate Cake',
      'category': 'Dessert',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Pepsi',
      'category': 'Drinks',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Cheese Pizza',
      'category': 'Pizza',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Veg Burger',
      'category': 'Burger',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Coke',
      'category': 'Drinks',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Chocolate Cake',
      'category': 'Dessert',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
    {
      'name': 'Pepsi',
      'category': 'Drinks',
      'imageUrl':
          'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    },
  ];

  List<Map<String, String>> get filteredFoods {
    if (selectedCategory.value == 'All') return allFoods;
    return allFoods
        .where((item) => item['category'] == selectedCategory.value)
        .toList();
  }

  final RxInt currentPage = 0.obs;

  Future<void> loadLikedProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedIds = prefs.getStringList(_key);
    if (savedIds != null) {
      likedProductIds.addAll(savedIds.map(int.parse));
    }
  }

  Future<void> toggleLike(int productId) async {
    if (likedProductIds.contains(productId)) {
      likedProductIds.remove(productId);
    } else {
      likedProductIds.add(productId);
    }
    await _saveToPrefs();
  }

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
        await fetchProducts();
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
    cartIconAnimationController.dispose();
    super.onClose();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      fetchProducts(),
      loadLikedProducts(),
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
      print('ssss ${_categoryCache[category]!.length}');
      return;
    }
    try {
      isLoading.value = true;
      final http.Response response = await http
          .get(Uri.parse('https://dummyjson.com/products/category/$category'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<ProductModel> productList = (data['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();

        if (productList.isEmpty) {
          print('Empty products ');
          productsCategory.clear();
          return;
        }

        _categoryCache[category] = productList;

        productsCategory.assignAll(productList);
      }
    } catch (e) {
      productsCategory.clear();
      print('Error: $e');
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
        final data = jsonDecode(response.body);
        final List<ProductModel> productList = (data['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();

        if (productList.isEmpty) {
          print('Empty products ');
          productsSearch.clear();
          return;
        }

        productsSearch.assignAll(productList);
      }
    } catch (e) {
      productsSearch.clear();
      debugPrint('Error: $e');
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
        final data = jsonDecode(response.body);
        final List<ProductModel> productList = (data['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();

        if (productList.isEmpty) {
          print('Empty products ');
          hasMoreData.value = false;
        }

        products.addAll(productList);

        skip += limit;
      }
    } catch (e) {
      debugPrint('Failed to Fetch Products $e');
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

class ProductTile extends StatefulWidget {
  const ProductTile({
    required this.product,
    required this.imageKey,
    required this.index,
    this.shouldAnimate = true,
    super.key,
  });
  final ProductModel product;
  final GlobalKey<State<StatefulWidget>> imageKey;
  final int index;
  final bool shouldAnimate;

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    if (widget.shouldAnimate) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0; // Skip animation
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return ScaleTransition(
      scale: _animation,
      child: Obx(
        () => AnimatedContainer(
          key: ValueKey<int>(
            widget.product.id,
          ),
          duration: const Duration(microseconds: 500),
          curve: Curves.bounceIn,
          // shape: widget.product.isAdded.value
          //     ? RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(15),
          //         side: const BorderSide(
          //           color: Colors.blue, // border color
          //           width: 2, // border width
          //         ),
          //       )
          //     : null,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // Light background
            borderRadius: BorderRadius.circular(20),
            boxShadow: controller.cartProducts.containsKey(widget.product.id)
                ? [
                    const BoxShadow(
                      color: Colors.blueGrey,
                      offset: Offset(2, 2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-4, -4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            AppPages.DETAIL_PRODUCT,
                            arguments: widget.product,
                          );
                        },
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Hero(
                            tag: widget.product.id,
                            child: Image.network(
                              key: widget.imageKey,
                              widget.product.thumbnail,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Obx(() {
                          final ProductModel? cartProduct =
                              controller.cartProducts[widget.product.id];
                          return Container(
                            width: 40,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: cartProduct == null
                                  ? null
                                  : Text(
                                      cartProduct.countItem.toString(),
                                      key: ValueKey(
                                        cartProduct.countItem.toString(),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                            ),
                          );
                        }),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Obx(() {
                          final bool isLiked =
                              controller.isLiked(widget.product.id).value;

                          return IconButton(
                            onPressed: () =>
                                controller.toggleLike(widget.product.id),
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey<bool>(
                                  isLiked,
                                ), // important for animation to trigger
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 26,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      widget.product.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                    ),
                  ),
                  Text(
                    widget.product.price.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width:
                        controller.cartProducts.containsKey(widget.product.id)
                            ? 180
                            : 150,
                    height: 45,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // controller.isAdded.putIfAbsent(
                              //   widget.product.id,
                              //   () => widget.product.id,
                              // );

                              // if (!controller.isAdded
                              //     .contains(widget.product.id)) {
                              //   controller.isAdded.add(widget.product.id);
                              // }

                              controller
                                ..addToCart(widget.product)
                                ..startAnimation(
                                  widget.imageKey,
                                  context,
                                  widget.product.thumbnail,
                                  widget.index,
                                );
                              // widget.product.isAdded.add(widget.product.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.cartProducts
                                      .containsKey(widget.product.id)
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              Icons.add,
                              color: controller.cartProducts
                                      .containsKey(widget.product.id)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            label: FittedBox(
                              child: Text(
                                controller.cartProducts
                                        .containsKey(widget.product.id)
                                    ? 'Added'
                                    : 'Add to Cart',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: controller.cartProducts
                                              .containsKey(widget.product.id)
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: controller.cartProducts
                                  .containsKey(widget.product.id)
                              ? 1.0
                              : 0.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: controller.cartProducts
                                  .containsKey(widget.product.id)
                              ? Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final ProductModel? cartProduct =
                                          controller
                                              .cartProducts[widget.product.id];

                                      if (cartProduct != null &&
                                          cartProduct.id == widget.product.id) {
                                        if (cartProduct.countItem.value > 0) {
                                          cartProduct.countItem.value -= 1;
                                          if (cartProduct.countItem.value ==
                                              0) {
                                            controller.cartProducts
                                                .remove(widget.product.id);
                                          }
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: const CircleBorder(),
                                      minimumSize: const Size(40, 40),
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Icon(Icons.remove, size: 20),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.white,
              //     foregroundColor: Colors.green,
              //   ),
              //   onPressed: () {
              //     controller.addToCart(widget.index);
              //     controller.startAnimation(
              //       widget.imageKey,
              //       context,
              //       widget.product.thumbnail,
              //       widget.index,
              //     );
              //     widget.product.isAdded.value = true;
              //   },
              //   child: Text(
              //     widget.product.isAdded.value
              //         ? 'Added To Cart'
              //         : 'Add To Cart',
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
