// import 'package:flutter/material.dart';

// import 'package:get/get.dart';

// import '../controllers/webview_controller.dart';

// class WebviewView extends GetView<WebviewController> {
//   const WebviewView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('WebviewView'),
//         centerTitle: true,
//       ),
//       body: const Center(
//         child: Text(
//           'WebviewView is working',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food_courier/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as htpp;
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class WebviewView extends StatefulWidget {
  const WebviewView({super.key});
  @override
  State<WebviewView> createState() => _WebviewViewState();
}

class _WebviewViewState extends State<WebviewView> {
  late WebViewController controller;
  int loadingPercentage = 0;

  String checkoutUrl = Get.arguments['checkout_url'] ?? '';
  String id = Get.arguments['id'] ?? '';
  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },

// Keeping track of navigation uisng NavigationDelegate
          onNavigationRequest: (navigation) async {
            final String host = Uri.parse(navigation.url).host;
            print('URL: $host');
            if (navigation.url.contains('https://www.google.com/')) {
              await fetchCheckoutSession(id);
              Get.toNamed(AppPages.DASHBOARD);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message.message,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      )
      ..loadRequest(
        Uri.parse(checkoutUrl),
      );
  }

  Future<void> fetchCheckoutSession(String sessionId) async {
    const String apiKey = 'c2tfdGVzdF9haWJVdkJycG9vc3BXdHFmbmQ1dXI4VVk6';

    const authHeader = 'Basic $apiKey';
    final headers = {
      'Authorization': authHeader,
      'Content-Type': 'application/json',
    };
    final linkStatus =
        'https://api.paymongo.com/v1/checkout_sessions/$sessionId';

    final Uri url = Uri.parse(linkStatus);

    try {
      // Sending a GET request
      final http.Response response = await htpp.get(
        url,
        headers: headers,
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        String status = responseBody['data']['attributes']['payments'][0]
            ['attributes']['status'];

        log('Status: $status Response Data: $responseBody');
      } else {
        log('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('WebView'),
        actions: [
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  final ScaffoldMessengerState messenger =
                      ScaffoldMessenger.of(context);
                  if (await controller.canGoBack()) {
                    await controller.goBack();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        duration: Duration(milliseconds: 200),
                        content: Text(
                          "Can't go back",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () async {
                  final ScaffoldMessengerState messenger =
                      ScaffoldMessenger.of(context);
                  if (await controller.canGoForward()) {
                    await controller.goForward();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        duration: Duration(milliseconds: 200),
                        content: Text(
                          'No forward history item',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: () {
                  controller.reload();
                },
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              color: Colors.red,
              value: loadingPercentage / 100.0,
            )
          else
            Container(),
        ],
      ),
    );
  }
}
