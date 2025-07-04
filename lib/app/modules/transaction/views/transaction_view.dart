import 'package:flutter/material.dart';
import 'package:food_courier/app/data/models/transaction_model.dart';
import 'package:get/get.dart';

import '../controllers/transaction_controller.dart';

class TransactionView extends GetView<TransactionController> {
  const TransactionView({super.key});
  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.put(TransactionController());
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Transactions',
        ),
      ),
      body: Obx(() {
        final RxList<TransactionModel> txList = controller.transactions;

        // if (txList.isEmpty) {
        //   return const Center(child: Text('No transactions yet.'));
        // }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: txList.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final TransactionModel tx = txList[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderTrackingWidget(
                      currentStep: tx.currentStep.isEmpty
                          ? -1
                          : tx.currentStep.length - 1,
                    ),

                    /// 🧾 Summary
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16), // default style
                        children: [
                          const TextSpan(
                            text: 'Order ID: ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextSpan(
                            text: tx.orderId,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// 🛒 Products
                    Column(
                      children: tx.products.map((product) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.thumbnail,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₱${product.price}  ×  ${product.countItem}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),

                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: Text(
                    //     _formatDate(tx.createdAt),
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       color: Colors.grey.shade600,
                    //     ),
                    //   ),
                    // ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style:
                                const TextStyle(fontSize: 16), // default style
                            children: [
                              const TextSpan(
                                text: 'Total: ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextSpan(
                                text: '₱${tx.totalPay}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          tx.createdAt.toString(),
                          //_formatDate(tx.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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

  String _formatDate(String isoDate) {
    final DateTime? dt = DateTime.tryParse(isoDate);
    if (dt == null) return '';
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class OrderTrackingWidget extends StatelessWidget {
  const OrderTrackingWidget({required this.currentStep, super.key});

  final int currentStep; // 0: Confirmed, 1: Shipped, 2: Delivered

  final List<String> steps = const ['Confirmed', 'Shipped', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circles and lines
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isEven) {
              final int stepIndex = index ~/ 2;
              final bool isCompleted = stepIndex < currentStep;
              final bool isCurrent = stepIndex == currentStep;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: isCurrent ? const EdgeInsets.all(4) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: Colors.green, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: isCompleted || isCurrent
                      ? Colors.green
                      : Colors.grey.shade300,
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              );
            } else {
              final bool isPassed = index ~/ 2 < currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  color: isPassed ? Colors.green : Colors.grey.shade300,
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            return Text(
              steps[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    index <= currentStep ? FontWeight.bold : FontWeight.normal,
                color: index <= currentStep ? Colors.black : Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
