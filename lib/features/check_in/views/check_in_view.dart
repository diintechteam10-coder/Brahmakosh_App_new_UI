import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/check_in/views/prayer_configuration_view.dart';
import 'package:brahmakosh/features/check_in/views/chanting_configuration_view.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brahmakosh/features/check_in/blocs/check_in/check_in_bloc.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/common/utils.dart';

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:brahmakosh/features/check_in/views/spiritual_stats_screen.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';

class CheckInView extends StatefulWidget {
  final ScrollController? scrollController;

  const CheckInView({super.key, this.scrollController});

  @override
  State<CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<CheckInView>
    with TickerProviderStateMixin {
  // final CheckInController controller = Get.put(CheckInController()); // Removed
  int _currentStatIndex = 0;
  Timer? _timer;
  final Map<String, String> _dynamicTranslations = {};
  String _lastLang = 'en';

  @override
  void initState() {
    super.initState();
    _startCarousel();
  }

  void _startCarousel() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentStatIndex = (_currentStatIndex + 1) % 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(String? iso) {
    if (iso == null) return "";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (e) {
      return "";
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return "";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return "";
    }
  }

  Future<void> _translateAllContents(Data data) async {
    final currentLang = Get.locale?.languageCode ?? 'en';
    if (currentLang == 'en') {
      if (_dynamicTranslations.isNotEmpty) {
        setState(() {
          _dynamicTranslations.clear();
          _lastLang = 'en';
        });
      }
      return;
    }

    final Set<String> toTranslate = {};
    
    // Activity titles
    if (data.activities != null) {
      for (var act in data.activities!) {
        if (act.title != null) toTranslate.add(act.title!);
      }
    }

    // Recent activity titles
    if (data.recentActivities != null) {
      for (var act in data.recentActivities!) {
        if (act.title != null) toTranslate.add(act.title!);
      }
    }

    // Motivation text
    if (data.motivation?.text != null) {
      toTranslate.add(data.motivation!.text!);
    }

    if (toTranslate.isEmpty) return;

    final list = toTranslate.toList();
    final results = await TranslateHelper.translateList(list);

    bool changed = false;
    for (int i = 0; i < list.length; i++) {
      if (_dynamicTranslations[list[i]] != results[i]) {
        _dynamicTranslations[list[i]] = results[i];
        changed = true;
      }
    }

    if (changed || _lastLang != currentLang) {
      if (mounted) {
        setState(() {
          _lastLang = currentLang;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CheckInBloc(repository: SpiritualRepository())..add(LoadCheckIn()),
      child: BlocConsumer<CheckInBloc, CheckInState>(
        listener: (context, state) {
          if (state is CheckInNavigationAction) {
            // Dismiss loader
            if (Get.isDialogOpen == true) Get.back();

            if (state.arguments != null) {
              Get.toNamed(state.route, arguments: state.arguments);
            } else {
              Get.toNamed(state.route);
            }
          } else if (state is CheckInNavigationLoading) {
            // Show Custom White Loader
            Get.dialog(
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
              barrierDismissible: false,
            );
          } else if (state is CheckInError) {
            if (Get.isDialogOpen == true) Get.back();
            Utils.showToast(state.message);
          } else if (state is CheckInLoaded) {
            // Close any lingering dialogs if needed (e.g. from refresh)
            if (Get.isDialogOpen == true) Get.back();
            _translateAllContents(state.data);
          }

        },
        builder: (context, state) {
          if (state is CheckInLoading) {
            return const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is CheckInError) {
            return SafeArea(child: Center(child: Text(state.message)));
          }

          Data? data;
          if (state is CheckInLoaded) {
            data = state.data;
          } else if (state is CheckInNavigationLoading) {
            data = state.previousState.data;
          } else if (state is CheckInNavigationAction) {
            data = state.previousState.data;
          }

          if (data == null) {
            // Fallback or Initial
            return SafeArea(child: Center(child: Text("loading".tr)));
          }

          final finalData = data;

          return Scaffold(
            backgroundColor: Colors.black, // Dark Theme Background
            body: SafeArea(
              bottom: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black, // Dark Theme Background
                ),
                child: RefreshIndicator(
                  color: const Color(0xff7B4A12),
                  onRefresh: () async {
                    final completer = Completer<void>();
                    context.read<CheckInBloc>().add(RefreshCheckIn(completer));
                    return completer.future;
                  },
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        // Header row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    Get.to(() => const SpiritualStatsScreen());
                                  },
                                ),
                              ),
                                Text(
                                  'are_you_spiritual'.tr,
                                style: GoogleFonts.lora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(
                                    0xFFD4AF37,
                                  ), // Primary Gold
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.share,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    if (data != null) {
                                      _shareCheckInDetails(context, data);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Main title & Subtitle
                        Text(
                          'daily_checkin_title'.tr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lora(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'daily_checkin_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white70,
                            letterSpacing: 0.2,
                          ),
                        ),

                        // Check-In Options (2x2 Grid)
                        if (finalData.activities != null &&
                            finalData.activities!.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 10,
                                    childAspectRatio:
                                        0.82, // Balanced for card + text
                                  ),
                              padding: EdgeInsets.zero,
                              itemCount: finalData.activities!.length,
                              itemBuilder: (context, index) {
                                final activities = finalData.activities!;
                                final activity = activities[index];
                                return _card(
                                  image: activity.image,
                                  title: (_dynamicTranslations[activity.title] ?? activity.title ?? '').toUpperCase(),
                                  onTap: () {
                                    if (activity.route != null) {
                                      final title = activity.title ?? '';
                                      if (title == 'Chanting') {
                                        Get.to(
                                          () => ChantingConfigurationView(
                                            chantingCategoryId: activity.id!,
                                          ),
                                        );
                                      } else if (title == 'Prayer' &&
                                          activity.id != null) {
                                        Get.to(
                                          () => PrayerConfigurationView(
                                            prayerCategoryId: activity.id!,
                                          ),
                                        );
                                      } else if (activity.id != null) {
                                        context.read<CheckInBloc>().add(
                                          SelectActivity(
                                            activityId: activity.id!,
                                            route: AppConstants
                                                .routeSpiritualConfiguration,
                                            title: activity.title,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (finalData.stats != null) ...[
                          RepaintBoundary(
                            child: _buildOverviewStats(
                              finalData.stats!,
                              finalData.recentActivities,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Category Progress
                        if (finalData.categoryStats != null) ...[
                          RepaintBoundary(
                            child: _buildCategoryStats(
                              finalData.categoryStats!,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Recent Activities
                        if (finalData.recentActivities != null &&
                            finalData.recentActivities!.isNotEmpty)
                          RepaintBoundary(
                            child: _buildRecentActivities(
                              finalData.recentActivities!,
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Karma & Motivation
                        Column(
                          children: [
                            if (finalData.motivation?.emoji != null)
                              Text(
                                finalData.motivation!.emoji!,
                                style: const TextStyle(fontSize: 40),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              'earn_karma_points'.tr,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD4AF37),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (finalData.motivation?.text != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  finalData.motivation!.text!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 125),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }, // Builder
      ), // Consumer
    ); // Provider
  }

  Widget _buildOverviewStats(
    Stats stats,
    List<RecentActivities>? recentActivities,
  ) {
    String lastCheckInText = 'no_recent_checkins'.tr;
    if (recentActivities != null && recentActivities.isNotEmpty) {
      // Format as "Today - 7:32 PM" if it's today, else standard format
      final dt = DateTime.parse(recentActivities.first.createdAt!).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        lastCheckInText = '${"today".tr} - ${DateFormat('h:mm a').format(dt)}';
      } else {
        lastCheckInText = DateFormat('MMM d - h:mm a').format(dt);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E), // Dark grey background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'last_checkin_cap'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastCheckInText,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: _currentStatIndex == 0
                      ? Row(
                          key: const ValueKey<int>(0),
                          children: [
                            Text(
                              '${stats.points ?? 0}',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.stars,
                              color: Color(0xFFD4AF37),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'karma_points'.tr,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey<int>(1),
                          children: [
                            Text(
                              '${stats.sessions ?? 0}',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFFD4AF37),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'total_checkins'.tr,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppConstants.routeRedeem);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8C265), // Soft Gold
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'redeem_cap'.tr,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareCheckInDetails(BuildContext context, Data data) {
    if (data.stats == null) {
      Utils.showToast("no_recent_checkins".tr);
      return;
    }
    const String playStoreUrl =
        "https://play.google.com/store/apps/details?id=com.brahmakosh.app&pcampaignid=web_share";

    const String appStoreUrl =
        "https://apps.apple.com/in/app/brahmakosh/id6759043110";

    final stats = data.stats!;
    final recent =
        (data.recentActivities != null && data.recentActivities!.isNotEmpty)
        ? data.recentActivities!.first
        : null;

    String shareMessage = "share_stats_msg".tr + "\n\n";
    shareMessage += "my_progress_share".tr + "\n";
    shareMessage += "${"total_sessions_share".tr} ${stats.sessions ?? 0}\n";
    shareMessage += "${"karma_points_share".tr} ${stats.points ?? 0}\n";
    if (recent != null) {
      shareMessage += "${"last_activity_share".tr} ${recent.title ?? ''}\n";
    }
    shareMessage += "join_me_share".tr;
    shareMessage += "Android:\n$playStoreUrl\n\n";
    shareMessage += "iOS:\n$appStoreUrl\n\n";
    shareMessage += "#Brahmakosh #Spirituality";
    final box = context.findRenderObject() as RenderBox?;

    Share.share(
      shareMessage,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _buildCategoryStats(CategoryStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(
            0xFF141414,
          ), // Dark grey background like recent activities/last check-in
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Table Header
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'your_progress'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'sessions_cap'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'time_cap'.tr,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (stats.meditation != null)
              _categoryRow('meditation'.tr, stats.meditation!),
            if (stats.chanting != null) ...[
              const Divider(color: Colors.white12, height: 1),
              _categoryRow('chanting'.tr, stats.chanting!),
            ],
            if (stats.prayer != null) ...[
              const Divider(color: Colors.white12, height: 1),
              _categoryRow('prayer'.tr, stats.prayer!),
            ],
            if (stats.silence != null) ...[
              const Divider(color: Colors.white12, height: 1),
              _categoryRow('silence'.tr, stats.silence!),
            ],
            if (stats.bonus != null) ...[
              const Divider(color: Colors.white12, height: 1),
              _bonusRedemptionRow(
                'bonus'.tr,
                '${"bonuses_label".trParams({'count': '${stats.bonus!.count}'})} • ${"points_label".trParams({'count': '${stats.bonus!.totalBonusPoints}'})}',
              ),
            ],
            if (stats.redemption != null) ...[
              const Divider(color: Colors.white12, height: 1),
              _bonusRedemptionRow(
                'redemption'.tr,
                '${"redemptions_label".trParams({'count': '${stats.redemption!.count}'})} • ${"points_label".trParams({'count': '${stats.redemption!.totalRedeemPoints}'})}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bonusRedemptionRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              subtitle,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(String title, CategoryDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${detail.sessions}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${detail.minutes} ${"mins_short".tr}',
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(List<RecentActivities> activities) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'recent_activities_cap'.tr,
            style: GoogleFonts.lora(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = activities[index];
              final bool isComplete = activity.status == 'completed';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414), // Dark grey background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getActivityIcon(activity.type),
                        size: 20,
                        color: isComplete
                            ? const Color(0xFF2ECC71)
                            : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dynamicTranslations[activity.title] ?? activity.title ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_formatDate(activity.createdAt)} ${_formatTime(activity.createdAt)}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (activity.karmaPoints != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isComplete
                                  ? const Color(
                                      0xFFD4AF37,
                                    ).withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${activity.karmaPoints} ${'karma'.tr}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isComplete
                                    ? const Color(0xFFD4AF37)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          isComplete ? 'completed'.tr : 'incomplete'.tr,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isComplete
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE74C3C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'meditation':
        return Icons.self_improvement;
      case 'chanting':
        return Icons.music_note;
      case 'prayer':
        return Icons.volunteer_activism;
      case 'silence':
        return Icons.do_not_disturb_on;
      default:
        return Icons.spa;
    }
  }

  Widget _card({
    String? image,
    required String title,
    required VoidCallback onTap,
  }) {
    String formattedTitle = title
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  24,
                ), // Increased slightly for better look
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    spreadRadius: 1,
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Builder(
                      builder: (context) {
                        final titleLower = title.toLowerCase();
                        String? localAsset;
                        if (titleLower.contains('chanting')) {
                          localAsset = 'assets/icons/chanting.png';
                        } else if (titleLower.contains('meditation')) {
                          localAsset = 'assets/icons/meditation.png';
                        } else if (titleLower.contains('prayer')) {
                          localAsset = 'assets/icons/prayer.png';
                        } else if (titleLower.contains('silence')) {
                          localAsset = 'assets/icons/silence.png';
                        }

                        if (localAsset != null) {
                          return Container(
                            color: const Color(0xFF141414),
                            child: Image.asset(
                              localAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          );
                        } else if (image != null && image.isNotEmpty) {
                          return CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFF141414),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFF141414),
                              child: const Icon(
                                Icons.error,
                                color: Colors.white24,
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            color: const Color(0xFF141414),
                            child: const Icon(
                              Icons.spa,
                              color: Color(0xFFD4AF37),
                              size: 40,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  // Border overlay to ensure it's never clipped
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD4AF37), // Solid gold
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formattedTitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
