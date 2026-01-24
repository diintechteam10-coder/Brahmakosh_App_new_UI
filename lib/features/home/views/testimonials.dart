import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/home/controllers/testimonials_controller.dart';

class TestimonialsCarousel extends StatelessWidget {
  const TestimonialsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller if not already present, or Find it.
    // Since this is a widget part of HomeView, likely we want to put it here or in Home binding.
    // For simplicity, we can use Get.put here or Get.find if we move it to HomeBinding.
    // Let's use Get.put to ensure it exists.
    final controller = Get.put(TestimonialsController());

    return Obx(() {
      if (!controller.isLoading.value && controller.testimonials.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  "Testimonials",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.feedback, color: AppTheme.deepGold, size: 20),
              ],
            ),
          ),

          /// Carousel
          SizedBox(
            height: 200,
            child: controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryGold),
                  )
                : PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.testimonials.length,
                    onPageChanged: (index) => controller.updatePage(index),
                    itemBuilder: (context, index) {
                      final item = controller.testimonials[index];
                      // Wrap usage of currentPage in Obx or just rely on parent Obx?
                      // Put Obx inside builder for fine-grained updates or just rebuild PageView (expensive?)
                      // PageView builder is called on scroll. scale depends on currentPage.
                      // We need reactivity here.
                      // Since the parent is Obx, any change to observables (currentPage) triggers rebuild of this whole block.
                      // That might be okay for a carousel.
                      
                      final isActive = index == controller.currentPage.value;
                      final scale = isActive ? 1.0 : 0.95;

                      final bgColor = [
                        const Color(0xFFFDEBD0),
                        const Color(0xFFD6EAF8),
                        const Color(0xFFFADBD8),
                      ][index % 3];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        transform: Matrix4.identity()..scale(scale),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppTheme.deepGold.withOpacity(0.4),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bgColor,
                                image: item.image.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(item.image),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: bgColor.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: item.image.isNotEmpty
                                  ? null
                                  : const Icon(
                                      Icons.person,
                                      color: AppTheme.deepGold,
                                      size: 28,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.message,
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.name,
                                    style: Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          /// Dots Indicator
          if (!controller.isLoading.value && controller.testimonials.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.testimonials.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: controller.currentPage.value == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.currentPage.value == index
                        ? AppTheme.primaryGold
                        : AppTheme.primaryGold.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
