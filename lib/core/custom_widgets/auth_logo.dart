import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthLogoAvatar extends StatelessWidget {
  final double size;
  final String imagePath;

  const AuthLogoAvatar({
    super.key,
    this.size = 100,
    this.imagePath = 'assets/images/brahmkosh_logo.png',
  });

  @override
  Widget build(BuildContext context) {
    final double innerSize = size * 0.8;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGold.withOpacity(0.9),
            AppTheme.primaryGold.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.3),
            blurRadius: size * 0.25,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: size * 0.15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(innerSize / 2),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
