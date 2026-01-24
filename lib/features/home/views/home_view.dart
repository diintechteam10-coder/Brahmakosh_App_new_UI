import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:brahmakosh/features/home/views/brahmkosh_bazar_card.dart';
import 'package:brahmakosh/features/home/views/chatbot_bannner.dart';
import 'package:brahmakosh/features/home/views/focus.dart';
import 'package:brahmakosh/features/home/views/founder_massegs.dart';
import 'package:brahmakosh/features/home/views/generate_avtar_card.dart';
import 'package:brahmakosh/features/home/views/lucky_flip_card.dart';
import 'package:brahmakosh/features/home/views/panchang_card.dart';
import 'package:brahmakosh/features/home/views/testimonials.dart';
import 'package:brahmakosh/features/home/views/sponsor_card.dart'; // Import the new SponsorCard
import 'package:brahmakosh/features/updates/story.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Import smooth_page_indicator

import '../../../common/utils.dart';
import '../../ai_rashmi/aradhya_selection_view.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../../../core/common_imports.dart';
import '../../dashboard/viewmodels/dashboard_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  int selectedDateIndex = 1;
  bool isAM = true;

  late final HomeController homeController = Get.put(HomeController());
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.fetchFounderMessages(this);
      homeController.fetchSponsors(this);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      homeController.fetchFounderMessages(this),
      homeController.fetchSponsors(this),
      Provider.of<DashboardViewModel>(
        context,
        listen: false,
      ).initLocationUpdate(this, forceRefresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryGold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<ProfileViewModel>(
                      builder: (context, profileViewModel, child) {
                        final profile = profileViewModel.profile;
                        final String? name =
                            profile?.profile?.name ??
                            StorageService.getString(AppConstants.keyUserName);
                        final String? image =
                            profile?.profileImageUrl ??
                            StorageService.getString(AppConstants.keyUserImage);

                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // border: Border.all(
                                  //   color: AppTheme.primaryGold.withOpacity(0.5),
                                  //   width: 2,
                                  // ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGold.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/brahmkosh_logo.jpeg',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name ?? "Brahmakosh",
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Consumer<DashboardViewModel>(
                                  builder:
                                      (context, dashboardViewModel, child) {
                                        final address =
                                            dashboardViewModel
                                                .userLocationAddress ??
                                            StorageService.getString(
                                              AppConstants.keyUserLocation,
                                            );
                                        if (address == null || address.isEmpty)
                                          return const SizedBox.shrink();
                                        return Text(
                                          address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lora(
                                            fontSize: 11,
                                            color: AppTheme.textSecondary,
                                          ),
                                        );
                                      },
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications,
                                color: AppTheme.textPrimary,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildTopBar(),

            const SizedBox(height: 10),
            PremiumChatCard(
              title: "Talk to BI Rashmi",
              subtitle: "Premium guidance just for you",
              backgroundImage: "assets/images/rashmi_bi_without.jpeg",
              messages: [
                "✨ Career & Finance Advice",
                "❤️ Love & Relationship",
                "🕉️ Kundli Analysis",
                "🔮 Future Predictions",
              ],
              onTap: () async {
                // Navigate to Aradhya Selection screen with callback
                await Get.to(
                  () => AradhyaSelectionView(
                    onDeitySelected: () async {
                      // Navigate to Rashmi AI screen (index 2 in dashboard)
                      Provider.of<DashboardViewModel>(
                        context,
                        listen: false,
                      ).changeTab(2);
                    },
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppTheme.primaryGold.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 1, right: 1, top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PraharSectionHeader(
                      //   praharName: 'BRAHMA PRAHAR',
                      //   timing: '8:00 AM - 10:00 AM',
                      // ), //backgroundImage: "assets/images/banner_bi.jpeg",
                      // PraharInfoCard(
                      //   praharName: "BRAHMA PRAHAR",
                      //   praharTiming: "12 PM - 3 PM",
                      //   energy: "High Energy",
                      //   auspiciousTime: "12:30 PM - 1:30 PM",
                      //   actionGoodFor: "New Plasms, Meditation",
                      //   actionAvoid: "Ergo clash, Stressful tasks",
                      //   inuspiciousTime: "12:30 PM - 1:30 PM",
                      // ),
                      // const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(
                            16,
                          ), // slightly reduced padding
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.cardBackground.withOpacity(0.95),
                                AppTheme.cardBackground.withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: AppTheme.primaryGold.withOpacity(0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                            border: Border.all(
                              color: AppTheme.primaryGold.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Luck in Your Favour ⭐',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: LuckyFlipCard(
                                      icon: Icons.color_lens,
                                      title: 'Lucky Colors',
                                      luckyNumber: '7',
                                      luckyColor: AppTheme.primaryGold,
                                      luckyColorName: 'Gold',
                                      cardId: 'lucky_colors',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LuckyFlipCard(
                                      icon: Icons.numbers,
                                      title: 'Lucky Number',
                                      luckyNumber: '8',
                                      luckyColor: AppTheme.chakraBlue,
                                      luckyColorName: 'Azure',
                                      cardId: 'lucky_number',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LuckyFlipCard(
                                      icon: Icons.emoji_people,
                                      title: 'Angel Blessing',
                                      luckyNumber: '111',
                                      luckyColor: AppTheme.primaryGold,
                                      luckyColorName: 'Blessing',
                                      cardId: 'angel_blessing',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.touch_app,
                                      size: 16,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Tap to reveal',
                                      style: GoogleFonts.lora(
                                        fontSize: 10.5,
                                        color: AppTheme.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PanchangCard(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            FocusInfoCard(),
            const SizedBox(height: 20),

            AvatarStudioCard(),
            const SizedBox(height: 20),
            BrahmBazarCard(
              onMoreTap: () {
                Get.toNamed(AppConstants.brahmBazar);
              },
            ),

            TestimonialsCarousel(),
            const SizedBox(height: 20),
            Obx(() {
              if (homeController.isSponsorLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (homeController.sponsors.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Sponsors',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Use PageView.builder for single sponsor display
                    Container(
                      height: 90, // 👈 patli strip
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        //  color: Colors.black.withOpacity(0.85),
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.1)),
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: SponsorLogoTicker(
                        sponsors: homeController.sponsors,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: homeController.sponsors.length,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: AppTheme.primaryGold,
                          dotColor: AppTheme.lightGold,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            Obx(() {
              if (homeController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final message = homeController.activeFounderMessage;
              if (message == null) return const SizedBox.shrink();

              return FounderMessageCard(
                founderName: message.founderName,
                designation: message.position,
                message: message.content,
                imageUrl: message.founderImage,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Column(children: [WhatsAppStatusWidget()]);
  }
}
