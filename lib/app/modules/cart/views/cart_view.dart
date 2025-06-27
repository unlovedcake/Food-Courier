import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/product_model.dart';
import 'package:food_courier/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});
  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        final List<ProductModel> items =
            homeController.cartProducts.values.toList();
        if (items.isEmpty) {
          return const Center(
            child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final ProductModel product = items[index];
            return FadeTransition(
              opacity: controller.fadeAnimations[index],
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    alignment: Alignment.center,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 100,
                            height: double.infinity,
                            color:
                                Colors.blue.shade50, // 🎨 Background color here
                            child: Hero(
                              tag: product.id,
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Title and Quantity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Price: ${product.price}'),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 10,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding:
                                    const EdgeInsets.all(16), // Adjust for size
                                backgroundColor: Colors.white, // Button color
                              ),
                              //padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (product.countItem.value > 1) {
                                  product.countItem.value--;
                                }
                              },
                            ),
                            Obx(
                              () => Text(
                                product.countItem.value.toString(),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding:
                                    const EdgeInsets.all(16), // Adjust for size
                                backgroundColor: Colors.white, // Button color
                              ),
                              child: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                product.countItem.value++;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    // child: Table(
                    //   columnWidths: const {
                    //     0: FixedColumnWidth(60), // for avatar
                    //     1: FlexColumnWidth(), // for title & subtitle
                    //     2: FixedColumnWidth(100), // for buttons
                    //   },
                    //   children: [
                    //     TableRow(
                    //       children: [
                    //         // Leading: Avatar
                    //         Padding(
                    //           padding: const EdgeInsets.all(8),
                    //           child: CircleAvatar(
                    //             backgroundColor: Colors.blue.shade50,
                    //             child: Image.network(
                    //               product.thumbnail,
                    //               width: 50,
                    //               height: 50,
                    //             ),
                    //           ),
                    //         ),

                    //         // Title & Subtitle
                    //         Padding(
                    //           padding: const EdgeInsets.symmetric(vertical: 8),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 product.title,
                    //                 style: const TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.w600,
                    //                 ),
                    //               ),
                    //               const SizedBox(height: 4),
                    //               Text('Qty: ${product.price}'),
                    //             ],
                    //           ),
                    //         ),

                    //         // Trailing: Buttons
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Row(
                    //               mainAxisAlignment: MainAxisAlignment.end,
                    //               children: [
                    //                 IconButton(
                    //                   icon: const Icon(
                    //                     Icons.remove_circle_outline,
                    //                   ),
                    //                   onPressed: () {
                    //                     if (product.countItem.value > 1) {
                    //                       product.countItem.value--;
                    //                     }
                    //                   },
                    //                 ),
                    //                 Obx(
                    //                   () => Text(
                    //                     product.countItem.value.toString(),
                    //                   ),
                    //                 ),
                    //                 IconButton(
                    //                   icon:
                    //                       const Icon(Icons.add_circle_outline),
                    //                   onPressed: () {
                    //                     product.countItem.value++;
                    //                   },
                    //                 ),
                    //               ],
                    //             ),
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ),
                  Positioned(
                    top: -20,
                    right: -10,
                    child: IconButton(
                      key: controller.buttonDeleteKeys[product.id],
                      color: Colors.red,
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () {
                        final BuildContext? context = controller
                            .buttonDeleteKeys[product.id]?.currentContext;
                        if (context == null) {
                          return;
                        }

                        final RenderObject? renderObject =
                            context.findRenderObject();
                        if (renderObject is! RenderBox) {
                          return;
                        }

                        final RenderBox renderBox = renderObject;
                        final Offset buttonOffset =
                            renderBox.localToGlobal(Offset.zero);

                        showDeleteDialogs(
                          context,
                          buttonOffset,
                          product.title,
                          product.id,
                          homeController,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
            // return AnimatedOpacity(
            //   duration: const Duration(milliseconds: 500),
            //   opacity: controller.isVisibleList[index] ? 1.0 : 0.0,
            //   child: Transform.translate(
            //     offset: controller.isVisibleList[index]
            //         ? const Offset(0, 0)
            //         : const Offset(0, 30),
            //     child: Container(
            //       margin: const EdgeInsets.only(bottom: 16),
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(16),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.grey.withOpacity(0.2),
            //             spreadRadius: 2,
            //             blurRadius: 8,
            //             offset: const Offset(0, 4),
            //           ),
            //         ],
            //       ),
            //       child: ListTile(
            //         leading: CircleAvatar(
            //           backgroundColor: Colors.blue.shade50,
            //           child: Image.network(product.thumbnail),
            //         ),
            //         title: Text(
            //           product.title,
            //           style: const TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //         subtitle: Text('Qty: ${product.countItem}'),
            //         trailing: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             IconButton(
            //               icon: const Icon(Icons.remove_circle_outline),
            //               onPressed: () {
            //                 //homeController.removeProduct(product.id);
            //               },
            //             ),
            //             IconButton(
            //               icon: const Icon(Icons.add_circle_outline),
            //               onPressed: () {
            //                 //homeController.addProduct(product);
            //               },
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // );
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        // final int totalItems = homeController.cartProducts.values
        //     .fold<int>(0, (sum, p) => sum + p.countItem.value);

        final double totalPay =
            homeController.cartProducts.values.fold(0, (sum, product) {
          return sum + (product.price * product.countItem.value);
        });

        return Container(
          height: 130,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            spacing: 20,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items: ${homeController.cartProducts.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Total: ₱${totalPay.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        controller.createCheckoutSession();
                      },
                      child: const Text('Checkout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
      // persistentFooterButtons: [
      //   Obx(() {
      //     // final int totalItems = homeController.cartProducts.values
      //     //     .fold<int>(0, (sum, p) => sum + p.countItem.value);

      //     final double totalPay =
      //         homeController.cartProducts.values.fold(0, (sum, product) {
      //       return sum + (product.price * product.countItem.value);
      //     });

      //     return Container(
      //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      //       decoration: const BoxDecoration(
      //         color: Colors.white,
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.black12,
      //             blurRadius: 4,
      //             offset: Offset(0, -2),
      //           ),
      //         ],
      //       ),
      //       child: Column(
      //         spacing: 20,
      //         children: [
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Text(
      //                 'Items: ${homeController.cartProducts.length}',
      //                 style: const TextStyle(
      //                   fontSize: 16,
      //                   fontWeight: FontWeight.w600,
      //                 ),
      //               ),
      //               Text(
      //                 'Total: ₱${totalPay.toStringAsFixed(2)}',
      //                 style: const TextStyle(
      //                   fontSize: 18,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ],
      //           ),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Expanded(
      //                 child: ElevatedButton(
      //                   style: ElevatedButton.styleFrom(
      //                     backgroundColor: Colors.green,
      //                     padding: const EdgeInsets.symmetric(
      //                       horizontal: 24,
      //                       vertical: 12,
      //                     ),
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                   ),
      //                   onPressed: () {
      //                     // TODO: Proceed to checkout
      //                   },
      //                   child: const Text('Checkout'),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     );
      //   }),
      // ],
    );
  }

  void showDeleteDialogs(
    BuildContext context,
    Offset startOffset,
    String productName,
    int productId,
    HomeController homeController,
  ) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
          reverseCurve: Curves.easeInCirc,
        );

        final Animation<Offset> positionTween = Tween<Offset>(
          begin: Offset(
            (startOffset.dx + 80) / screenWidth,
            startOffset.dy / MediaQuery.sizeOf(context).height,
          ),
          end: const Offset(0.5, 0.5),
        ).animate(curvedAnimation);

        return Stack(
          children: [
            AnimatedBuilder(
              animation: positionTween,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(
                    positionTween.value.dx - 0.5,
                    positionTween.value.dy - 0.5,
                  ),
                  child: ScaleTransition(scale: curvedAnimation, child: child),
                );
              },
              child: Center(
                child: Container(
                  width: Get.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Delete Product',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            children: [
                              const TextSpan(
                                text: 'Are you sure you want to delete ',
                              ),
                              TextSpan(
                                text: '"$productName"',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .red, // Optional: emphasize product name
                                ),
                              ),
                              const TextSpan(text: '?'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: Get.back,
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                homeController.cartProducts.remove(productId);

                                final int index = homeController.products
                                    .indexWhere((p) => p.id == productId);
                                if (index != -1) {
                                  homeController
                                      .products[index].countItem.value = 0;
                                }
                                Get.back();
                              },
                              icon: const Icon(Icons.delete),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              label: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
