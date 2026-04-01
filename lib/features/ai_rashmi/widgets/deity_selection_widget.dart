import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DeitySelectionWidget extends StatelessWidget {
  final VoidCallback onSelectKrishna;
  final VoidCallback onSelectRashmi;

  const DeitySelectionWidget({
    super.key,
    required this.onSelectKrishna,
    required this.onSelectRashmi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: const Color(0xFF18151B), // Dark theme background
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout: Row for wide screens, Column for very narrow (though Row usually fits on mobile for 2 items)
          // Actually, design shows a Row.
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDeityCard(
                context,
                "Ask Krishna",
                "assets/images/Small_krishna.png",
                onSelectKrishna,
              ),
              SizedBox(width: 4.w),
              _buildDeityCard(
                context,
                "Ask Rashmi",
                "assets/icons/rashmi_new_avatar.png",
                onSelectRashmi,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeityCard(
    BuildContext context,
    String title,
    String imagePath,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // Fixed aspect ratio or height to look like a card
          height: 22.5.h,
          decoration: BoxDecoration(
            color: const Color(0xFF100E13), // Darker card background
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 15.w,
                        color: const Color(0xFFF1C453),
                      );
                    },
                  ),
                ),
              ),
              // Text
              Padding(
                padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 2.h),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
