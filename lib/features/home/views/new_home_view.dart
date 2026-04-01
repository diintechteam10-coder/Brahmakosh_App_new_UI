import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../sankalp/blocs/sankalp_bloc.dart';
import '../../sankalp/blocs/sankalp_state.dart';
import '../../sankalp/models/sankalp_model.dart';
import '../../sankalp/views/sankalp_screen.dart';
import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:sizer/sizer.dart';
import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';
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
import 'package:brahmakosh/common/widgets/custom_popups.dart';
import 'package:brahmakosh/common/widgets/custom_profile_avatar.dart';
import 'package:brahmakosh/features/profile/views/profile_view.dart'
    as brahmakosh_profile;
import 'package:brahmakosh/features/notifications/blocs/notification_bloc.dart';
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
    "health",
    "emotions",
    "profession",
    "luck",
    "personal_life",
    "travel",
  ];

  int _selectedCheckInIndex = -1;

  List<Activities> _checkInActivities = [];
  bool _isCheckInLoading = false;
  String _selectedRemedyTab = "must_have";

  // Focus management
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _swapnaFocusNode = FocusNode();

  // Scroll Controller for check-in activities
  final ScrollController _checkInScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ensure data is fresh when viewing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRefresh();
      _fetchCheckInData();
      _unfocusAll(); // Initial clean state
      context.read<NotificationBloc>().add(RefreshUnreadCount());
      _startComingSoonTimer();
    });
  }

  void _startComingSoonTimer() {
    _comingSoonTimer?.cancel();
    _comingSoonTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_comingSoonPageController.hasClients) {
        int nextPage = (_comingSoonPageIndex + 1) % _comingSoonProjects.length;
        _comingSoonPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _comingSoonTimer?.cancel();
    _comingSoonPageController.dispose();
    _searchFocusNode.dispose();
    _swapnaFocusNode.dispose();
    _checkInScrollController.dispose();
    super.dispose();
  }

  void _unfocusAll() {
    _searchFocusNode.unfocus();
    _swapnaFocusNode.unfocus();
    // Also global unfocus just in case
    FocusManager.instance.primaryFocus?.unfocus();
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

  void _scrollToSelectedCheckIn(int index) {
    if (!_checkInScrollController.hasClients) return;
    final screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = 22.w + 20.0;
    double offset = (index * itemWidth) - (screenWidth / 2) + (26.w / 2);

    if (offset < 0) offset = 0;
    if (offset > _checkInScrollController.position.maxScrollExtent) {
      offset = _checkInScrollController.position.maxScrollExtent;
    }

    _checkInScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      homeController.refreshHomeData(),
      astrologyController.refreshExperts(),
      redeemController.fetchRedemptionHistory(),
      Provider.of<ProfileViewModel>(context, listen: false).refreshProfile(),
    ]);
    if (mounted) {
      context.read<NotificationBloc>().add(RefreshUnreadCount());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(top: padding.top),
        child: RefreshIndicator(
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
              // _buildSearchBar(),
              _buildTitle(),
              _buildMainBanner(screenWidth),
              _buildFeatureGrid(isTablet),
              _buildSpiritualCheckIn(),
              _buildKarmaDashboard(),
              _buildExpertConnect(screenWidth),
              _buildMuhuratSection(),
              if (!Platform.isIOS) _buildRemediesSection(screenWidth),
              // _buildSelfDiscoverySection(),
              _buildSpiritualToolsSection(screenWidth),
              _buildSankalpTracker(),
              _buildSwapnaDecoder(),
              _buildComingSoonProjectsSection(screenWidth),
              _buildSponsorsSection(screenWidth),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<ProfileViewModel>(
              builder: (context, profileVM, child) {
                final fullName = profileVM.profile?.profile?.name ?? " ";
                final firstName = fullName.trim().split(' ').first;
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "namaste".tr + " ",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: firstName,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD4AF37),
                          fontSize: 15.sp,
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
                // Notification Bell with dynamic badge
                GestureDetector(
                  onTap: () {
                    _unfocusAll();
                    Get.toNamed(AppConstants.routeNotifications);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/notification.svg',
                          color: Colors.white,
                        ),
                      ),
                      // Dynamic Badge
                      BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, state) {
                          debugPrint("HOME BADGE COUNT: ${state.unreadCount}");
                          if (state.unreadCount <= 0) {
                            return const SizedBox.shrink();
                          }
                          return Positioned(
                            top: -2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Center(
                                child: Text(
                                  state.unreadCount > 9 ? '9+' : state.unreadCount.toString(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Profile Avatar with gold ring
                GestureDetector(
                  onTap: () async {
                    _unfocusAll();
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
                        radius: 5.w,
                        borderWidth: 1.5,
                        borderColor: AppTheme.primaryGold,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSearchBar() {
  //   final borderRadius = BorderRadius.circular(16);

  //   return SliverToBoxAdapter(
  //     child: Padding(
  //       padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
  //       child: Container(
  //         height: 6.h,
  //         decoration: BoxDecoration(borderRadius: borderRadius),
  //         child: TextField(
  //           focusNode: _searchFocusNode,
  //           style: TextStyle(color: Colors.white, fontSize: 11.sp),
  //           textAlignVertical: TextAlignVertical.center,
  //           decoration: InputDecoration(
  //             filled: true,
  //             fillColor: const Color(0xFF0A0A0A), // 👈 DARK COLOR
  //             hintText: "Search rituals, puja, astrologers",
  //             hintStyle: GoogleFonts.poppins(
  //               color: Colors.white.withOpacity(0.35),
  //               fontSize: 11.sp,
  //               fontWeight: FontWeight.w500,
  //             ),

  //             prefixIcon: Padding(
  //               padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.2.h),
  //               child: SvgPicture.asset(
  //                 'assets/icons/search.svg',
  //                 colorFilter: ColorFilter.mode(
  //                   Colors.white.withOpacity(0.4),
  //                   BlendMode.srcIn
  //                 ),
  //               ),
  //             ),
  //                           border: OutlineInputBorder(
  //               borderRadius: borderRadius,
  //               borderSide: BorderSide.none,
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: borderRadius,
  //               borderSide: BorderSide.none,
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: borderRadius,
  //               borderSide: const BorderSide(
  //                 color: Color(0xFFD4AF37),
  //                 width: 1.2,
  //               ),
  //             ),

  //             contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "BRAHMAKOSH",
                style: GoogleFonts.lora(
                  color: const Color(0xFFD4AF37),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Your Spiritual Operating System",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMainBanner(double screenWidth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildBannerItem(
                  title: "Rashmi",
                  role: "Spiritual Guide",
                  description: "Get guidance on astrology, puja, rituals & spiritual practice",
                  buttonText: "ASK SPIRITUAL GUIDE",
                  imageUrl: 'assets/icons/rashmi_new_avatar.png',
                  alignment: const Alignment(0, -0.6), // Pull Rashmi up slightly
                  onPressed: () {
                    _unfocusAll();
                    Get.to(
                      () => const AiGuideView(
                        deityName: "Rashmi",
                        subtitle: "Your Spiritual Guide",
                        backgroundImage: 'assets/icons/chat_bg_new.png',
                        characterImagePath: 'assets/icons/Rashmi_new_chat.png',
                        chatBackgroundImage: 'assets/icons/Rashmi_new_chat.png',
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildBannerItem(
                  title: "Talk to Krishna",
                  description: "Seek timeless wisdom from the Bhagavad Gita.",
                  buttonText: "START CONVERSATION",
                  imageUrl: 'assets/icons/Krishna_new_avatar.png',
                  alignment: Alignment.topCenter, // Keep Krishna as is
                  onPressed: () {
                    _unfocusAll();
                    Get.to(
                      () => const AiGuideView(
                        deityName: "Krishna",
                        subtitle: "Divine Cosmic Intelligence",
                        backgroundImage: 'assets/icons/chat_bg_new.png',
                        characterImagePath: 'assets/icons/krishna_neww.png',
                        chatBackgroundImage: 'assets/images/Krishna_chat.png',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildBannerItem({
    required String title,
    String? role,
    required String description,
    required String buttonText,
    required String imageUrl,
    required VoidCallback onPressed,
    Alignment alignment = Alignment.topCenter, // Added this
    bool isNetwork = false,
  }) {

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.20), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image part with gradient
          SizedBox(
            height: 22.h,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  isNetwork
                      ? Image.network(
                          ApiUrls.getFormattedImageUrl(imageUrl)!,
                          fit: BoxFit.cover,
                          alignment: alignment,
                        )
                      : Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          alignment: alignment,
                        ),
                  // Bottom gradient overlay to transition to black
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0F0F0F).withOpacity(0.6),
                            const Color(0xFF0F0F0F),
                          ],
                          stops: const [0.5, 0.85, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content part
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lora(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (role != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          "•",
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10.sp),
                        ),
                      ),
                      Text(
                        role,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD4AF37),
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 1.5.h),
                SizedBox(
                  width: double.infinity,
                  height: 4.5.h,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonBadge() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Coming Soon',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 6.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Small triangle pointer
        CustomPaint(
          size: const Size(6, 4),
          painter: TrianglePainter(),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    String title,
    String iconPath, {
    VoidCallback? onTap,
    bool showComingSoon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Card Background
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.01),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 5.h, bottom: 1.h, left: 1.w, right: 1.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Floating Icon
          Positioned(
            top: -1.h,
            child: Image.asset(
              iconPath,
              height: 7.5.h,
              fit: BoxFit.contain,
            ),
          ),
          // Badge
          if (showComingSoon)
            Positioned(
              top: -1.2.h,
              child: _buildComingSoonBadge(),
            ),
        ],
      ),
    );
  }



  Widget _buildFeatureGrid(bool isTablet) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 2.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 3.5.h, // Space for floating icons
          crossAxisSpacing: 3.w,
          childAspectRatio: 0.95,
        ),
        delegate: SliverChildListDelegate([
          _buildGridItem(
            "check_in".tr,
            "assets/icons/check_in.png",
            onTap: () {
              _unfocusAll();
              Get.toNamed(AppConstants.routeCheckIn);
            },
          ),
          _buildGridItem(
            "astrology".tr,
            "assets/icons/astrology.png",
            onTap: () {
              _unfocusAll();
              Get.toNamed(AppConstants.routeAstrologyDetails);
            },
          ),
          _buildGridItem(
            "expert_connect".tr,
            "assets/icons/expert_connect.png",
            onTap: () {
              _unfocusAll();
              Provider.of<DashboardViewModel>(context, listen: false).changeTab(3);
            },
          ),
          _buildGridItem(
            "Reports",
            "assets/icons/reports.png",
            showComingSoon: false,
            onTap: () {
              _unfocusAll();
              Get.dialog(const ComingSoonPopup(feature: "Reports"));
            },
          ),
          _buildGridItem(
            "remedies".tr,
            "assets/icons/remedies.png",
            onTap: () {
              _unfocusAll();
              Provider.of<DashboardViewModel>(context, listen: false).changeTab(4);
            },
          ),
          _buildGridItem(
            "sankalp_tracker".tr,
            "assets/icons/sankalptracker.png",
            onTap: () {
              _unfocusAll();
              Get.toNamed(AppConstants.routeSankalp);
            },
          ),
          _buildGridItem(
            "puja_vidhi".tr,
            "assets/icons/puja_vidhi.png",
            onTap: () {
              _unfocusAll();
              Get.toNamed(AppConstants.routePoojaList);
            },
          ),
          _buildGridItem(
            "Courses",
            "assets/icons/courses.png",
            showComingSoon: true,
            onTap: () {
              _unfocusAll();
              Get.dialog(const ComingSoonPopup(feature: "Courses"));
            },
          ),
        ]),
      ),
    );
  }


  // Placeholder methods for other sections
  Widget _buildSpiritualCheckIn() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFF111111), // Match dark background
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(
                      "are_you_spiritual".tr,
                      style: GoogleFonts.poppins(
                        // Cleaner look
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Text(
                  //   "${_selectedCheckInIndex + 1}/${_checkInActivities.length}",
                  //   style: GoogleFonts.poppins(
                  //     color: const Color(0xFFFFD447), // Brighter gold
                  //     fontSize: 11.sp,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 24),

              // Horizontal Activity List
              if (_isCheckInLoading && _checkInActivities.isEmpty)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD447)),
                )
              else
                SingleChildScrollView(
                  controller: _checkInScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(_checkInActivities.length, (index) {
                      final activity = _checkInActivities[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedCheckInIndex = index);
                            _scrollToSelectedCheckIn(index);
                          },
                          child: _buildActivityItem(
                            activity.title?.toLowerCase().tr ?? "",
                            _getActivityIconPath(activity.title ?? ""),
                            isSelected: _selectedCheckInIndex == index,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              SizedBox(height: 2.h),
              // The White Action Button
              SizedBox(
                width: 45.w,
                height: 4.5.h,
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
                    "check_in_now".tr,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
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
    _unfocusAll();
    if (_checkInActivities.isEmpty || _selectedCheckInIndex == -1) {
      Get.toNamed(AppConstants.routeCheckIn);
      return;
    }

    final activity = _checkInActivities[_selectedCheckInIndex];

    if (activity.title == 'Chanting') {
      Get.to(() => ChantingConfigurationView(chantingCategoryId: activity.id!));
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

  Widget _buildActivityItem(
    String title,
    String imagePath, {
    bool isSelected = false,
  }) {
    final double size =  20.w;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20.w,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: size,
              width: size,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4), // Set white background for all image cards
                borderRadius: BorderRadius.circular(16),
                // Clean gold border only when selected
                border: isSelected
                    ? Border.all(color: const Color(0xFFFFD447), width: 1)
                    : Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD447).withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              padding: const EdgeInsets.all(4), // Give uniform padding to keep image inside the borders nicely
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(imagePath, fit: BoxFit.contain), // Use contain prevent cropping
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 18.sp,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: isSelected ? 10.sp : 9.sp,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
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
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "karma_dashboard".tr,
                        style: GoogleFonts.poppins(
                          color: Color(0xff8E8E93),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _unfocusAll();
                          Get.toNamed(AppConstants.routeRedeem);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
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
                              ),
                            ],
                          ),
                          child: Text(
                            "redeem_cap".tr,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD4AF37),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      // Karma Points
                      Expanded(
                        child: _buildKarmaStat(
                          "karma_points".tr,
                          NumberFormat("#,###").format(karmaPoints),
                          iconPath: "assets/icons/star_rounded.svg",
                        ),
                      ),
                      _buildVerticalDivider(),
                      // Seva Done
                      Obx(() {
                        final completedCount = redeemController
                            .redemptionHistory
                            .where(
                              (item) =>
                                  item.status.toLowerCase() == 'completed',
                            )
                            .length;
                        return Expanded(
                          child: _buildKarmaStat(
                            "seva_done".tr,
                            completedCount.toString(),
                            iconPath: "assets/icons/support.svg",
                          ),
                        );
                      }),
                      _buildVerticalDivider(),
                      // Alignment
                      Expanded(
                        child: _buildKarmaStat(
                          "alignment".tr,
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
      height: 5.h,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
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
            fontSize: 7.5.sp,
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
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (iconPath != null) ...[
              const SizedBox(width: 4),
              SvgPicture.asset(
                iconPath,
                width: 4.w,
                height: 4.w,
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
                    "expert_connect_title".tr,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _unfocusAll();
                      Provider.of<DashboardViewModel>(
                        context,
                        listen: false,
                      ).changeTab(3);
                    },
                    child: Text(
                      "view_all".tr,
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
                return SizedBox(
                  height: 24.h,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                );
              }
              if (experts.isEmpty) {
                return SizedBox(
                   height: 24.h,
                  child: Center(
                    child: Text(
                      "no_experts".tr,
                      style: GoogleFonts.lora(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 24.h,
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
      onTap: () {
        _unfocusAll();
        astrologyController.navigateToProfile(expert);
      },
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
                      color: Color(0xFFD4AF37), // Border color
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 6.w,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    backgroundImage: () {
                      if (expert.profilePhoto == null ||
                          expert.profilePhoto!.isEmpty) {
                        return const AssetImage('assets/images/logo.png')
                            as ImageProvider;
                      }
                      final photo = expert.profilePhoto!;
                      if (photo.startsWith('file://')) {
                        return FileImage(
                          File(photo.replaceFirst('file://', '')),
                        );
                      }
                      if (photo.startsWith('/')) {
                        return FileImage(File(photo));
                      }
                      final formattedUrl = ApiUrls.getFormattedImageUrl(photo);
                      if (formattedUrl == null) {
                        return const AssetImage('assets/images/logo.png')
                            as ImageProvider;
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
                            child: FutureBuilder<String>(
                              future: TranslateHelper.translate(expert.name ?? "Expert"),
                              initialData: expert.name ?? "Expert",
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? "Expert",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOnline ? "online".tr : "offline".tr,
                              style: GoogleFonts.poppins(
                                color: isOnline ? Colors.green : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<String>(
                        future: TranslateHelper.translate(expert.expertise ?? "Astrology"),
                        initialData: expert.expertise ?? "Astrology",
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? "Astrology",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        },
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF2C2C2E,
                    ), // Subtle dark grey background
                    borderRadius: BorderRadius.circular(20), // Pill shape
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Shrinks container to content size
                    children: [
                      Text(
                        "${expert.rating ?? 0.0}",
                        style: GoogleFonts.poppins(
                          // Switched to Poppins for that clean look
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4), // Gap between text and star
                      const Icon(
                        Icons
                            .star_rounded, // Rounded version looks more like the image
                        color: Color(0xFFFFD447), // Brighter yellow/gold
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 0,
                  child: GestureDetector(
                    onTap: () {
                      _unfocusAll();
                      astrologyController.startChat(expert);
                    },
                    child: _buildExpertActionButton("chat".tr),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 0,
                  child: GestureDetector(
                    onTap: () {
                      _unfocusAll();
                      astrologyController.navigateToProfile(expert);
                    },
                    child: _buildExpertActionButton("talk".tr, isPrimary: true),
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
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFD4AF37) : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: isPrimary
            ? null
            : Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                width: 1,
              ),
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
                    "todays_muhurat".tr,
                    style: GoogleFonts.poppins(
                      color: Color(0xff8E8E93),
                      fontSize: 13.sp,
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
                      "sunrise_sunset".tr,
                      formatTimeToAMPM(
                        basic?.sunrise,
                      ), // formats to e.g. "6:24 AM"
                      formatTimeToAMPM(
                        basic?.sunset,
                      ), // formats to e.g. "6:15 PM"
                      Icons.wb_sunny_outlined,
                      const Color(0xFFFF9933),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMuhuratTimeCard(
                      "moonrise_moonset".tr,
                      // Logic for Moonrise
                      formatTimeToAMPM(
                        (basic?.moonrise?.isNotEmpty ?? false)
                            ? basic?.moonrise
                            : advanced?.moonrise,
                      ),
                      // Logic for Moonset
                      formatTimeToAMPM(
                        (basic?.moonset?.isNotEmpty ?? false)
                            ? basic?.moonset
                            : advanced?.moonset,
                      ),
                      Icons.nightlight_round_outlined,
                      const Color(
                        0xFF8A9DFF,
                      ), // Updated to the softer blue from your image
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "personalized_astrology_muhurat".tr,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailedMuhuratCard(
                "abhijit_muhurat".tr,
                "${formatTimeToAMPM(advanced?.abhijitMuhurta?.start)} - ${formatTimeToAMPM(advanced?.abhijitMuhurta?.end)}",
                "highly_auspicious".tr,
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
                      "rahu_kaal".tr,
                      "${formatTimeToAMPM(advanced?.rahukaal?.start)} - ${formatTimeToAMPM(advanced?.rahukaal?.end)}",
                      "avoid_tag".tr,
                      Colors.red,
                    ),
                    _buildMuhuratRow(
                      "tithi".tr,
                      basic?.tithi ?? "Loading...",
                      advanced?.panchang?.tithi?.endTime != null
                          ? "until".tr + " ${(advanced!.panchang!.tithi!.endTime!.hour! % 24).toString().padLeft(2, '0')}:${advanced!.panchang!.tithi!.endTime!.minute.toString().padLeft(2, '0')}"
                          : (basic?.paksha ?? ""),
                      const Color(0xFFD4AF37),
                    ),
                    _buildMuhuratRow(
                      "nakshatra".tr,
                      basic?.nakshatra ?? "--",
                      advanced?.panchang?.nakshatra?.endTime != null
                          ? "until".tr + " ${(advanced!.panchang!.nakshatra!.endTime!.hour! % 24).toString().padLeft(2, '0')}:${advanced!.panchang!.nakshatra!.endTime!.minute.toString().padLeft(2, '0')}"
                          : "",
                      const Color(0xFFD4AF37),
                    ),
                    _buildMuhuratRow(
                      "hindu_month".tr,
                      advanced?.hinduMaah?.purnimanta ?? "--",
                      "",
                      const Color(0xFFD4AF37),
                    ),
                    _buildMuhuratRow(
                      "ritu".tr,
                      basic?.ritu ?? (advanced?.ritu ?? "--"),
                      "",
                      const Color(0xFFD4AF37),
                    ),
                    _buildMuhuratRow(
                      "direction".tr,
                      basic?.dishaShool ?? (advanced?.dishaShool ?? "--"),
                      "",
                      Colors.orange,
                    ),
                    _buildMuhuratRow(
                      "sun_moon_sign".tr,
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
                  onTap: () {
                    _unfocusAll();
                    Get.toNamed(AppConstants.routePanchang);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xff1C1C1E),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.17,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "view_todays_panchang".tr,
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

  Widget _buildMuhuratTimeCard(
    String label,
    String time1,
    String time2,
    IconData icon,
    Color themeColor,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
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
              Icon(icon, color: themeColor, size: 8.w),
            ],
          ),
          const SizedBox(height: 16),
          // Title Text
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.4),
              fontSize: 7.5.sp,
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
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Icon(
                  Icons.circle,
                  color: Colors.white.withOpacity(0.4),
                  size: 1.w,
                ),
              ),
              Text(
                time2,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9.sp,
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
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFD4AF37).withOpacity(0.20),
          width: 0.5,
        ),
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
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 9.sp,
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
              fontSize: 15.sp,
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
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tagColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (tag.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  tag,
                  style: GoogleFonts.poppins(
                    color: tagColor,
                    fontSize: 9.sp,
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
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSs1hx27RUdRVHpThGV_4DN3712p8UCKtndeA&s",
      },
      {
        "title": "Yellow Sapphire",
        "subtitle": "For wealth, prosperity & planet Jupiter...",
        "price": "15,500",
        "image":
            "https://www.shivaago.com/wp-content/uploads/2021/03/IMG_20210307_160026_compress32-600x486.jpg",
      },
    ];

    final goodToHaveRemedies = [
      {
        "title": "Sphatik Mala",
        "subtitle": "For peace, concentration & planet Moon...",
        "price": "850",
        "image":
            "https://ik.imagekit.io/gemsonline/wp-content/uploads/2026/01/Spetics-mala-3-scaled.jpg",
      },
      {
        "title": "Gomati Chakra",
        "subtitle": "For protection, prosperity and bringing luck...",
        "price": "150",
        "image":
            "https://m.media-amazon.com/images/I/A1QIkWYHngL._AC_UY1100_.jpg",
      },
    ];

    final displayedRemedies = _selectedRemedyTab == "must_have"
        ? mustHaveRemedies
        : goodToHaveRemedies;

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
                "personalized_remedies".tr,
                style: GoogleFonts.poppins(
                  color: Color(0xff8E8E93),
                  fontSize: 13.sp,
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
                        "must_have".tr,
                        isSelected: _selectedRemedyTab == "must_have",
                        onTap: () {
                          setState(() {
                            _selectedRemedyTab = "must_have";
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        "good_to_have".tr,
                        isSelected: _selectedRemedyTab == "good_to_have",
                        onTap: () {
                          setState(() {
                            _selectedRemedyTab = "good_to_have";
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
              height: 35.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: displayedRemedies.length,
                itemBuilder: (context, index) {
                  final remedy = displayedRemedies[index];
                  return FutureBuilder<List<String>>(
                    future: Future.wait([
                      TranslateHelper.translate(remedy["title"]!),
                      TranslateHelper.translate(remedy["subtitle"]!),
                    ]),
                    initialData: [remedy["title"]!, remedy["subtitle"]!],
                    builder: (context, snapshot) {
                      final translated = snapshot.data!;
                      return _buildProductCard(
                        translated[0],
                        translated[1],
                        remedy["price"]!,
                        remedy["image"]!,
                        screenWidth,
                        isNetwork: true,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.25.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
            fontSize: 9.75.sp,
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
              height: 17.5.h,
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
                  : Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10.5.sp,
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
              fontSize: 8.25.sp,
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
                  fontSize: 11.25.sp,
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
                  "shop_btn".tr,
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

  Widget _buildSpiritualToolsSection(double screenWidth) {
    final tools = [
      {
        "title": "Remedies",
        "desc": "Protect your energy & remove negativity",
        "icon": "assets/icons/remedies.png",
        "onTap": () {
          _unfocusAll();
          Provider.of<DashboardViewModel>(context, listen: false).changeTab(4);
        },
      },
      {
        "title": "Puja Vidhi",
        "desc": "Perform rituals with step-by-step guidance",
        "icon": "assets/icons/puja_vidhi.png",
        "onTap": () {
          _unfocusAll();
          Get.toNamed(AppConstants.routePoojaList);
        },
      },
      {
        "title": "Reports",
        "desc": "Get deep insights into your life's path",
        "icon": "assets/icons/reports.png",
        "isComingSoon": true,
        "onTap": () {
          _unfocusAll();
          Get.dialog(const ComingSoonPopup(feature: "Reports"));
        },
      },
      {
        "title": "Courses",
        "desc": "Learn sacred wisdom from experts",
        "icon": "assets/icons/courses.png",
        "isComingSoon": true,
        "onTap": () {
          _unfocusAll();
          Get.dialog(const ComingSoonPopup(feature: "Courses"));
        },
      },
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "SPIRITUAL TOOLS",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 20.h, // Adjusted height for more breathing room
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return _buildSpiritualToolCard(
                    tool["title"] as String,
                    tool["desc"] as String,
                    tool["icon"] as String,
                    screenWidth,
                    tool["onTap"] as VoidCallback,
                    isComingSoon: tool["isComingSoon"] as bool? ?? false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiritualToolCard(
    String title,
    String desc,
    String iconPath,
    double screenWidth,
    VoidCallback onTap, {
    bool isComingSoon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.72, // Responsive width showing partial next card
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Image.asset(
                  iconPath,
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 14),
                // Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: TranslateHelper.translate(pooja.pujaName ?? "Unknown Puja"),
                        initialData: pooja.pujaName ?? "Unknown Puja",
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? "Unknown Puja",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lora(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      FutureBuilder<String>(
                        future: TranslateHelper.translate(pooja.subcategory ?? pooja.category ?? "Ritual"),
                        initialData: pooja.subcategory ?? pooja.category ?? "Ritual",
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? "Ritual",
                            style: GoogleFonts.lora(
                              color: const Color(0xFFD4AF37),
                              fontSize: 7.5.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Explore Button
            SizedBox(
              width: double.infinity,
              height: 5.h, // Increased height to prevent text clipping
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: EdgeInsets.zero, // Clear default padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  "EXPLORE",
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    height: 1.0, // Ensures text fits vertically
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSankalpTracker() {
    return BlocBuilder<SankalpBloc, SankalpState>(
      builder: (context, state) {
        List<UserSankalpModel> activeSankalps = [];
        double avgProgress = 0;
        int activeCount = 0;

        if (state is SankalpLoaded) {
          activeSankalps = state.userSankalps
              .where((s) => s.status == 'active')
              .toList();
          
          if (activeSankalps.isNotEmpty) {
            double totalProgressSum = 0;
            for (var us in activeSankalps) {
              final completed = us.dailyReports.where((r) => r.status == 'yes').length;
              totalProgressSum += us.totalDays > 0 ? (completed / us.totalDays) : 0;
            }
            avgProgress = totalProgressSum / activeSankalps.length;
            activeCount = activeSankalps.length;
          }
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SANKALP TRACKER",
                      style: GoogleFonts.poppins(
                        color: const Color(0xff8E8E93),
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (activeSankalps.isNotEmpty)
                    GestureDetector(
                      onTap: () => Get.to(() => const SankalpScreen()),
                      child: Text(
                        "View All",
                        style: GoogleFonts.poppins(
                          color: AppTheme.primaryGold,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
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
                                  activeCount > 0 ? "Daily Spiritual Progress" : "No Active Sankalp",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeCount > 0 
                                    ? "Tracking $activeCount active spiritual habits."
                                    : "Start a new Sankalp to track your spiritual journey.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 9.75.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
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
                              width: 8.w,
                              height: 8.w,
                            ),
                          ),
                        ],
                      ),
                      
                      if (activeSankalps.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "OVERALL PROGRESS",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "${(avgProgress * 100).toInt()}%",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: avgProgress.clamp(0.0, 1.0),
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGold.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTrackSankalpButton(),
                      ] else ...[
                        const SizedBox(height: 20),
                        _buildTrackSankalpButton(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackSankalpButton() {
    return SizedBox(
      width: double.infinity,
      height: 5.5.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: () {
          _unfocusAll();
          Get.to(() => const SankalpScreen());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 22,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              "TRACK YOUR SANKALP",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                color: Colors.black,
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
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "swapna_decoder_title".tr,
              style: GoogleFonts.poppins(
                color: const Color(0xff8E8E93),
                fontSize: 13.5.sp,
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
                          size: 8.w,
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
                                    "decode_your_dream".tr,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // go_tab.svg icon at top right
                                GestureDetector(
                                  onTap: () {
                                    _unfocusAll();
                                    Get.toNamed(AppConstants.routeSwapnaDecoder);
                                  },
                                  child: SvgPicture.asset(
                                    'assets/icons/go_tab.svg',
                                    width: 24,
                                    height: 24,
                                    color: Color(0xFFD4AF37),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "decode_dream_msg".tr,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 9.75.sp,
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
                    height: 5.5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      focusNode: _swapnaFocusNode,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10.5.sp,
                      ),
                      decoration: InputDecoration(
                        fillColor: const Color(0xFF0A0A0A),
                        filled: true,
                        hintText: "dream_hint".tr,
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white30,
                          fontSize: 10.5.sp,
                        ),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                _unfocusAll();
                                Get.toNamed(AppConstants.routeSwapnaDecoder);
                              },
                              icon: Icon(
                                Icons.send_rounded,
                                color: Color(0xFFD4AF37),
                                size: 5.5.w,
                              ),
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

  Widget _buildComingSoonProjectsSection(double screenWidth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Coming Soon Projects",
                style: GoogleFonts.lora(
                  color: const Color(0xFFD4AF37),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Building spiritual ecosystem for growth and learning...",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10.sp,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 42.h,
              child: PageView.builder(
                controller: _comingSoonPageController,
                itemCount: _comingSoonProjects.length,
                onPageChanged: (index) {
                  setState(() {
                    _comingSoonPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildComingSoonProjectCard(
                    _comingSoonProjects[index],
                    screenWidth,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_comingSoonProjects.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _comingSoonPageIndex == index ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _comingSoonPageIndex == index
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonProjectCard(
    Map<String, String> project,
    double screenWidth,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image
            Image.asset(
              project["image"]!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Dark Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    project["title"]!,
                    style: GoogleFonts.lora(
                      color: Colors.white,
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project["subtitle"]!,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 9.sp,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Coming Soon Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Coming Soon",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildSelfDiscoverySection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Text(
              "self_discovery_title".tr,
              style: GoogleFonts.lora(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10.5.sp,
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
                      _discoveryTabs[index].toLowerCase().tr,
                      style: GoogleFonts.lora(
                        color: isSelected
                            ? Colors.black
                            : Colors.white.withOpacity(0.6),
                        fontSize: 8.25.sp,
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
                        fontSize: 9.75.sp,
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
                "our_sponsors".tr,
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10.5.sp,
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

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

