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
        color: borderColor, // Outer border color
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(borderWidth), // Outer border width
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // Inner border color
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(2), // Inner border width/gap
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
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Image.asset('assets/icons/User.jpg', fit: BoxFit.cover);
  }
}
