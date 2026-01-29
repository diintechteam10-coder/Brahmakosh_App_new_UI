import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';
import '../controllers/check_in_controller.dart';

class CheckInView extends StatelessWidget {
  CheckInView({super.key});

  final CheckInController controller = Get.put(CheckInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFDF8), Color(0xffFFF2D9), Color(0xffFFE4B5)],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = controller.checkInData.value;
            if (data == null) {
              return const Center(child: Text("No data available"));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Color(0xff7B4A12),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  /// 🔱 App Title
                  Text(
                    'BRAHMAKOSH',
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: const Color(0xff7B4A12),
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// #AreYouSpiritual
                  Text(
                    '#AreYouSpiritual',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff7B4A12),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Subtitle
                  Text(
                    'Take a moment for yourself',
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'CHECK-IN OPTIONS',
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff7B4A12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🧘 Cards Grid
                  if (data.activities != null && data.activities!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: data.activities!.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85, // Taller for image
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
                                  Get.toNamed(AppConstants.routeMeditate);
                                } else if (activity.title == 'Chanting') {
                                  Get.toNamed(AppConstants.routeMantraChanting);
                                } else {
                                  Get.toNamed(AppConstants.routeMeditate);
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 20),

                  /// 📊 Overview Stats
                  if (data.stats != null) _buildOverviewStats(data.stats!),

                  const SizedBox(height: 24),

                  /// 📈 Category Stats
                  if (data.categoryStats != null)
                    _buildCategoryStats(data.categoryStats!),

                  const SizedBox(height: 24),

                  /// 🕒 Recent Activities
                  if (data.recentActivities != null &&
                      data.recentActivities!.isNotEmpty)
                    _buildRecentActivities(data.recentActivities!),

                  const SizedBox(height: 24),

                  /// ⭐ Karma & Motivation
                  if (data.motivation?.emoji != null)
                    Text(
                      data.motivation!.emoji!,
                      style: const TextStyle(fontSize: 24),
                    ),

                  const SizedBox(height: 8),

                  Text(
                    'Earn Karma points',
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff7B4A12),
                    ),
                  ),

                  const SizedBox(height: 4),

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
                ],
              ),
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('Days', '${stats.days}'),
            _statItem('Sessions', '${stats.sessions}'),
            _statItem('Minutes', '${stats.minutes}'),
            _statItem('Points', '${stats.points}'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xff7B4A12),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lora(fontSize: 12, color: Colors.black54),
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
              color: Colors.white.withOpacity(0.8),
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
                  color: Colors.white.withOpacity(0.8),
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xff7B4A12).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image covers top 1/3rd (approx, adjusted by flex)
            Expanded(
              flex: 4,
              child: image != null
                  ? CachedNetworkImage(
                      imageUrl: image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
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
            ),
            // Text at bottom
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: const Color(0xff5D3A1A),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
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
