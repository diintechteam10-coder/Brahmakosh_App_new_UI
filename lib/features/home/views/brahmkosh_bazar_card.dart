import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BrahmBazarCard extends StatelessWidget {
  final VoidCallback onMoreTap;

  const BrahmBazarCard({super.key, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              AppTheme.cardBackground,
              AppTheme.cardBackground.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(0.25),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront, size: 24, color: AppTheme.deepGold),
                  const SizedBox(width: 10),
                  Text(
                    "Brahm Bazar",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onMoreTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.lightGoldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGold.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: AppTheme.deepGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// STORE ITEMS GRID
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: const [
                  _StoreItem(icon: Icons.auto_awesome, label: "Yantra"),
                  _StoreItem(icon: Icons.self_improvement, label: "Puja"),
                  _StoreItem(icon: Icons.menu_book, label: "Books"),
                  _StoreItem(icon: Icons.spa, label: "Healing"),
                  _StoreItem(icon: Icons.music_note, label: "Mantra"),
                  _StoreItem(
                    icon: Icons.local_grocery_store,
                    label: "Supplies",
                  ),
                ],
              ),
            ),

            /// FOOTER CTA
            GestureDetector(
              onTap: onMoreTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold, // Solid color for button look
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Explore & purchase spiritual essentials",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // White text for contrast
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StoreItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryGold, // circle border color
              width: 2, // border thickness
            ),
            // no gradient or background
          ),
          child: Center(child: Icon(icon, size: 24, color: AppTheme.deepGold)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
