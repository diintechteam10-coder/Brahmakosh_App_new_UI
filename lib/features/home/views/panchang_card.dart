import 'package:brahmakosh/core/common_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PanchangCard extends StatelessWidget {
  const PanchangCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.wb_sunny,
        'label': 'tithi'.tr,
        'color': const Color(0xFFFFC107),
        'route': AppConstants.routeTithi,
      }, // Yellow
      {
        'icon': Icons.cloud,
        'label': 'nakshatra'.tr,
        'color': const Color(0xFF64B5F6),
        'route': AppConstants.routeNakshatra,
      }, // Blue
      {
        'icon': Icons.star,
        'label': 'yoga'.tr,
        'color': const Color(0xFFFF5722),
        'route': AppConstants.routeYoga,
      }, // Orange
      {
        'icon': Icons.access_time,
        'label': 'karan'.tr,
        'color': const Color(0xFF4CAF50),
        'route': AppConstants.routeKaran,
      }, // Green
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(AppConstants.routePanchang);
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGold.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ✨ HEADER (GOLD GRADIENT)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "panchang".tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppTheme.deepGold,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              /// 🌼 ACTIONS
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: items.map((item) {
                    return _PanchangItem(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      color: item['color'] as Color,
                      onTap: () {
                         Get.toNamed(item['route'] as String);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanchangItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PanchangItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(60),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 26, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
