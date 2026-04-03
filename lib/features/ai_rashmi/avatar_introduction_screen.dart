import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/agent/lemon_agent_page.dart';
import 'package:brahmakosh/features/ai_rashmi/deity_selection_service.dart';
import 'package:sizer/sizer.dart';

class AvatarIntroductionScreen extends StatefulWidget {
  final String? backgroundImage;
  const AvatarIntroductionScreen({super.key, this.backgroundImage});

  @override
  State<AvatarIntroductionScreen> createState() =>
      _AvatarIntroductionScreenState();
}

class _AvatarIntroductionScreenState extends State<AvatarIntroductionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DeitySelectionService _deityService = DeitySelectionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer:
          const SizedBox(), // No drawer needed for this screen or maybe re-implement if needed
      body: Stack(
        children: [
          // Background
          Builder(
            builder: (context) {
              if (widget.backgroundImage != null) {
                return Positioned.fill(
                  child: Image.asset(
                    widget.backgroundImage!,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.5.w,
                  vertical: 1.h,
                ),
                child: _buildHeader(context),
              ),
            ),
          ),

          // Talk Button
          Positioned(
            bottom: 5.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const AvatarAgentPage());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "Talk",
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Determine the current deity name and image logic
    String deityName = 'Krishna';
    String imageAsset = 'assets/images/Small_krishna.png';

    // Check widget config for default
    if (widget.backgroundImage?.contains('Rashmi') == true) {
      deityName = 'Rashmi';
      imageAsset = 'assets/images/Small_rashmi.png';
    }

    // Check selected deity or fallback
    if (_deityService.selectedDeity != null) {
      final name = _deityService.selectedDeity!.name ?? '';
      if (name.toLowerCase().contains('rashmi')) {
        deityName = 'Rashmi';
        imageAsset = 'assets/images/Small_rashmi.png';
      } else if (name.toLowerCase().contains('krishna')) {
        deityName = 'Krishna';
        imageAsset = 'assets/images/Small_krishna.png';
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context); // Go back to drawer/previous screen
          },
          child: Container(
            child: Icon(Icons.arrow_back, color: Colors.black, size: 4.5.w),
          ),
        ),

        // Center "Krishna" Button/Dropdown (Static here, no toggle)
        Container(
          height: 4.5.h,
          padding: EdgeInsets.symmetric(horizontal: 2.5.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Center(
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(imageAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  deityName,
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Empty placeholder to balance the row
        const SizedBox(width: 32),
      ],
    );
  }
}
