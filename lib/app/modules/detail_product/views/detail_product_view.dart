import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:food_courier/app/modules/detail_product/controllers/detail_product_controller.dart';
import 'package:food_courier/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class DetailProductView extends StatefulWidget {
  const DetailProductView({super.key});

  @override
  State<DetailProductView> createState() => _DetailProductViewState();
}

class _DetailProductViewState extends State<DetailProductView>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _fadeController;
  late Animation<double> _rippleAnimation1;
  late Animation<double> _rippleAnimation;
  // late Animation<double> _fadeImage;
  // late Animation<double> _fadeContent;

  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _rippleAnimation1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOutCubic,
      ),
    );

    _rippleAnimation = Tween<double>(
      begin: 0,
      end: 1000, // enough to reveal the whole image
    ).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // _fadeImage = Tween<double>(begin: 0, end: 1).animate(
    //   CurvedAnimation(
    //     parent: _fadeController,
    //     curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
    //   ),
    // );

    // _fadeContent = Tween<double>(begin: 0, end: 1).animate(
    //   CurvedAnimation(
    //     parent: _fadeController,
    //     curve: const Interval(0.6, 1, curve: Curves.easeIn),
    //   ),
    // );

    const itemCount = 7;
    const double step = 1.0 / itemCount;

    _fadeAnimations = [];
    _slideAnimations = [];

    for (int i = 0; i < itemCount; i++) {
      double start = i * step;
      double end = start + step * 0.8;

      _fadeAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Interval(start, end, curve: Curves.easeIn),
          ),
        ),
      );

      _slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.5), // Slide up from below
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
    }

    // _fadeAnimations = List.generate(4, (index) {
    //   const double step = 0.25;
    //   return createFadeInterval(
    //     controller: _fadeController,
    //     start: index * step,
    //     end: (index + 1) * step,
    //   );
    // });

    Future.delayed(const Duration(milliseconds: 100), () {
      _rippleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Animation<double> createFadeInterval({
    required AnimationController controller,
    required double start,
    required double end,
  }) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeIn),
      ),
    );
  }

  Widget fadeInUpItem(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProductModel product = Get.arguments;
    final Size size = MediaQuery.of(context).size;
    final DetailProductController controller =
        Get.put(DetailProductController());
    final HomeController homeController = Get.put(HomeController());

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white24,
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground,
              ],
              background: AnimatedBuilder(
                animation: _rippleAnimation1,
                builder: (_, __) {
                  return CustomPaint(
                    painter: GradientRipplePainter(
                      radius: _rippleAnimation1.value * size.width * 1.5,
                    ),
                    child: ClipPath(
                      clipper: RippleRevealClipper(_rippleAnimation.value),
                      child: Obx(
                        () => Center(
                          child: GestureDetector(
                            onPanUpdate: controller.updateRotation,
                            // onPanEnd: (_) => controller.resetRotation(),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateX(controller.rotateX.value)
                                ..rotateY(controller.rotateY.value),
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // fadeInUpItem(
                  //   0,
                  //   Text(
                  //     product.title,
                  //     style: const TextStyle(
                  //       fontSize: 24,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(), // For the title (takes remaining space)
                      1: IntrinsicColumnWidth(), // For the heart icon (fixed size)
                    },
                    children: [
                      TableRow(
                        children: [
                          fadeInUpItem(
                            0,
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          fadeInUpItem(
                            0,
                            Obx(() {
                              final bool isLiked =
                                  homeController.isLiked(product.id).value;

                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                child: IconButton(
                                  onPressed: () => homeController
                                      .addFavoriteProductToCollectionUsersWithSubCollectionFavorites(
                                    product,
                                  ),
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
                                      key: ValueKey<bool>(isLiked),
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),

                  fadeInUpItem(
                    1,
                    StarRating(
                      rating: product.rating,
                      size: 20,
                      filledColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  fadeInUpItem(
                    2,
                    Text(
                      '₱ ${product.price}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontSize: 22,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  fadeInUpItem(
                    3,
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  fadeInUpItem(
                    4,
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20), // Space for the button
                  fadeInUpItem(
                    5,
                    Obx(
                      () => TextButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(Colors.blue),
                        ),
                        onPressed: controller.toggleReviews,
                        child: Text(
                          controller.showReviews.value
                              ? 'Hide Reviews'
                              : 'Show Reviews',
                        ),
                      ),
                    ),
                  ),
                  // ReviewToggleWidget(
                  //   reviews: product.reviews,
                  // ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final Review review = product.reviews[index];
                return Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 100),
                      firstChild: const SizedBox.shrink(),
                      secondChild: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ⭐ Star rating row
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),

                              // 💬 Comment
                              Text(
                                review.comment,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),

                              // 👤 Reviewer name and 📅 date
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review.reviewerName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),

                              // Optional 📧 Email
                              Text(
                                review.reviewerEmail,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ), // from previous answer
                      crossFadeState: controller.showReviews.value
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),
                  ),
                );
              },
              childCount: product.reviews.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: fadeInUpItem(
        6,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 22),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (homeController.cartProducts.containsKey(product.id)) {
                  return;
                }
                homeController.addToCart(product);
              },
              child: Text(
                homeController.cartProducts.containsKey(product.id)
                    ? 'Added'
                    : 'Add to Cart',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  const StarRating({
    required this.rating,
    super.key,
    this.size = 24,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.grey,
  });
  final double rating;
  final double size;
  final Color filledColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    final double rounded = (rating * 2).round() / 2;
    final int fullStars = rounded.floor();
    final hasHalf = (rounded - fullStars) == 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: filledColor, size: size);
        } else if (index == fullStars && hasHalf) {
          return Icon(Icons.star_half, color: filledColor, size: size);
        } else {
          return Icon(Icons.star_border, color: emptyColor, size: size);
        }
      }),
    );
  }
}

class ReviewList extends StatelessWidget {
  const ReviewList({required this.reviews, super.key});
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final Review review = reviews[index];
          return Card(
            color: Colors.blue.shade50,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐ Star rating row
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),

                  // 💬 Comment
                  Text(
                    review.comment,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),

                  // 👤 Reviewer name and 📅 date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.reviewerName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),

                  // Optional 📧 Email
                  Text(
                    review.reviewerEmail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReviewToggleWidget extends StatelessWidget {
  ReviewToggleWidget({required this.reviews, super.key});
  final DetailProductController controller = Get.put(DetailProductController());
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 👇 Toggle button
        Obx(
          () => TextButton(
            onPressed: controller.toggleReviews,
            child: Text(
              controller.showReviews.value ? 'Hide Reviews' : 'Show Reviews',
            ),
          ),
        ),

        // 👇 Animated transition
        Obx(
          () => AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstChild: const SizedBox.shrink(),
            secondChild: ReviewList(reviews: reviews), // from previous answer
            crossFadeState: controller.showReviews.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ),
      ],
    );
  }
}

