import 'dart:io';
import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brahmakosh/features/home/views/sponsor_card.dart';
import 'package:brahmakosh/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';
import 'package:brahmakosh/features/check_in/views/chanting_configuration_view.dart';
import 'package:brahmakosh/features/check_in/views/prayer_configuration_view.dart';
import 'package:brahmakosh/features/ai_rashmi/views/ai_guide_view.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/common/widgets/custom_profile_avatar.dart';
import 'package:brahmakosh/features/profile/views/profile_view.dart' as brahmakosh_profile;
import 'package:brahmakosh/features/pooja/blocs/pooja_bloc.dart';
import 'package:brahmakosh/features/pooja/blocs/pooja_event.dart';
import 'package:brahmakosh/features/pooja/blocs/pooja_state.dart';
import 'package:brahmakosh/features/pooja/models/pooja_model.dart';
import 'package:brahmakosh/features/pooja/repositories/pooja_repository.dart';
import 'package:brahmakosh/features/pooja/views/pooja_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';

class NewHomeView extends StatefulWidget {
  final ScrollController? scrollController;
  const NewHomeView({super.key, this.scrollController});

  @override
  State<NewHomeView> createState() => _NewHomeViewState();
}

class _NewHomeViewState extends State<NewHomeView> {
  final HomeController homeController = Get.put(HomeController());
  final AstrologyController astrologyController = Get.put(
    AstrologyController(),
  );
  final RedeemController redeemController = Get.put(RedeemController());
  int _selectedDiscoveryIndex = 0;
  final List<String> _discoveryTabs = [
    "Health",
    "Emotions",
    "Profession",
    "Luck",
    "Personal Life",
    "Travel",
  ];

  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  int _selectedCheckInIndex = -1;
  List<Activities> _checkInActivities = [];
  bool _isCheckInLoading = false;
  String _selectedRemedyTab = "MUST HAVE";

