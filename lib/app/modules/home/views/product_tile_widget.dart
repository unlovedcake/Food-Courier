import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:food_courier/app/modules/home/controllers/home_controller.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ProductTileWidget extends StatefulWidget {
  const ProductTileWidget({
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
  State<ProductTileWidget> createState() => _ProductTileWidgetState();
}

class _ProductTileWidgetState extends State<ProductTileWidget>
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _animation,
        child: Obx(
          () => AnimatedContainer(
            key: ValueKey<int>(
              widget.product.id,
            ),
            duration: const Duration(microseconds: 500),
            curve: Curves.bounceIn,
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
                          onTap: () async {
                            await Get.toNamed(
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
                              onPressed: () {
                                controller
                                    .addFavoriteProductToCollectionUsersWithSubCollectionFavorites(
                                  widget.product,
                                );
                                //controller.toggleLike(widget.product.id);
                              },
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Text(
                        widget.product.title,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(),
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
                                    : Colors.black,
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
                                            controller.cartProducts[
                                                widget.product.id];

                                        if (cartProduct != null &&
                                            cartProduct.id ==
                                                widget.product.id) {
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
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
