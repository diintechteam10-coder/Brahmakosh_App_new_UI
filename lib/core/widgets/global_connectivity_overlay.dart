import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../services/connectivity_service.dart';

class GlobalConnectivityOverlay extends StatelessWidget {
  final Widget child;

  const GlobalConnectivityOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Stack(
      children: [
        child,
        Obx(() {
          if (!connectivityService.isOffline.value) {
            return const SizedBox.shrink();
          }

          return Material(
            color: Colors.black.withOpacity(0.7),
            child: PopScope(
              canPop: false,
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E), // Premium Dark
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD4AF).withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.redAccent,
                          size: 10.w,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        "No Internet Connection",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.merriweather(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD4AF), // Gold accent
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        "Please check your internet settings. This app requires an active connection to function.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD4AF)),
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 3.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => connectivityService.refreshConnectivity(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD4AF).withOpacity(0.1),
                            foregroundColor: const Color(0xFFFFD4AF),
                            side: const BorderSide(color: Color(0xFFFFD4AF)),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            "Try Again",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
