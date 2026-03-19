import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFluidSlider extends StatefulWidget {
  final int valueIndex;
  final int itemCount;
  final String Function(int) labelBuilder;
  final ValueChanged<int> onChanged;

  const CustomFluidSlider({
    super.key,
    required this.valueIndex,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  State<CustomFluidSlider> createState() => _CustomFluidSliderState();
}

class _CustomFluidSliderState extends State<CustomFluidSlider> {
  void _handleUpdate(Offset localPosition, double width) {
    if (widget.itemCount <= 1) return;
    
    // Clamp the horizontal position
    double dx = localPosition.dx.clamp(0.0, width);
    // Calculate the continuous progress [0.0, 1.0]
    double percent = dx / width;
    
    // Nearest index
    int index = (percent * (widget.itemCount - 1)).round();
    index = index.clamp(0, widget.itemCount - 1);
    
    if (index != widget.valueIndex) {
      widget.onChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // height of the paint area. Let's reserve enough space for the tooltip
        const double sliderHeight = 60.0; // Total height including tooltip

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) =>
              _handleUpdate(details.localPosition, width),
          onTapDown: (details) => _handleUpdate(details.localPosition, width),
          child: SizedBox(
            width: width,
            height: sliderHeight,
            child: CustomPaint(
              painter: _SliderPainter(
                valueIndex: widget.valueIndex,
                itemCount: widget.itemCount,
                label: widget.labelBuilder(widget.valueIndex),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  final int valueIndex;
  final int itemCount;
  final String label;

  _SliderPainter({
    required this.valueIndex,
    required this.itemCount,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double percent = itemCount <= 1 ? 0.0 : valueIndex / (itemCount - 1);
    
    final trackHeight = 12.0;
    final trackY = size.height - trackHeight / 2;
    
    final thumbX = percent * size.width;
    
    // 1. Draw Background Track (Inactive)
    final bgPaint = Paint()
      ..color = const Color(0xFF2C2C2E) // Dark Grey
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
      
    final bgRect = RRect.fromLTRBR(
      0,
      trackY - trackHeight / 2,
      size.width,
      trackY + trackHeight / 2,
      const Radius.circular(6),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // 2. Draw Active Track (Chevrons)
    // We clip to the active region and draw repeating chevrons.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, trackY - trackHeight, thumbX, trackY + trackHeight));
    
    final chevronPaint = Paint()
      ..color = const Color(0xFFE67E22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    const double chevronSpacing = 10.0;
    const double chevronWidth = 4.0;
    const double chevronHeight = 8.0;
    
    int numOfChevrons = (thumbX / chevronSpacing).ceil() + 1;
    for (int i = 0; i < numOfChevrons; i++) {
      double startX = i * chevronSpacing;
      final path = Path();
      path.moveTo(startX, trackY - chevronHeight / 2);
      path.lineTo(startX + chevronWidth, trackY);
      path.lineTo(startX, trackY + chevronHeight / 2);
      canvas.drawPath(path, chevronPaint);
    }
    canvas.restore();

    // 3. Draw Thumb
    final thumbRadius = 8.0;
    
    // Outer Orange Border
    canvas.drawCircle(Offset(thumbX, trackY), thumbRadius, Paint()..color = const Color(0xFFE67E22));
    
    // Inner White Circle
    canvas.drawCircle(Offset(thumbX, trackY), thumbRadius - 3.0, Paint()..color = Colors.white);

    // 4. Draw Tooltip
    // Tooltip rect
    final textPainter = TextPainter(
      text: TextSpan(
        text: ' $label',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Wait, the design has a clock icon in the tooltip too!
    // Since drawing an icon in CustomPainter is a bit tedious (need to use IconData and a specific font family like MaterialIcons),
    // let's draw it using text using a Unicode icon or just use TextPainter with IconData.
    
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.check_circle_outline.codePoint),
        style: TextStyle(
          fontFamily: Icons.check_circle_outline.fontFamily,
          package: Icons.check_circle_outline.fontPackage,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();

    final paddingHorizontal = 10.0;
    final paddingVertical = 6.0;
    final gap = 4.0;
    final tooltipWidth = iconPainter.width + textPainter.width + gap + paddingHorizontal * 2;
    final tooltipHeight = max(iconPainter.height, textPainter.height) + paddingVertical * 2;
    
    final tooltipY = trackY - thumbRadius - tooltipHeight - 4; // 4 is arrow spacing
    
    // Calculate tooltip X (keep within bounds if possible)
    double tooltipX = thumbX - tooltipWidth / 2;
    // However, bounding can make the down arrow unaligned. Let's let it overflow slightly
    // or adjust the rect and keep arrow at thumbX.
    double tooltipRectX = tooltipX;
    if (tooltipRectX < 0) tooltipRectX = 0;
    if (tooltipRectX + tooltipWidth > size.width) {
      tooltipRectX = size.width - tooltipWidth;
    }

    final tooltipRect = RRect.fromLTRBR(
      tooltipRectX,
      tooltipY,
      tooltipRectX + tooltipWidth,
      tooltipY + tooltipHeight,
      const Radius.circular(6),
    );
    
    final tooltipBgPaint = Paint()
      ..color = const Color(0xFFE67E22)
      ..style = PaintingStyle.fill;
      
    // Draw Tooltip Arrow (triangle pointing down)
    final arrowPath = Path();
    arrowPath.moveTo(thumbX - 4, tooltipY + tooltipHeight - 1);
    arrowPath.lineTo(thumbX + 4, tooltipY + tooltipHeight - 1);
    arrowPath.lineTo(thumbX, tooltipY + tooltipHeight + 5);
    arrowPath.close();
    
    canvas.drawPath(arrowPath, tooltipBgPaint);
    canvas.drawRRect(tooltipRect, tooltipBgPaint);

    // Draw Tooltip contents
    iconPainter.paint(
      canvas,
      Offset(
        tooltipRectX + paddingHorizontal,
        tooltipY + (tooltipHeight - iconPainter.height) / 2,
      ),
    );
    
    textPainter.paint(
      canvas,
      Offset(
        tooltipRectX + paddingHorizontal + iconPainter.width + gap,
        tooltipY + (tooltipHeight - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _SliderPainter oldDelegate) {
    return oldDelegate.valueIndex != valueIndex ||
           oldDelegate.itemCount != itemCount ||
           oldDelegate.label != label;
  }
}

