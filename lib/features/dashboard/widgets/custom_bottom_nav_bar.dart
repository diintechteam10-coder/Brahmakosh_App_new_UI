// import 'package:flutter_svg/flutter_svg.dart';
// import '../../../../core/common_imports.dart';

// class CustomBottomNavBar extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const CustomBottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
// }

// class _CustomBottomNavBarState extends State<CustomBottomNavBar>
//     with TickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isRashmiSelected = widget.currentIndex == 2;

//     final bottomPadding = MediaQuery.of(context).padding.bottom;

//     return SizedBox(
//       height:
//           110 +
//           bottomPadding, // Increased height to include the floating button and bottom padding
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.bottomCenter,
//         children: [
//           // Bottom Navigation Background & Items
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: 70 + bottomPadding,
//               decoration: BoxDecoration(
//                 color: AppTheme.cardBackground,
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppTheme.primaryGold.withOpacity(0.15),
//                     blurRadius: 15,
//                     offset: const Offset(0, -3),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: EdgeInsets.only(top: 8, bottom: 4 + bottomPadding),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     _buildNavItem(
//                       icon: Icons.home_rounded,
//                       label: 'Home',
//                       index: 0,
//                     ),
//                     _buildNavItem(
//                       icon: Icons.search_rounded,
//                       svgPath: 'assets/images/checked.png',
//                       label: 'Check-In',
//                       index: 1,
//                     ),
//                     const SizedBox(width: 70),
//                     _buildNavItem(
//                       icon: Icons.self_improvement_rounded,
//                       label: 'Connect',
//                       index: 3,
//                     ),
//                     _buildNavItem(
//                       icon: Icons.card_giftcard_rounded,
//                       label: 'Remedies',
//                       index: 4,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Center Floating Button
//           Positioned(
//             top: 12,
//             child: GestureDetector(
//               onTap: () => widget.onTap(2),
//               behavior: HitTestBehavior.opaque, // Ensure taps are caught
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Replaced AnimatedBuilder and Transforms with a static Container
//                   Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       // gradient: isRashmiSelected
//                       //     ? const LinearGradient(
//                       //         begin: Alignment.topLeft,
//                       //         end: Alignment.bottomRight,
//                       //         colors: [
//                       //           AppTheme.primaryGold,
//                       //           AppTheme.darkGold,
//                       //           AppTheme.deepGold,
//                       //         ],
//                       //       )
//                       //     : const LinearGradient(
//                       //         begin: Alignment.topLeft,
//                       //         end: Alignment.bottomRight,
//                       //         colors: [
//                       //           AppTheme.lightGold,
//                       //           AppTheme.primaryGold,
//                       //         ],
//                       //       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppTheme.primaryGold.withOpacity(
//                             isRashmiSelected ? 0.7 : 0.4,
//                           ),
//                           blurRadius: isRashmiSelected ? 20 : 15,
//                           offset: const Offset(0, 6),
//                           spreadRadius: isRashmiSelected ? 3 : 2,
//                         ),
//                         if (isRashmiSelected)
//                           BoxShadow(
//                             color: AppTheme.primaryGold.withOpacity(0.3),
//                             blurRadius: 30,
//                             offset: const Offset(0, 0),
//                             spreadRadius: 5,
//                           ),
//                       ],
//                     ),
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Outer ring
//                         // if (isRashmiSelected)
//                         //   Container(
//                         //     width: 70,
//                         //     height: 70,
//                         //     decoration: BoxDecoration(
//                         //       shape: BoxShape.circle,
//                         //       border: Border.all(
//                         //         color: AppTheme.primaryGold.withOpacity(0.3),
//                         //         width: 2,
//                         //       ),
//                         //     ),
//                         //   ),
//                         // Icon
//                         ClipOval(
//                           child: SizedBox(
//                             width: 70,
//                             height: 70,
//                             child: Image.asset(
//                               'assets/images/brahmkosh_logo.jpeg',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // const SizedBox(height: 8),
//                   Text(
//                     'Ask BI',
//                     style: GoogleFonts.lora(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: isRashmiSelected
//                           ? AppTheme.primaryGold
//                           : AppTheme.textSecondary,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     String? svgPath,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = widget.currentIndex == index;
//     return GestureDetector(
//       onTap: () => widget.onTap(index),
//       behavior: HitTestBehavior.opaque,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           svgPath != null
//               ? Image.asset(
//                   svgPath,

//                   height: isSelected ? 24 : 22,
//                   width: isSelected ? 24 : 22,
//                 )
//               : Icon(
//                   icon,
//                   color: isSelected
//                       ? AppTheme.primaryGold
//                       : AppTheme.textSecondary,
//                   size: isSelected ? 24 : 22,
//                 ),
//           const SizedBox(height: 3),
//           AnimatedDefaultTextStyle(
//             duration: const Duration(milliseconds: 250),
//             style: GoogleFonts.lora(
//               fontSize: isSelected ? 11 : 10,
//               fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//               color: isSelected ? AppTheme.primaryGold : AppTheme.textSecondary,
//               letterSpacing: 0.3,
//             ),
//             child: Text(label),
//           ),
//         ],
//       ),
//     );
//   }
// }