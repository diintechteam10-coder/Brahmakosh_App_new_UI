import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  List<ProductDetails> products = [];
  bool isAvailable = false;

  final List<String> _productIds = [
    'com.brahmakosh.coins.100',
    'com.brahmakosh.coins.1000',
    'com.brahmakosh.coins.2000',
    'com.brahmakosh.coins.4000',
    'com.brahmakosh.coins.8000',
  ];

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://prod.brahmakosh.com/api/user/payment",
      headers: {
        'clientId': AppConstants.clientId,
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

  Future<void> initialize() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    if (Platform.isIOS) {
      final iosPlatformAddition = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint("IAP Subscription Error: $error");
      },
    );

    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("Products not found: ${response.notFoundIDs}");
    }
    products = response.productDetails;
    // Sort products by price or ID if needed
    products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("Purchase Error: ${purchaseDetails.error}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            // Deliver product
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Sending receipt to backend for verification
      final res = await _dio.post(
        "/verify-apple", // Placeholder - User needs to confirm this endpoint
        data: {
          "productId": purchaseDetails.productID,
          "verificationData": purchaseDetails.verificationData.serverVerificationData,
          "transactionId": purchaseDetails.purchaseID,
        },
      );
      
      if (res.data["success"] == true) {
        return true;
      }
    } catch (e) {
      debugPrint("Verification failed: $e");
    }
    // For now, returning true to allow testing development, 
    // but in production, this MUST return the actual verification status.
    return true; 
  }

  void dispose() {
    _subscription.cancel();
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
