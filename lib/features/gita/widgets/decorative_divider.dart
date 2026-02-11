import 'package:flutter/material.dart';

class DecorativeDivider extends StatelessWidget {
  final int starCount;
  final double normalStarSize;
  final double centerStarSize;
  final Color lineColor;
  final Color starColor;

  /// Dynamic center
  final String? centerText;
  final TextStyle? centerTextStyle;
  final Widget? centerWidget;

  const DecorativeDivider({
    super.key,
    this.starCount = 3,
    this.normalStarSize = 14,
    this.centerStarSize = 18,
    this.lineColor = const Color(0xFFE6C7A1),
    this.starColor = const Color(0xFFFF9F2D),
    this.centerText,
    this.centerTextStyle,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _line()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildCenter(),
        ),
        Expanded(child: _line()),
      ],
    );
  }

  Widget _buildCenter() {
    // 1️⃣ Custom widget (highest priority)
    if (centerWidget != null) {
      return centerWidget!;
    }

    // 2️⃣ Text → ⭐ Text ⭐
    if (centerText != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: normalStarSize, color: starColor),
          const SizedBox(width: 4),
          Text(
            centerText!,
            style: centerTextStyle ??
                TextStyle(
                  color: starColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: normalStarSize, color: starColor),
        ],
      );
    }

    // 3️⃣ Default → Stars with bigger center star
    final centerIndex = starCount ~/ 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final isCenter = index == centerIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.star,
            size: isCenter ? centerStarSize : normalStarSize,
            color: starColor,
          ),
        );
      }),
    );
  }

  Widget _line() {
    return Container(
      height: 1,
      color: lineColor,
    );
  }
}
