import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FounderMessageCard extends StatelessWidget {
  final String founderName;
  final String designation;
  final String message;
  final String? imageUrl;

  const FounderMessageCard({
    super.key,
    required this.founderName,
    this.designation = "Founder",
    required this.message,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// Main Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  AppTheme.cardBackground.withOpacity(0.98),
                  AppTheme.cardBackground.withOpacity(0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Floating quote icon
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.format_quote,
                    size: 36,
                    color: AppTheme.primaryGold.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 8),

                /// Message
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground.withOpacity(0.98),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 1.5,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ),
                const SizedBox(height: 20),

                /// Founder Name & Designation
                Text(
                  founderName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                ),
                Text(
                  designation,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          /// Avatar overlapping the card
          Positioned(
            top: -20,
            left: 16,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.lightGoldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 32,
                          color: AppTheme.deepGold,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 32,
                        color: AppTheme.deepGold,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
