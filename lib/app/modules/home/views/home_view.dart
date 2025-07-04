import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_courier/app/core/theme_controller.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:food_courier/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:food_courier/app/modules/home/views/product_tile_widget.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final DashboardController dashBoardController =
        Get.put(DashboardController());
    final ThemeController themeController = Get.find();

    return Obx(
      () => Scaffold(
        body: CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 2,
              leadingWidth: 100,
              automaticallyImplyLeading: false,
              floating: true,
              pinned: true,
              expandedHeight: 180,
              collapsedHeight: 80,
              stretch: true,
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
                        return Image.asset(
                          controller.carouselImages[index],
                          key: ValueKey(controller.carouselImages[index]),
                          fit: BoxFit.cover,
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
                    // Positioned.fill(
                    //   child: Container(
                    //     decoration: const BoxDecoration(
                    //       gradient: LinearGradient(
                    //         begin: Alignment.topCenter,
                    //         end: Alignment.bottomCenter,
                    //         colors: [
                    //           Colors.black54, // darker at top
                    //           Colors.transparent, // fades out
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // Text at Top-Left
                    // Positioned(
                    //   top: 50,
                    //   left: 30,
                    //   child: RichText(
                    //     text: TextSpan(
                    //       style:
                    //           Theme.of(context).textTheme.labelLarge?.copyWith(
                    //                 fontSize: 18,
                    //                 color: Colors.white,
                    //               ),
                    //       children: [
                    //         const TextSpan(text: 'Up to\n'),
                    //         TextSpan(
                    //           text: '70% ',
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .labelLarge
                    //               ?.copyWith(
                    //                 fontSize: 35,
                    //                 color: Colors.red,
                    //               ),
                    //         ),
                    //         const TextSpan(text: 'Off\nwith free delivery'),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedTextReveal(
                        duration: const Duration(milliseconds: 450),
                        text: 'Shop Swift',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 18,
                              color: Colors.orange,
                            ),
                      ),
                      Text(
                        'Up to 50% off with free delivery',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/app_logo.png',
                ),
              ),
              actions: [
                // Obx(
                //   () => IconButton(
                //     tooltip: 'Notification',
                //     onPressed: () async {
                //       await dashBoardController.markMessageAsRead();
                //       await Get.toNamed(AppPages.CHAT);
                //     },
                //     icon: Badge(
                //       backgroundColor: Colors.white,
                //       label: dashBoardController.isRead.value
                //           ? null
                //           : const CircleAvatar(
                //               radius: 2,
                //               backgroundColor: Colors.red,
                //             ),
                //       offset: const Offset(6, -6),
                //       child: const Icon(
                //         Icons.notification_important,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      themeController.isDarkMode.value
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Colors.grey,
                    ),
                    onPressed: themeController.toggleTheme,
                  ),
                ),
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
                        backgroundColor: Colors.red,
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
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),

            SliverAppBar(
              collapsedHeight: 70,
              expandedHeight: 60,
              pinned: true,
              centerTitle: true,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isDesktop = constraints.maxWidth > 1024;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 300 : 4,
                        vertical: 4,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          //color: Theme.of(context).colorScheme.surfaceContainer,
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
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
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
                    );
                  },
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: MyCustomHeaderDelegate(
                height: controller.showScrollToTop.value ? 60 : 80,
                child: Obx(() {
                  final bool shrink = controller.showScrollToTop.value;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: Colors.white,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      spacing: 10,
                      children: [
                        // ✅ Animated Category List
                        ScrollConfiguration(
                          behavior: WebScrollBehavior(),
                          child: AnimatedContainer(
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
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: categoryEntries.length,
                                itemBuilder: (context, index) {
                                  final String key = categoryEntries[index].key;
                                  final String categoryName =
                                      categoryEntries[index].value;

                                  final bool isVisible =
                                      controller.animatedFlags.length > index &&
                                          controller.animatedFlags[index];

                                  return Obx(
                                    () => AnimatedOpacity(
                                      opacity: isVisible ? 1.0 : 0.0,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: AnimatedSlide(
                                        offset: isVisible
                                            ? Offset.zero
                                            : const Offset(-0.3, 0),
                                        duration:
                                            const Duration(milliseconds: 800),
                                        child: InkWell(
                                          splashColor: Colors.blueAccent
                                              .withValues(alpha: 0.3),
                                          onTap: () =>
                                              controller.changeCategory(
                                            categoryName,
                                            key,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: shrink ? 12 : 20,
                                              vertical: shrink ? 6 : 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: controller.selectedCategory
                                                          .value ==
                                                      categoryName
                                                  ? Colors.orange
                                                  : Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Text(
                                                categoryName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize:
                                                          shrink ? 12 : 14,
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
                    return ProductTileWidget(
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
                  childAspectRatio: 0.59,
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
            // if (!controller.hasMoreData.value)
            //   const SliverToBoxAdapter(
            //     child: Text(
            //       'No more products',
            //       style: TextStyle(fontSize: 16),
            //     ), // Add some space
            //   ),
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
    )..repeat();
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

// 👇 This enables pointer device support on web
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