class RippleRevealClipper extends CustomClipper<Path> {
  RippleRevealClipper(this.radius);
  final double radius;

  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from bottom-left
    final center = Offset(0, size.height);

    // Draw a circle path that will reveal the image
    path.addOval(Rect.fromCircle(center: center, radius: radius));

    return path;
  }

  @override
  bool shouldReclip(covariant RippleRevealClipper oldClipper) {
    return oldClipper.radius != radius;
  }
}

/// 🎨 Gradient ripple painter (limited to image area only)

class GradientRipplePainter extends CustomPainter {
  GradientRipplePainter({required this.radius});
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    // 🟢 Origin point for the ripple: bottom-left corner
    final center = Offset(0, size.height);

    // 📦 Target rectangle: full size
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 🎨 Radial gradient starting from bottom-left and expanding
    final gradient = RadialGradient(
      center: Alignment.bottomLeft, // bottom-left in alignment space
      radius: 2, // wide enough to reach top-right
      colors: [
        Colors.white.withValues(alpha: 0.4),
        Colors.grey.shade300.withValues(alpha: 0.2),
        Colors.black,
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant GradientRipplePainter oldDelegate) {
    return radius != oldDelegate.radius;
  }
}

// class GradientRipplePainter extends CustomPainter {
//   GradientRipplePainter({required this.radius});
//   final double radius;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(0, size.height); // 🔽 bottom-left origin

//     final gradient = RadialGradient(
//       center: Alignment.bottomLeft, // Focus from bottom-left
//       radius: 1, // Fill more of the rect
//       colors: [
//         Colors.white.withValues(0.4),
//         Colors.red.shade300.withValues(0.2),
//         Colors.blue,
//       ],
//       stops: const [0.1, 0.5, 1.0],
//     );

//     final paint = Paint()
//       ..shader = gradient.createShader(
//         Rect.fromCircle(center: center, radius: radius),
//       );

//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     canvas.drawRect(rect, paint); // ✅ Draw rectangle with gradient
//   }

//   @override
//   bool shouldRepaint(covariant GradientRipplePainter oldDelegate) {
//     return radius != oldDelegate.radius;
//   }
// }

// class GradientRipplePainter extends CustomPainter {
//   GradientRipplePainter({required this.radius});
//   final double radius;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);

//     final gradient = RadialGradient(
//       radius: 0.6,
//       colors: [
//         Colors.white.withValues(alpha: 0.4),
//         Colors.grey.shade300.withValues(alpha: 0.2),
//         Colors.transparent,
//       ],
//       stops: const [0.1, 0.4, 1.0],
//     );

//     final paint = Paint()
//       ..shader = gradient
//           .createShader(Rect.fromCircle(center: center, radius: radius));

//     canvas.drawCircle(center, radius, paint);
//   }

//   @override
//   bool shouldRepaint(covariant GradientRipplePainter oldDelegate) {
//     return radius != oldDelegate.radius;
//   }
// }
