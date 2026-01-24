import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BottomBrandingCard extends StatelessWidget {
  final String appName;
  final String tagline;
  final String backgroundImage; // New: background image path/url
  final VoidCallback? onTap;

  const BottomBrandingCard({
    super.key,
    required this.appName,
    this.tagline = "",
    this.backgroundImage = "",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 350, // Bada height: full bottom 4x4 feel
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            image: backgroundImage.isNotEmpty
                ? DecorationImage(
                    image: AssetImage(backgroundImage),
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: AppTheme.goldGradient.withOpacity(0.9) != null
                ? AppTheme.goldGradient
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
              BoxShadow(
                color: AppTheme.primaryGold.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              /// App Logo (Bada + Glow)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.lightGoldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/brahmkosh_logo.jpeg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 24),

              /// App Name & Tagline
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color.fromARGB(255, 247, 244, 242),
                            fontSize: 24,
                          ),
                    ),
                    if (tagline.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          tagline,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color.fromRGBO(253, 253, 253, 1),
                              ),
                        ),
                      ),
                  ],
                ),
              ),

              /// Optional Arrow CTA
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: AppTheme.deepGold,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