  @override
  void initState() {
    super.initState();
    // Ensure data is fresh when viewing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRefresh();
      _fetchCheckInData();
    });
  }

  Future<void> _fetchCheckInData() async {
    setState(() {
      _isCheckInLoading = true;
    });
    try {
      final response = await SpiritualRepository().getCheckIn();
      if (response != null &&
          response.data != null &&
          response.data!.activities != null) {
        setState(() {
          _checkInActivities = response.data!.activities!;
          if (_checkInActivities.isNotEmpty) {
            _selectedCheckInIndex = 0; // Default to first item
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching check-in data: $e");
    } finally {
      setState(() {
        _isCheckInLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      homeController.refreshHomeData(),
      astrologyController.refreshExperts(),
      redeemController.fetchRedemptionHistory(),
      Provider.of<ProfileViewModel>(context, listen: false).refreshProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFFD4AF37),
        backgroundColor: Colors.black,
        child: CustomScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTitle(),
            _buildMainBanner(screenWidth),
            _buildFeatureGrid(isTablet),
            _buildSpiritualCheckIn(),
            _buildKarmaDashboard(),
            _buildExpertConnect(screenWidth),
            _buildMuhuratSection(),
            _buildRemediesSection(screenWidth),
            // _buildSelfDiscoverySection(),
            _buildPujaVidhi(screenWidth),
            _buildSankalpTracker(),
            _buildSwapnaDecoder(),
            _buildGitaBanner(screenWidth),
            _buildSponsorsSection(screenWidth),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting Text
              Consumer<ProfileViewModel>(
                builder: (context, profileVM, child) {
                  final fullName = profileVM.profile?.profile?.name ?? " ";
                  // Extract first name only
                  final firstName = fullName.trim().split(' ').first;
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Namaste ",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: firstName,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD4AF37),
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Icons Row
              Row(
                children: [
                  // Notification Bell with red dot badge
                  GestureDetector(
                    onTap: () => Get.toNamed(AppConstants.routeNotifications),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                          ),
                          child: SvgPicture.asset(
                          'assets/icons/notification.svg',
                        color: Colors.white,
                        ),
                      
                        ),
                        // Red badge dot
                        Positioned(
                          top: 8,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Profile Avatar with gold ring
                  GestureDetector(
                    onTap: () async {
                      final result = await Get.to(
                        () => const brahmakosh_profile.ProfileView(),
                      );
                      if (result != null && result is int && context.mounted) {
                        Provider.of<DashboardViewModel>(
                          context,
                          listen: false,
                        ).changeTab(result);
                      }
                    },
                    child: Consumer<ProfileViewModel>(
                      builder: (context, profileVM, child) {
                        return CustomProfileAvatar(
                          imageUrl: profileVM.profile?.profileImageUrl,
                          radius: 20.0,
                          borderWidth: 1.5,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildSearchBar() {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center, // Keeps icon/text aligned
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            hintText: "Search rituals, puja, astrologers",
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.35),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_sharp, // Rounded variant looks cleaner
              color: Colors.white.withOpacity(0.5),
              size: 30,
            ),
            // Use OutlineInputBorder to get the surrounding ring
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none, // Invisible by default
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none, // Invisible when not focused
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFD4AF37), // Your theme purple
                width: 1.2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Center(
          child: Text(
            "BRAHMAKOSH",
            style: GoogleFonts.lora(
              color: const Color(0xFFD4AF37),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainBanner(double screenWidth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Obx(() {
        final message = homeController.activeFounderMessage;
        final krishaImageUrl =
            message?.founderImage ?? 'assets/images/home_krishna_banner.png';

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: screenWidth * 0.9, // Adaptive height
              child: PageView(
                controller: _bannerController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                children: [
                  _buildBannerItem(
                    krishaImageUrl,
                    "Talk to Krishna",
                    () => Get.to(
                      () => const AiGuideView(
                        deityName: "Krishna",
                        subtitle: "Divine Cosmic Intelligence",
                        backgroundImage: 'assets/images/rashmi_background.jpeg',
                        characterImagePath: 'assets/images/Krishana_new.png',
                        chatBackgroundImage: 'assets/images/Krishna_chat.png',
                      ),
                    ),
                    isNetwork: message?.founderImage != null,
                  ),
                  _buildBannerItem(
                    'assets/images/TalkToRashmiBack.png',
                    "Talk to Rashmi",
                    () => Get.to(
                      () => const AiGuideView(
                        deityName: "Rashmi",
                        subtitle: "Your Spiritual Guide",
                        backgroundImage: 'assets/images/rashmi_background.jpeg',
                        characterImagePath: 'assets/images/Rashmi_new.png',
                        chatBackgroundImage: 'assets/images/Rashmi_chat.png',
                      ),
                    ),
                    isNetwork: false,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  final bool isSelected = _currentBannerIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isSelected ? 20 : 6,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

  Widget _buildBannerItem(
    String imageUrl,
    String buttonText,
    VoidCallback onPressed, {
    bool isNetwork = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: isNetwork
                ? NetworkImage(ApiUrls.getFormattedImageUrl(imageUrl)!)
                : AssetImage(imageUrl) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: onPressed,
                  icon: const Icon(Icons.call_rounded, size: 20),
                  label: Text(
                    buttonText,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildGridItem(String title, String iconPath, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. The Border & Background Layer
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // This creates the gradient border effect
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.4), // Visible border at top
                  Colors.white.withOpacity(0.05),           // Fades out at bottom
                ],
              ),
            ),
            // The Inner Content (Padding creates the border thickness)
            padding: const EdgeInsets.all(1.2), 
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), // slightly smaller
                color: const Color(0xFF0A0A0A), // Solid dark inner background
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 2. The Floating Icon
        Positioned(
          top: -10, 
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              // Shadow to make the icon "pop"
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                iconPath,
                width: 75,
                height: 75,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildFeatureGrid(bool isTablet) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 4 : 3,
          mainAxisSpacing: 30, // Space between rows
          crossAxisSpacing: 12, // Space between columns
          childAspectRatio: 0.82, // Adjusted to fit the icon + card height
        ),
        delegate: SliverChildListDelegate([
          _buildGridItem(
            "Check - In",
            "assets/icons/check_in.png",
            onTap: () => Get.toNamed(AppConstants.routeCheckIn),
          ),
          _buildGridItem(
            "Astrology",
            "assets/icons/astrology.png",
            onTap: () => Get.toNamed(AppConstants.routeAstrologyDetails),
          ),
          _buildGridItem(
            "Expert Connect",
            "assets/icons/expert_connect.png",
            onTap: () => Provider.of<DashboardViewModel>(
              context,
              listen: false,
            ).changeTab(3),
          ),
          _buildGridItem(
            "Remedies",
            "assets/icons/remedies.png",
            onTap: () => Provider.of<DashboardViewModel>(
              context,
              listen: false,
            ).changeTab(4),
          ),
          _buildGridItem(
            "Sankalp Tracker",
            "assets/icons/sankalptracker.png",
            onTap: () => Get.toNamed(AppConstants.routeSankalp),
          ),
          _buildGridItem(
            "Puja Vidi",
            "assets/icons/puja_vidhi.png",
            onTap: () => Get.toNamed(AppConstants.routePoojaList),
          ),
        ]),
      ),
    );
  }

  // Placeholder methods for other sections
 Widget _buildSpiritualCheckIn() {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111), // Match dark background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1),width: 1),
        ),
        child: Column(
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ARE YOU SPRITUAL ?",
                  style: GoogleFonts.poppins( // Cleaner look
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "${_selectedCheckInIndex + 1}/${_checkInActivities.length}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFD447), // Brighter gold
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Horizontal Activity List
            if (_isCheckInLoading && _checkInActivities.isEmpty)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFFD447)))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_checkInActivities.length, (index) {
                    final activity = _checkInActivities[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCheckInIndex = index),
                        child: _buildActivityItem(
                          activity.title ?? "",
                          _getActivityIconPath(activity.title ?? ""),
                          isSelected: _selectedCheckInIndex == index,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            const SizedBox(height: 24),

            // The White Action Button
            SizedBox(
              width: 185,
              height: 36,
              // Specific width from image
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _onCheckInNowPressed,
                child: Text(
                  "CHECK-IN NOW",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  String _getActivityIconPath(String title) {
    switch (title.toLowerCase()) {
      case 'prayer':
        return 'assets/icons/prayer.png';
      case 'chanting':
        return 'assets/icons/chanting.png';
      case 'meditation':
        return 'assets/icons/meditation.png';
      case 'silence':
        return 'assets/icons/silence.png';
      default:
        return 'assets/icons/check_in.png';
    }
  }

  void _onCheckInNowPressed() {
    if (_checkInActivities.isEmpty || _selectedCheckInIndex == -1) {
      Get.toNamed(AppConstants.routeCheckIn);
      return;
    }

    final activity = _checkInActivities[_selectedCheckInIndex];

    if (activity.title == 'Chanting') {
      Get.to(
        () => ChantingConfigurationView(chantingCategoryId: activity.id!),
      );
    } else if (activity.title == 'Prayer' && activity.id != null) {
      Get.to(() => PrayerConfigurationView(prayerCategoryId: activity.id!));
    } else if (activity.id != null) {
      Get.toNamed(
        AppConstants.routeSpiritualConfiguration,
        arguments: {'categoryId': activity.id!, 'title': activity.title},
      );
    } else {
      Get.toNamed(AppConstants.routeCheckIn);
    }
  }

Widget _buildActivityItem(String title, String imagePath, {bool isSelected = false}) {
  final double size = isSelected ? 105 : 90;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Clean gold border only when selected
          border: isSelected 
              ? Border.all(color: const Color(0xFFFFD447), width: 1.08) 
              : Border.all(color: Colors.transparent, width: 2.0),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFFFFD447).withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ] : [],
        ),
        padding: EdgeInsets.all(isSelected ? 4 : 0), 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        title,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          fontSize: isSelected ? 16 : 14,
          fontWeight: isSelected ? FontWeight.w400 : FontWeight.w400,
        ),
      ),
    ],
  );
}
  Widget _buildKarmaDashboard() {
    return SliverToBoxAdapter(
      child: Consumer<ProfileViewModel>(
        builder: (context, profileVM, child) {
          final karmaPoints = profileVM.profile?.karmaPoints ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1),width:  1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "KARMA DASHBOARD",
                        style: GoogleFonts.poppins(
                          color: Color(0xff8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppConstants.routeRedeem),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFD4AF37).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: -2,
                              )
                            ],
                          ),
                          child: Text(
                            "REDEEM",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD4AF37),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      // Karma Points
                      Expanded(
                        child: _buildKarmaStat(
                          "KARMA POINTS",
                          NumberFormat("#,###").format(karmaPoints),
                          iconPath: "assets/icons/star_rounded.svg",
                        ),
                      ),
                      _buildVerticalDivider(),
                      // Seva Done
                      Obx(() {
                        final completedCount = redeemController.redemptionHistory
                            .where(
                              (item) =>
                                  item.status.toLowerCase() == 'completed',
                            )
                            .length;
                        return Expanded(
                          child: _buildKarmaStat(
                            "SEVA DONE",
                            completedCount.toString(),
                            iconPath: "assets/icons/support.svg",
                          ),
                        );
                      }),
                      _buildVerticalDivider(),
                      // Alignment
                      Expanded(
                        child: _buildKarmaStat(
                          "ALIGNMENT",
                          "9.0",
                          suffix: "/10",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildKarmaStat(
    String label,
    String value, {
    String? iconPath,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: suffix != null ? const Color(0xFFFFD447) : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (iconPath != null) ...[
              const SizedBox(width: 4),
              SvgPicture.asset(
                iconPath,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFD447),
                  BlendMode.srcIn,
                ),
              ),
            ],
            if (suffix != null) ...[
              Text(
                suffix,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildExpertConnect(double screenWidth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "EXPERT CONNECT",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Provider.of<DashboardViewModel>(
                      context,
                      listen: false,
                    ).changeTab(3),
                    child: Text(
                      "View All",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD4AF37),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final experts = astrologyController.experts;
              if (astrologyController.isLoading.value && experts.isEmpty) {
                return const SizedBox(
                  height: 184,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                );
              }
              if (experts.isEmpty) {
                return SizedBox(
                  height: 184,
                  child: Center(
                    child: Text(
                      "No experts available",
                      style: GoogleFonts.lora(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 185,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: experts.length,
                  itemBuilder: (context, index) {
                    return _buildExpertCard(experts[index], screenWidth);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCard(dynamic expert, double screenWidth) {
    bool isOnline =
        expert.status?.toLowerCase() == 'online' ||
        expert.status?.toLowerCase() == 'available';
    return GestureDetector(
      onTap: () => astrologyController.navigateToProfile(expert),
      child: Container(
        width: screenWidth * 0.7, // Adaptive width
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                
                    Container(
                     padding: const EdgeInsets.all(2), // Border width
                     decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:  Color(0xFFD4AF37), // Border color
                          width: 2,
                        ),
                        ),
                        child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      backgroundImage: () {
                        if (expert.profilePhoto == null || expert.profilePhoto!.isEmpty) {
                          return const AssetImage('assets/images/logo.png') as ImageProvider;
                        }
                        final photo = expert.profilePhoto!;
                        if (photo.startsWith('file://')) {
                          return FileImage(File(photo.replaceFirst('file://', '')));
                        }
                        if (photo.startsWith('/')) {
                          return FileImage(File(photo));
                        }
                        final formattedUrl = ApiUrls.getFormattedImageUrl(photo);
                        if (formattedUrl == null) {
                          return const AssetImage('assets/images/logo.png') as ImageProvider;
                        }
                        return NetworkImage(formattedUrl);
                      }(),
                    ),
                    ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expert.name ?? "Expert",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOnline ? "ONLINE" : "OFFLINE",
                              style: GoogleFonts.poppins(
                                color: isOnline ? Colors.green : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        expert.expertise ?? "Astrology",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${expert.experience ?? 0}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
               Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: const Color(0xFF2C2C2E), // Subtle dark grey background
    borderRadius: BorderRadius.circular(20), // Pill shape
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min, // Shrinks container to content size
    children: [
      Text(
        "${expert.rating ?? 0.0}",
        style: GoogleFonts.poppins( // Switched to Poppins for that clean look
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: 4), // Gap between text and star
      const Icon(
        Icons.star_rounded, // Rounded version looks more like the image
        color: Color(0xFFFFD447), // Brighter yellow/gold
        size: 16,
      ),
    ],
  ),
)
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                   flex: 0,
                  child: GestureDetector(
                    onTap: () => astrologyController.startChat(expert),
                    child: _buildExpertActionButton("CHAT"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                   flex: 0,
                  child: GestureDetector(
                    onTap: () => astrologyController.navigateToProfile(expert),
                    child: _buildExpertActionButton("TALK", isPrimary: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertActionButton(String label, {bool isPrimary = false}) {
    return Container(
      // height: 40,
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFD4AF37) : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: isPrimary ? null : Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5),width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isPrimary ? Colors.black : const Color(0xFFD4AF37),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMuhuratSection() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (homeController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final panchang = homeController.panchangData;
        if (panchang == null) return const SizedBox.shrink();

        final basic = panchang.basicPanchang;
        final advanced = panchang.advancedPanchang;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TODAY'S MUHURAT",
                    style: GoogleFonts.poppins(
                      color: Color(0xff8E8E93),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
      child: _buildMuhuratTimeCard(
        "SUNRISES & SUNSET",
        formatTimeToAMPM(basic?.sunrise), // formats to e.g. "6:24 AM"
        formatTimeToAMPM(basic?.sunset),  // formats to e.g. "6:15 PM"
        Icons.wb_sunny_outlined,
        const Color(0xFFFF9933),
      ),
    ),  
                  const SizedBox(width: 10),
                 Expanded(
        child: _buildMuhuratTimeCard(
       "MOONRISE & MOONSET",
    // Logic for Moonrise
      formatTimeToAMPM(
      (basic?.moonrise?.isNotEmpty ?? false) 
          ? basic!.moonrise 
          : advanced?.moonrise
      ),
    // Logic for Moonset
      formatTimeToAMPM(
      (basic?.moonset?.isNotEmpty ?? false) 
          ? basic!.moonset 
          : advanced?.moonset
    ),
    Icons.nightlight_round_outlined,
    const Color(0xFF8A9DFF), // Updated to the softer blue from your image
  ),
),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "PERSONALIZED ASTROLOGY MUHURAT",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailedMuhuratCard(
                "Abhijit Muhurat",
                "${formatTimeToAMPM(advanced?.abhijitMuhurta?.start)} - ${formatTimeToAMPM(advanced?.abhijitMuhurta?.end)}",
                "HIGHLY AUSPICIOUS",
                const Color(0xFF22C55E),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildMuhuratRow(
                      "Rahu Kaal",
                      "${formatTimeToAMPM(advanced?.rahukaal?.start)} - ${formatTimeToAMPM(advanced?.rahukaal?.end)}",
                      "(AVOID)",
                      Colors.red,
                    ),
                    _buildMuhuratRow(
                      "Tithi",
                      basic?.tithi ?? "Loading...",
                      advanced?.panchang?.tithi?.endTime != null
                          ? "Until ${(advanced!.panchang!.tithi!.endTime!.hour! % 24).toString().padLeft(2, '0')}:${advanced!.panchang!.tithi!.endTime!.minute.toString().padLeft(2, '0')}"
                          : (basic?.paksha ?? ""),
                      const Color(0xFFD4AF37),
                    ),
                    _buildMuhuratRow(
                      "Nakshatra",
                      basic?.nakshatra ?? "--",
                      advanced?.panchang?.nakshatra?.endTime != null
                          ? "Until ${(advanced!.panchang!.nakshatra!.endTime!.hour! % 24).toString().padLeft(2, '0')}:${advanced!.panchang!.nakshatra!.endTime!.minute.toString().padLeft(2, '0')}"
                          : "",
                      const Color(0xFFD4AF37),
                    ),
                    _buildMuhuratRow(
                      "Hindu Month",
                      advanced?.hinduMaah?.purnimanta ?? "--",
                      "",
                      const Color(0xFFD4AF37),
                    ),
                    _buildMuhuratRow(
                      "Ritu",
                      basic?.ritu ?? (advanced?.ritu ?? "--"),
                      "",
                      const Color(0xFFD4AF37),
                    ),
                    _buildMuhuratRow(
                      "Direction",
                      basic?.dishaShool ?? (advanced?.dishaShool ?? "--"),
                      "",
                      Colors.orange,
                    ),
                    _buildMuhuratRow(
                      "Sun / Moon Sign",
                      "${advanced?.sunSign ?? '--'} / ${advanced?.moonSign ?? '--'}",
                      "",
                      const Color(0xFFE67E22),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
               
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppConstants.routePanchang),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xff1C1C1E),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white.withOpacity(0.1),width: 1.17),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "View Today's Panchang",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFFD4AF37),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

 Widget _buildMuhuratTimeCard(String label, String time1, String time2, IconData icon, Color themeColor) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF121212), // Dark card background
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        // Icon with Glow Effect
        Stack(
          alignment: Alignment.center,
          children: [
            // The Glow
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.5),
                    blurRadius: 25,
                    spreadRadius: 15,
                  ),
                ],
              ),
            ),
            // The Icon
            Icon(icon, color: themeColor, size: 32),
          ],
        ),
        const SizedBox(height: 16),
        // Title Text
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Time Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time1,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.circle, color: Colors.white.withOpacity(0.4), size: 4),
            ),
            Text(
              time2,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String formatTimeToAMPM(String? time) {
  if (time == null || time.isEmpty || time == "--:--") return "--:--";
  try {
    // If your time is already a string like "06:30:00" or "18:30"
    // We parse it and then re-format it to 12-hour style
    final DateTime parsedTime = DateFormat("HH:mm").parse(time);
    return DateFormat("h:mm a").format(parsedTime);
  } catch (e) {
    // Fallback if the string is already partially formatted or in a different style
    return time; 
  }
}

  Widget _buildDetailedMuhuratCard(
    String title,
    String time,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color:Color(0xFFD4AF37).withOpacity(0.20),width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.1),width: 1),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: const Color(0xFFD4AF37),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuhuratRow(
    String title,
    String value,
    String tag,
    Color tagColor, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: tagColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (tag.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  tag,
                  style: GoogleFonts.poppins(
                    color: tagColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: Colors.white.withOpacity(0.05),
            height: 2,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildRemediesSection(double screenWidth) {
    // Hardcoded remedy data
    final mustHaveRemedies = [
      {
        "title": "7 Mukhi Rudraksha",
        "subtitle": "For spiritual protection & planet Saturn...",
        "price": "1,299",
        "image": "https://img.freepik.com/premium-photo/rudraksha-isolated-white-background_1025754-1845.jpg?w=740",
      },
      {
        "title": "Yellow Sapphire",
        "subtitle": "For wealth, prosperity & planet Jupiter...",
        "price": "15,500",
        "image": "https://img.freepik.com/premium-photo/yellow-sapphire-gemstone-isolated-white-background_1025754-2091.jpg?w=740",
      },
    ];

    final goodToHaveRemedies = [
      {
        "title": "Sphatik Mala",
        "subtitle": "For peace, concentration & planet Moon...",
        "price": "850",
        "image": "https://img.freepik.com/free-photo/shiny-white-crystal-beads-necklace_53876-104917.jpg?t=st=1710675715~exp=1710679315~hmac=8e6b1b6c0b1b0b2b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9a0b1",
      },
      {
        "title": "Gomati Chakra",
        "subtitle": "For protection, prosperity and bringing luck...",
        "price": "150",
        "image": "https://img.freepik.com/premium-photo/gomti-chakra-shell-isolated-white-background_1025754-2150.jpg?w=740",
      },
    ];

    final displayedRemedies = _selectedRemedyTab == "MUST HAVE" ? mustHaveRemedies : goodToHaveRemedies;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0.0,
              ),
              child: Text(
                "PERSONALIZED REMEDIES",
              style: GoogleFonts.poppins(
                color: Color(0xff8E8E93),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      "MUST HAVE",
                      isSelected: _selectedRemedyTab == "MUST HAVE",
                      onTap: () {
                        setState(() {
                          _selectedRemedyTab = "MUST HAVE";
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      "GOOD TO HAVE",
                      isSelected: _selectedRemedyTab == "GOOD TO HAVE",
                      onTap: () {
                        setState(() {
                          _selectedRemedyTab = "GOOD TO HAVE";
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: displayedRemedies.length,
              itemBuilder: (context, index) {
                final remedy = displayedRemedies[index];
                return _buildProductCard(
                  remedy["title"]!,
                  remedy["subtitle"]!,
                  remedy["price"]!,
                  remedy["image"]!,
                  screenWidth,
                  isNetwork: true,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTabButton(String label, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
    
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    String title,
    String subtitle,
    String price,
    String imagePath,
    double screenWidth, {
    bool isNetwork = false,
  }) {
    return Container(
      width: screenWidth * 0.48,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: isNetwork
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white10,
                        child: const Icon(Icons.image, color: Colors.white24),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹$price",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD4AF37),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  "SHOP",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPujaVidhi(double screenWidth) {
    return BlocProvider(
      create: (context) =>
          PoojaBloc(repository: PoojaRepository())..add(FetchPoojas()),
      child: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0.0,
                ),
                child: Text(
                  "PUJA VIDHI",
                style: GoogleFonts.poppins(
                  color: Color(0xff8E8E93),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            BlocBuilder<PoojaBloc, PoojaState>(
              builder: (context, state) {
                if (state is PoojaLoading) {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    ),
                  );
                } else if (state is PoojaLoaded) {
                  if (state.filteredPoojas.isEmpty) {
                    return SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          "No Puja available",
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: state.filteredPoojas.length,
                      itemBuilder: (context, index) {
                        final pooja = state.filteredPoojas[index];
                        return _buildRealPujaCard(pooja, screenWidth);
                      },
                    ),
                  );
                } else if (state is PoojaError) {
                  return SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        "Error loading Puja Vidhi",
                        style: TextStyle(color: Colors.red.withOpacity(0.7)),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildRealPujaCard(PoojaModel pooja, double screenWidth) {
    return GestureDetector(
      onTap: () {
        Get.to(() => PoojaDetailScreen(poojaId: pooja.sId ?? ""));
      },
      child: Container(
        width: screenWidth * 0.55, // Adaptive width
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          image: pooja.thumbnailUrl != null && pooja.thumbnailUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(pooja.thumbnailUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFD4AF37),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pooja.pujaName ?? "Unknown Puja",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lora(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pooja.subcategory ?? pooja.category ?? "Ritual",
                        style: GoogleFonts.lora(
                          color: const Color(0xFFD4AF37),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pooja.description ?? "Step-by-step guide for ritual.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lora(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );

  }


  Widget _buildSankalpTracker() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SANKALP TRACKER",
              style: GoogleFonts.poppins(
                color: const Color(0xff8E8E93),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05),width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Morning Prayer",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "A peaceful start to your spiritual journey.",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // pray_new.svg with glow
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.15),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/pray_new.svg',
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "DAILY PROGRESS",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "75%",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD4AF37),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () => Get.toNamed(AppConstants.routeSankalp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_outline, size: 22,color: Colors.black,),
                          const SizedBox(width: 8),
                          Text(
                            "TRACK YOUR SANKALP",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapnaDecoder() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SWAPNA DECODER",
              style: GoogleFonts.poppins(
                color: const Color(0xff8E8E93),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Large circular glow icon (outer spread)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF222222),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.nightlight_outlined,
                          color: const Color(0xFFD4AF37),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Decode Your Dream",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // go_tab.svg icon at top right
                                SvgPicture.asset(
                                  'assets/icons/go_tab.svg',
                                  width: 24,
                                  height: 24,
                                  color: Color(0xFFD4AF37),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "What did you see in your sleep last night?",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Dream Input Field
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.1),width: 1),
                    ),
                    child: TextField(
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        fillColor: const Color(0xFF0A0A0A),
                        filled: true,
                        hintText: "Enter your dream....",
                        hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1),width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1),width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => Get.toNamed(AppConstants.routeSwapnaDecoder),
                              icon: const Icon(Icons.send_rounded, color: Color(0xFFD4AF37), size: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGitaBanner(double screenWidth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
        child: Container(
          height: screenWidth * 1.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            image: const DecorationImage(
              image: AssetImage('assets/images/bhagavad_gita_banner.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              // ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Learn Bhagavad Gita",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      color: const Color(0xFFD4AF37),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Timeless Wisdom for Modern Life",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      color: Color(0xff8E8E93),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Get.toNamed(AppConstants.routeGita),
                      child: Text(
                        "START YOUR JOURNEY",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelfDiscoverySection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Text(
              "PERSONALITY & SELF-DISCOVERY",
              style: GoogleFonts.lora(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(_discoveryTabs.length, (index) {
                final isSelected = _selectedDiscoveryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDiscoveryIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _discoveryTabs[index],
                      style: GoogleFonts.lora(
                        color: isSelected
                            ? Colors.black
                            : Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Obx(() {
            final panchang = homeController.panchangData;
            final prediction = panchang?.dailyNakshatraPrediction?.prediction;
            String content = "Loading insights for your star...";

            if (prediction != null) {
              switch (_discoveryTabs[_selectedDiscoveryIndex]) {
                case "Health":
                  content =
                      prediction.health ?? "Maintain a balanced diet today.";
                  break;
                case "Emotions":
                  content = prediction.emotions ?? "Stay calm and meditative.";
                  break;
                case "Profession":
                  content =
                      prediction.profession ?? "Good day for new beginnings.";
                  break;
                case "Luck":
                  content = prediction.luck ?? "Fortune favors the bold.";
                  break;
                case "Personal Life":
                  content =
                      prediction.personalLife ?? "Spend time with loved ones.";
                  break;
                case "Travel":
                  content =
                      prediction.travel ?? "Short trips might be beneficial.";
                  break;
              }
            } else if (!homeController.isPanchangLoading) {
              content = "Data unavailable at the moment.";
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1A1A1A), const Color(0xFF141414)],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getDiscoveryIcon(
                        _discoveryTabs[_selectedDiscoveryIndex],
                      ),
                      color: const Color(0xFFD4AF37),
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getDiscoveryIcon(String tab) {
    switch (tab) {
      case "Health":
        return Icons.favorite_border;
      case "Emotions":
        return Icons.psychology_outlined;
      case "Profession":
        return Icons.work_outline;
      case "Luck":
        return Icons.auto_awesome_outlined;
      case "Personal Life":
        return Icons.home_outlined;
      case "Travel":
        return Icons.explore_outlined;
      default:
        return Icons.star_border;
    }
  }

  Widget _buildSponsorsSection(double screenWidth) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (homeController.isSponsorLoading) {
          return const SizedBox.shrink();
        }
        if (homeController.sponsors.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Text(
                'OUR SPONSORS',
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              height: screenWidth * 0.25, // Adaptive height
              constraints: const BoxConstraints(maxHeight: 120, minHeight: 80),
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SponsorLogoTicker(sponsors: homeController.sponsors),
            ),
          ],
        );
      }),
    );
  }
}
