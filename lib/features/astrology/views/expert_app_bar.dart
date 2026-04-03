import '../../../core/common_imports.dart';
import '../controllers/astrology_controller.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';

class AstrologyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const AstrologyAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller = Get.find<AstrologyController>();
    final displayTitle = title ?? 'expert_connect_title'.tr;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.goldGradient, // Use gold gradient from AppTheme
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppTheme.textPrimary,
          size: 24,
        ), // Use textPrimary color
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Text(
        displayTitle,
        style: GoogleFonts.lora(
          // Use Cinzel font for titles
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary, // Use textPrimary color
        ),
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground, // Use cardBackground from AppTheme
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.currency_rupee_sharp,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Consumer<ProfileViewModel>(
                builder: (context, profileVM, child) {
                  final credits = profileVM.profile?.credits ?? 0;
                  return Text(
                    credits.toString(),
                    style: GoogleFonts.lora(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.history,
            color: AppTheme.textPrimary,
            size: 24,
          ), // Use textPrimary color
          onPressed: () => controller.openHistory(),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

