import 'package:brahmakosh/core/common_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://shop.brahmakosh.com/')) {
              return NavigationDecision.navigate;
            }
            // Allow all internal navigation on the site
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://shop.brahmakosh.com/'));
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
              left: false,
              right: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: WebViewWidget(controller: controller),
              ),
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGold),
              ),
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
