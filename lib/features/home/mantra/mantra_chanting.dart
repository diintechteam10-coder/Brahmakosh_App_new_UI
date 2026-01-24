import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/home/controllers/mantra_chanting_controller.dart';

class MantraChantingView extends StatefulWidget {
  const MantraChantingView({super.key});

  @override
  State<MantraChantingView> createState() => _MantraChantingViewState();
}

class _MantraChantingViewState extends State<MantraChantingView> {
  late final MantraChantingController controller;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MantraChantingController());
    pageController = PageController();

    /// Sync tab change with PageView
    ever<int>(controller.selectedIndex, (index) {
      if (pageController.hasClients && pageController.page?.round() != index) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chantingMantras.isEmpty) {
          return const Center(child: Text("No mantras available"));
        }

        return Column(
          children: [
            /// 🔝 TOP BAR WITH DROPDOWN
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: AppTheme.deepGold,
                      onPressed: Get.back,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() {
                        return SizedBox(
                          height: 42,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.chantingMantras.length,
                            itemBuilder: (context, index) {
                              final mantra = controller.chantingMantras[index];
                              final isSelected =
                                  controller.selectedIndex.value == index;

                              return GestureDetector(
                                onTap: () {
                                  controller.selectMantra(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryGold
                                        : Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryGold
                                          : AppTheme.deepGold.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.primaryGold
                                                  .withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      mantra.name ?? "Mantra",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.deepGold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            /// 📜 PAGE VIEW
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.chantingMantras.length,
                onPageChanged: controller.selectMantra,
                itemBuilder: (_, index) {
                  final mantra = controller.chantingMantras[index];

                  return GestureDetector(
                    onTap: controller.incrementCount,
                    child: SingleChildScrollView(
                      child: _MantraBody(
                        controller: controller,
                        mantra: mantra,
                      ),
                    ),
                  );
                },
              ),
            ),

            /// 🔘 PAGE INDICATOR
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SmoothPageIndicator(
                controller: pageController,
                count: controller.chantingMantras.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: AppTheme.primaryGold,
                  dotColor: AppTheme.lightGold,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
                onDotClicked: (index) {
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MantraBody extends StatelessWidget {
  final MantraChantingController controller;
  final dynamic mantra;

  const _MantraBody({required this.controller, required this.mantra});

  @override
  Widget build(BuildContext context) {
    final total = mantra.malaCount ?? 108;

    return Obx(() {
      final progress = controller.chantCount.value / total;

      return Column(
        children: [
          const SizedBox(height: 24),

          /// 🕉 OM
          ScaleTransition(
            scale: controller.scaleAnimation,
            child: Text(
              "ॐ",
              style: GoogleFonts.playfairDisplay(
                fontSize: 90,
                color: AppTheme.deepGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 📿 NAME
          Text(
            mantra.name ?? "Om Namah Shivaya",
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepGold,
            ),
          ),

          const SizedBox(height: 12),

          /// 🔢 COUNTER (NOW REACTIVE ✅)
          Text(
            "${controller.chantCount.value} / $total",
            style: GoogleFonts.playfairDisplay(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGold,
            ),
          ),

          const SizedBox(height: 12),

          /// ⭕ PROGRESS (NOW REACTIVE ✅)
          SizedBox(
            height: 110,
            width: 110,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 10,
              valueColor: AlwaysStoppedAnimation(
                controller.isCompleted.value
                    ? Colors.green
                    : AppTheme.primaryGold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// 🧾 DESCRIPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              controller.isCompleted.value
                  ? "🎉 Mala completed!"
                  : mantra.description ?? "Tap anywhere to increase count",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.deepGold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔄 RESET
          TextButton.icon(
            onPressed: controller.resetCount,
            icon: const Icon(Icons.refresh),
            label: const Text("RESET"),
          ),

          const SizedBox(height: 30),
        ],
      );
    });
  }
}
