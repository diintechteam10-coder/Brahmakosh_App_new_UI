import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';
import '../controllers/check_in_controller.dart';

import 'dart:async';

class CheckInView extends StatefulWidget {
  const CheckInView({super.key});

  @override
  State<CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<CheckInView> {
  final CheckInController controller = Get.put(CheckInController());
  int _currentStatIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCarousel();
  }

  void _startCarousel() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffFFFDF8), Color(0xffFFF2D9), Color(0xffFFE4B5)],
            ),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = controller.checkInData.value;
            if (data == null) {
              return const Center(child: Text("No data available"));
            }

            return Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.history,
                          color: Color(0xff7B4A12),
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        'BRAHMAKOSH',
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: const Color(0xff7B4A12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Color(0xff7B4A12)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        // Main title
                        Text(
                          '#AreYouSpiritual',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff7B4A12),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Subtitle
                        Text(
                          'Take a moment for yourself',
                          style: GoogleFonts.lora(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        // ───────────────────────────────────────────────
                        // CHECK-IN OPTIONS SECTION (only if activities exist)
                        if (data.activities != null &&
                            data.activities!.isNotEmpty) ...[
                          const SizedBox(height: 16),

                          Text(
                            'CHECK-IN OPTIONS',
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff7B4A12),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 56),
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: data.activities!.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    childAspectRatio: 1.0,
                                  ),
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final activity = data.activities![index];
                                return _card(
                                  image: activity.image,
                                  title: activity.title?.toUpperCase() ?? '',
                                  onTap: () {
                                    if (activity.route != null) {
                                      if (activity.title == 'Meditation') {
                                        Get.toNamed(
                                          AppConstants
                                              .routeSpiritualConfiguration,
                                          arguments: activity.id,
                                        );
                                      } else if (activity.title == 'Chanting') {
                                        Get.toNamed(
                                          AppConstants.routeMantraChanting,
                                        );
                                      } else {
                                        Get.toNamed(
                                          AppConstants
                                              .routeSpiritualConfiguration,
                                          arguments: activity.id,
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                        // ───────────────────────────────────────────────

                        // ───────────────────────────────────────────────

                        // Overview stats wrapper with header text
                        if (data.stats != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Text(
                                  'Last Check-In 2.30PM 2.02.2026',
                                  style: GoogleFonts.lora(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff7B4A12),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'With Each Check-In Earn Karma Points',
                                  style: GoogleFonts.lora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff7B4A12),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildOverviewStats(data.stats!),
                          const SizedBox(height: 32),
                        ],

                        // Category progress
                        if (data.categoryStats != null) ...[
                          _buildCategoryStats(data.categoryStats!),
                          const SizedBox(height: 32),
                        ],

                        // Recent activities
                        if (data.recentActivities != null &&
                            data.recentActivities!.isNotEmpty) ...[
                          _buildRecentActivities(data.recentActivities!),
                          const SizedBox(height: 36),
                        ],

                        // Karma & motivation
                        if (data.motivation?.emoji != null)
                          Text(
                            data.motivation!.emoji!,
                            style: const TextStyle(fontSize: 40),
                          ),

                        const SizedBox(height: 12),

                        Text(
                          'Earn Karma points',
                          style: GoogleFonts.lora(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff7B4A12),
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (data.motivation?.text != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              data.motivation!.text!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontSize: 14,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        const SizedBox(height: 48), // final bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildOverviewStats(Stats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff7B4A12).withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentStatIndex),
                  child: _currentStatIndex == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //_statItem('Days', '${stats.days}'),
                            _statItem(
                              'Your Total Check-In',
                              '${stats.sessions}',
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //_statItem('Minutes', '${stats.minutes}'),
                            _statItem(
                              'Your Total Karma Points',
                              '${stats.points}',
                            ),
                          ],
                        ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 233, 130, 11),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Redeem',
                style: GoogleFonts.lora(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/brahmkosh_logo.jpeg',
              height: 28,
              width: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
            const SizedBox(width: 2),
            Text(
              value,
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff7B4A12),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.lora(fontSize: 14, color: const Color(0xff7B4A12)),
        ),
      ],
    );
  }

  Widget _buildCategoryStats(CategoryStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PROGRESS',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xff7B4A12),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xff7B4A12).withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                if (stats.meditation != null)
                  _categoryRow('Meditation', stats.meditation!),
                if (stats.chanting != null)
                  _categoryRow('Chanting', stats.chanting!),
                if (stats.prayer != null) _categoryRow('Prayer', stats.prayer!),
                if (stats.silence != null)
                  _categoryRow('Silence', stats.silence!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(String title, CategoryDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            '${detail.sessions} sessions • ${detail.minutes} mins',
            style: GoogleFonts.lora(fontSize: 13, color: Colors.black54),
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
            'RECENT ACTIVITIES',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xff7B4A12),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xff7B4A12).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff7B4A12).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getActivityIcon(activity.type),
                        size: 16,
                        color: const Color(0xff7B4A12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title ?? '',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            activity.createdAt != null
                                ? activity.createdAt!.split('T')[0]
                                : '',
                            style: GoogleFonts.lora(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (activity.karmaPoints != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffC9A24D).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${activity.karmaPoints} Karma',
                          style: GoogleFonts.lora(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff7B4A12),
                          ),
                        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            image != null
                ? CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.transparent,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.transparent,
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  )
                : Container(
                    color: const Color(0xff7B4A12).withOpacity(0.1),
                    child: const Icon(
                      Icons.spa,
                      color: Color(0xff7B4A12),
                      size: 40,
                    ),
                  ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // Title Text
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
