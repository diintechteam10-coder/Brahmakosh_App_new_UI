// import 'package:brahmakosh/core/common_imports.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class RemediesWebView extends StatefulWidget {
//   final VoidCallback? onBack;
//   const RemediesWebView({super.key, this.onBack});

//   @override
//   State<RemediesWebView> createState() => _RemediesWebViewState();
// }

// class _RemediesWebViewState extends State<RemediesWebView> {
//   late final WebViewController controller;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeController();
//     _loadWebView();
//   }

//   void _initializeController() {
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {},
//           onPageStarted: (String url) {
//             debugPrint('WebView Page Started: $url');
//             if (mounted) {
//               setState(() {
//                 isLoading = true;
//               });
//             }
//           },
//           onPageFinished: (String url) {
//             debugPrint('WebView Page Finished: $url');
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//               });
//             }
//           },
//           onWebResourceError: (WebResourceError error) {},
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith('https://shop.brahmakosh.com')) {
//               return NavigationDecision.navigate;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       );
//   }


// Future<void> _loadWebView() async {
//   final token = StorageService.getString(AppConstants.keyAuthToken);

//   if (token != null && token.isNotEmpty) {
//     // Set cookie for persistence on the shop domain
//     final cookieManager = WebViewCookieManager();
//     final domains = ['shop.brahmakosh.com', 'prod.brahmakosh.com'];
    
//     for (final domain in domains) {
//       await cookieManager.setCookie(
//         WebViewCookie(
//           name: 'token',
//           value: token,
//           domain: domain,
//           path: '/',
//         ),
//       );
//     }

//     final url =
//         'https://prod.brahmakosh.com/api/store/sso-login'
//         '?token=$token&redirect=/remedies';

//     debugPrint('✅ Loading SSO URL: $url');

//     await controller.loadRequest(Uri.parse(url));
//   } else {
//     const url = 'https://shop.brahmakosh.com/';
//     debugPrint('⚠️ Loading without token: $url');

//     await controller.loadRequest(Uri.parse(url));
//   }
// }
//   // Future<void> _loadWebView() async {
//   //   final token = StorageService.getString(AppConstants.keyAuthToken);

//   //   if (token != null && token.isNotEmpty) {
//   //     // Set cookie for persistence
//   //     final cookieManager = WebViewCookieManager();
//   //     await cookieManager.setCookie(
//   //       WebViewCookie(
//   //         name: 'token',
//   //         value: token,
//   //         domain: 'shop.brahmakosh.com',
//   //         path: '/',
//   //       ),
//   //     );

//   //     // Pass token as URL parameter for initial login
//   //     final url = 'https://shop.brahmakosh.com/?token=$token';
//   //     debugPrint('WebView Loading with token: $url');
//   //     await controller.loadRequest(Uri.parse(url));
//   //   } else {
//   //     const url = 'https://shop.brahmakosh.com/';
//   //     debugPrint('WebView Loading without token: $url');
//   //     await controller.loadRequest(Uri.parse(url));
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: widget.onBack == null,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) return;
//         if (widget.onBack != null) {
//           widget.onBack!();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             SafeArea(
//               top: false,
//               bottom: true,
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.paddingOf(context).top,
//                 ),
//                 child: WebViewWidget(controller: controller),
//               ),
//             ),
//             if (isLoading)
//               const Center(
//                 child: CircularProgressIndicator(color: AppTheme.primaryGold),
//               ),
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 10,
//               left: 10,
//               child: Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFe6e7e8),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 3,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                   iconSize: 18,
//                   icon: const Icon(
//                     Icons.arrow_back,
//                     color: AppTheme.textPrimary,
//                   ),
//                   onPressed: () {
//                     if (widget.onBack != null) {
//                       widget.onBack!();
//                     } else {
//                       Get.back();
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:brahmakosh/core/common_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RemediesWebView extends StatefulWidget {
  final VoidCallback? onBack;
  const RemediesWebView({super.key, this.onBack});

  @override
  State<RemediesWebView> createState() => _RemediesWebViewState();
}

class _RemediesWebViewState extends State<RemediesWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _initializeController();
    _loadWebView();
  }

  void _initializeController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('🌐 Page Started: $url');
            if (mounted) {
              setState(() => isLoading = true);
            }
          },
          onPageFinished: (String url) async {
            debugPrint('✅ Page Finished: $url');

            /// 🔍 Debug cookies (optional)
            try {
              final cookies =
                  await controller.runJavaScriptReturningResult(
                      "document.cookie");
              debugPrint('🍪 Cookies: $cookies');
            } catch (_) {}

            if (mounted) {
              setState(() => isLoading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint('❌ Web Error: ${error.description}');
          },
          onNavigationRequest: (request) {
            debugPrint('➡️ Navigating: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  Future<void> _loadWebView() async {
    final token = StorageService.getString(AppConstants.keyAuthToken);

    /// ✅ Always clear old cookies (avoid conflicts)
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    if (token != null && token.isNotEmpty) {
      /// 🔥 BEST PRACTICE: Use only SSO URL (no manual cookie dependency)
      final url =
          'https://prod.brahmakosh.com/api/store/sso-login'
          '?token=$token';

      debugPrint('🚀 Loading SSO URL: $url');

      await Future.delayed(const Duration(milliseconds: 300));

      await controller.loadRequest(Uri.parse(url));
    } else {
      const url = 'https://shop.brahmakosh.com/';
      debugPrint('⚠️ Loading without token: $url');

      await controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top,
                ),
                child: WebViewWidget(controller: controller),
              ),
            ),

            /// 🔄 Loader
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGold,
                ),
              ),

            /// 🔙 Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFe6e7e8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 18,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Get.back();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
