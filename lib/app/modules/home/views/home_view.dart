import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    // final List<Map<String, dynamic>> products = List.generate(
    //   10,
    //   (index) => {
    //     'name': 'Product $index',
    //     'image':
    //         'https://media.istockphoto.com/id/1048400936/photo/whole-italian-pizza-on-wooden-table-with-ingredients.jpg?s=612x612&w=0&k=20&c=_1GwSXSjFeC06w3MziyeqRk5Lx-FMXUZzCpxEOoHyzQ=',
    //   },
    // );

    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       CustomScrollView(
    //         slivers: [
    //           SliverAppBar(
    //             floating: true,
    //             pinned: true,
    //             title: const Text('Products'),
    //             actions: [
    //               Padding(
    //                 padding: const EdgeInsets.only(right: 16),
    //                 child:
    //                     Icon(Icons.shopping_cart, key: cartController.cartKey),
    //               ),
    //             ],
    //           ),
    //           SliverList(
    //             delegate: SliverChildBuilderDelegate(
    //               (context, index) {
    //                 final Map<String, dynamic> product = products[index];
    //                 final GlobalKey<State<StatefulWidget>> imageKey =
    //                     GlobalKey();

    //                 return Padding(
    //                   padding: const EdgeInsets.all(8),
    //                   child: Card(
    //                     child: Row(
    //                       children: [
    //                         Image.network(
    //                           product['image'],
    //                           key: imageKey,
    //                           width: 80,
    //                           height: 80,
    //                         ),
    //                         const SizedBox(width: 10),
    //                         Expanded(child: Text(product['name'])),
    //                         TextButton(
    //                           onPressed: () => cartController.animateToCart(
    //                             imageKey,
    //                             context,
    //                           ),
    //                           child: const Text('Add to Cart'),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 );
    //               },
    //               childCount: products.length,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );

    return Obx(
      () => Scaffold(
        body: CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              floating: true,
              pinned: true,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.blurBackground],
                centerTitle: true,
                background: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: controller.pageController,
                      itemCount: controller.carouselImages.length,
                      onPageChanged: (index) {
                        controller.currentPage.value = index;
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          controller.carouselImages[index],
                          key: ValueKey(controller.carouselImages[index]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.carouselImages.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: controller.currentPage.value == index
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Dark Top Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54, // darker at top
                              Colors.transparent, // fades out
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Text at Top-Left
                    Positioned(
                      top: 30,
                      left: 20,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                          children: [
                            TextSpan(text: 'Up to\n'),
                            TextSpan(
                              text: '70% ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                                color: Colors.red,
                              ),
                            ),
                            TextSpan(text: 'Off\nwith free delivery'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                title: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: AnimatedTextReveal(
                    text: 'Click & Get',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              actions: [
                ScaleTransition(
                  scale: controller.cartScaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: IconButton(
                      key: controller.cartKey,
                      tooltip: 'Cart',
                      onPressed: () {
                        Get.toNamed(AppPages.CART);
                      },
                      icon: Badge(
                        label: controller.cartProducts.isEmpty
                            ? null
                            : ScaleTransition(
                                scale: controller.cartScaleAnimation,
                                child: Text(
                                  controller.cartProducts.length.toString(),
                                ),
                              ),
                        offset: const Offset(6, -6),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // ScaleTransition(
                //   scale: controller.cartScaleAnimation,
                //   child: IconButton(
                //     key: controller.cartKey,
                //     icon: const Icon(
                //       Icons.shopping_cart,
                //       color: Colors.white,
                //     ),
                //     onPressed: () {},
                //   ),
                // ),
              ],
            ),

            SliverAppBar(
              pinned: true,
              centerTitle: true,
              backgroundColor: Colors.white,
              // bottom: const PreferredSize(
              //   preferredSize: Size.fromHeight(20),
              //   child: SizedBox(),
              // ),
              flexibleSpace: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 45,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: controller.onSearchChanged,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    hintText: 'Search...',
                    hintStyle: const TextStyle(fontSize: 16),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: MyCustomHeaderDelegate(
                height: controller.showScrollToTop.value ? 70 : 90,
                // height: controller.showScrollToTop.value ? 140 : 160,
                child: Obx(() {
                  final bool shrink = controller.showScrollToTop.value;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: Colors.white,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✅ Animated Search Field
                        // AnimatedContainer(
                        //   duration: const Duration(milliseconds: 300),
                        //   height: shrink ? 40 : 50,
                        //   margin: const EdgeInsets.symmetric(
                        //     horizontal: 16,
                        //     vertical: 8,
                        //   ),
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(28),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.grey.withOpacity(0.2),
                        //         blurRadius: 12,
                        //         offset: const Offset(0, 6),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Center(
                        //     child: TextField(
                        //       style: TextStyle(fontSize: shrink ? 14 : 18),
                        //       decoration: InputDecoration(
                        //         icon: Icon(
                        //           Icons.search,
                        //           color: Colors.grey[600],
                        //           size: shrink ? 18 : 24,
                        //         ),
                        //         hintText: 'Search...',
                        //         hintStyle:
                        //             TextStyle(fontSize: shrink ? 14 : 16),
                        //         border: InputBorder.none,
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        // ✅ Animated Category List
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: shrink ? 30 : 40,
                          child: Obx(() {
                            if (controller.animatedFlags.isEmpty) {
                              return const SizedBox();
                            }
                            final List<MapEntry<String, String>>
                                categoryEntries =
                                controller.categories.entries.toList();

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categoryEntries.length,
                              itemBuilder: (context, index) {
                                final String key = categoryEntries[index].key;
                                final String categoryName =
                                    categoryEntries[index].value;
                                // final String category =
                                //     controller.categories[index];
                                // final isSelected =
                                //     controller.selectedCategory.value ==
                                //         category;

                                final bool isVisible =
                                    controller.animatedFlags.length > index &&
                                        controller.animatedFlags[index];

                                // return Obx(
                                //   () => AnimatedCategoryButton(
                                //     label: controller.categories[index],
                                //     isSelected:
                                //         controller.selectedCategory.value ==
                                //             controller.categories[index],
                                //     onTap: () => controller.changeCategory(
                                //       controller.categories[index],
                                //     ),
                                //   ),
                                // );

                                return Obx(
                                  () => AnimatedOpacity(
                                    opacity: isVisible ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 500),
                                    child: AnimatedSlide(
                                      offset: isVisible
                                          ? Offset.zero
                                          : const Offset(-0.3, 0),
                                      duration:
                                          const Duration(milliseconds: 800),
                                      child: InkWell(
                                        splashColor: Colors.blueAccent
                                            .withValues(alpha: 0.3),
                                        onTap: () => controller.changeCategory(
                                          categoryName,
                                          key,
                                        ),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: shrink ? 12 : 20,
                                            vertical: shrink ? 6 : 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: controller.selectedCategory
                                                        .value ==
                                                    categoryName
                                                ? Colors.deepOrange
                                                : Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              categoryName,
                                              style: TextStyle(
                                                fontSize: shrink ? 12 : 14,
                                                color: controller
                                                            .selectedCategory
                                                            .value ==
                                                        categoryName
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ProductModel product =
                        controller.selectedCategory.value != 'All' &&
                                controller.searchQuery.value == ''
                            ? controller.productsCategory[index]
                            : controller.searchQuery.value == ''
                                ? controller.products[index]
                                : controller.productsSearch[index];
                    final GlobalKey<State<StatefulWidget>> imageKey =
                        GlobalKey();
                    final bool animate =
                        controller.shouldAnimate(index); // Check only once
                    return ProductTile(
                      product: product,
                      imageKey: imageKey,
                      index: index,
                      shouldAnimate: animate,
                    );
                  },
                  childCount: controller.selectedCategory.value != 'All' &&
                          controller.searchQuery.value == ''
                      ? controller.productsCategory.length
                      : controller.searchQuery.value == ''
                          ? controller.products.length
                          : controller.productsSearch.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250, // Max width for each item
                  // crossAxisCount: Get.width < 800
                  //     ? 2
                  //     : Get.width > 800 || Get.width < 1024
                  //         ? 3
                  //         : 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.61,
                ),
              ),
            ),

            // Loading Indicator
            if (controller.isLoading.value)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // Optional: You can remove this if you show "No more products" using ScaffoldMessenger
            if (!controller.hasMoreData.value)
              const SliverToBoxAdapter(
                child: Text(
                  'No more products',
                  style: TextStyle(fontSize: 16),
                ), // Add some space
              ),
          ],
        ),
      ),
    );
  }
}

class SwipeRotateLive extends StatefulWidget {
  const SwipeRotateLive({super.key});

  @override
  _SwipeRotateLiveState createState() => _SwipeRotateLiveState();
}

class _SwipeRotateLiveState extends State<SwipeRotateLive> {
  double _rotationY = 0;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Drag sensitivity control
      _rotationY += details.delta.dx * 0.01;
    });
  }

  Matrix4 _buildTransform(double rotationY) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // add perspective
      ..rotateY(rotationY);

    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        child: Transform(
          transform: _buildTransform(_rotationY),
          alignment: Alignment.center,
          child: Image.network(
            'https://imgd.aeplcdn.com/370x208/n/cw/ec/139585/harrier-ev-exterior-right-front-three-quarter-18.jpeg?isig=0&q=80',
            width: 400,
            height: 400,
          ),
        ),
      ),
    );
  }
}

class AnimatedTextReveal extends StatefulWidget {
  const AnimatedTextReveal({
    required this.text,
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 120),
  });
  final String text;
  final TextStyle? style;
  final Duration duration;

  @override
  State<AnimatedTextReveal> createState() => _AnimatedTextRevealState();
}

class _AnimatedTextRevealState extends State<AnimatedTextReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int totalChars;

  @override
  void initState() {
    super.initState();
    totalChars = widget.text.length;
    _controller = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: widget.duration.inMilliseconds * totalChars),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getProgress(int index) {
    final double step = 1.0 / totalChars;
    final double revealStart = step * index;
    final double revealEnd = step * (index + 1);
    final double value = _controller.value;

    if (value < revealStart) return 0;
    if (value > revealEnd) return 1;

    // Normalized progress between revealStart and revealEnd
    return (value - revealStart) / step;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.text.length, (index) {
            final double progress = _getProgress(index);
            final double opacity = progress.clamp(0.0, 1.0);
            final double scale = 0.8 + 0.2 * progress; // Scale from 0.8 → 1.0

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  widget.text[index],
                  style: widget.style,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class MyCustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  MyCustomHeaderDelegate({
    required this.height,
    required this.child,
  });
  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant MyCustomHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class AnimatedCategoryButton extends StatefulWidget {
  const AnimatedCategoryButton({
    required this.isSelected,
    required this.onTap,
    required this.label,
    super.key,
  });
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  @override
  State<AnimatedCategoryButton> createState() => _AnimatedCategoryButtonState();
}

class _AnimatedCategoryButtonState extends State<AnimatedCategoryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(covariant AnimatedCategoryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !_wasSelected) {
      _controller.forward(from: 0);
    }
    _wasSelected = widget.isSelected;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: widget.isSelected ? 0 : 1,
        end: widget.isSelected ? 1 : 0,
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final Color backgroundColor = widget.isSelected
            ? Color.lerp(Colors.grey.shade200, Colors.blueAccent, value)!
            : Colors.grey.shade200;

        final Color textColor =
            Color.lerp(Colors.black87, Colors.white, value)!;

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
