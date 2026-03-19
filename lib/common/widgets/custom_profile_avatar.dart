import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:brahmakosh/common/api_urls.dart';

class CustomProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;

  const CustomProfileAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20.0,
    this.borderWidth = 1.0,
    this.borderColor = Colors.white,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final formattedUrl = ApiUrls.getFormattedImageUrl(imageUrl);
    
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: (formattedUrl == null || formattedUrl.isEmpty)
            ? _buildFallbackIcon()
            : CachedNetworkImage(
                imageUrl: formattedUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildFallbackIcon(),
                errorWidget: (context, url, error) {
                  debugPrint(
                    "❌ CustomProfileAvatar Error loading: $url - Error: $error",
                  );
                  return _buildFallbackIcon();
                },
              ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD4AF37),
            Color(0xFFA67C00),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 24,
        color: Colors.white,
      ),
    );
  }
}
