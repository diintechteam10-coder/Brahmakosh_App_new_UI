import 'package:brahmakosh/features/check_in/controllers/prayer_configuration_controller.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' show ImageFilter;

class PrayerSelectionViewV2 extends StatefulWidget {
  final String prayerCategoryId;
  const PrayerSelectionViewV2({super.key, required this.prayerCategoryId});

  @override
  State<PrayerSelectionViewV2> createState() => _PrayerSelectionViewV2State();
}

class _PrayerSelectionViewV2State extends State<PrayerSelectionViewV2> {
  final PrayerConfigurationController controller =
      Get.put(PrayerConfigurationController());
  String? _expandedCategoryId;

  @override
  void initState() {
    super.initState();
    controller.fetchConfigurations(widget.prayerCategoryId);
  }

  String _getEmoji(String text) {
    if (text.isEmpty) return '🙏';
    final characters = text.characters;
    if (characters.isEmpty) return '🙏';
    return characters.first;
  }

  String _getCleanTitle(String text) {
    if (text.isEmpty) return '';
    final firstChar = text.characters.first;
    // Only strip if first char is non-ASCII (emoji/symbol)
    if (firstChar.codeUnits.any((u) => u > 127)) {
      return text.replaceFirst(firstChar, '').trim();
    }
    return text.trim();
  }

  // Category icon/color mapping by keyword
  final Map<String, _CategoryStyle> _categoryStyles = {
    'Time': _CategoryStyle(
      icon: Icons.access_time_rounded,
      color: const Color(0xFFFFB74D),
    ),
    'Daily': _CategoryStyle(
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFFFD54F),
    ),
    'Gratitude': _CategoryStyle(
      icon: Icons.favorite_rounded,
      color: const Color(0xFFF06292),
    ),
    'Healing': _CategoryStyle(
      icon: Icons.self_improvement_rounded,
      color: const Color(0xFF81C784),
    ),
    'Devotional': _CategoryStyle(
      icon: Icons.local_florist_rounded,
      color: const Color(0xFFCE93D8),
    ),
    'Mantra': _CategoryStyle(
      icon: Icons.music_note_rounded,
      color: const Color(0xFF4DB6AC),
    ),
    'Others': _CategoryStyle(
      icon: Icons.spa_rounded,
      color: const Color(0xFFD4AF37),
    ),
  };

  _CategoryStyle _getStyle(String categoryName) {
    return _categoryStyles.entries
        .firstWhere(
          (e) => categoryName.toLowerCase().contains(e.key.toLowerCase()),
          orElse: () => _categoryStyles.entries.last,
        )
        .value;
  }

  void _showPrayerSheet(SpiritualConfiguration track) {
    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8.0 * anim1.value,
            sigmaY: 8.0 * anim1.value,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: PrayerBeginSheet(track: track),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIconButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Get.back(),
                  ),
                  _circleIconButton(
                    icon: Icons.more_vert_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      'Prayer',
                      style: GoogleFonts.lora(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Connect with divine energy',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Categories Label
                    Row(
                      children: [
                        Text(
                          'CATEGORIES',
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white38,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Container(
                            height: 0.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white24,
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Category List
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.allConfigurations.isEmpty) {
                        return SizedBox(
                          height: 30.h,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        );
                      }

                      final grouped = controller.groupedConfigurations;
                      if (grouped.isEmpty) {
                        return SizedBox(
                          height: 30.h,
                          child: Center(
                            child: Text(
                              'No prayer tracks found',
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: grouped.entries.map((entry) {
                          final categoryName = entry.key;
                          final tracks = entry.value;
                          final style = _getStyle(categoryName);

                          // Auto-expand first category if none selected
                          if (_expandedCategoryId == null &&
                              grouped.isNotEmpty) {
                            _expandedCategoryId = grouped.keys.first;
                          }

                          return _CategoryCard(
                            categoryName: categoryName,
                            tracks: tracks,
                            style: style,
                            isExpanded: _expandedCategoryId == categoryName,
                            getEmoji: _getEmoji,
                            getCleanTitle: _getCleanTitle,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _expandedCategoryId =
                                    expanded ? categoryName : null;
                              });
                            },
                            onTrackTap: _showPrayerSheet,
                          );
                        }).toList(),
                      );
                    }),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final List<SpiritualConfiguration> tracks;
  final _CategoryStyle style;
  final bool isExpanded;
  final Function(bool) onExpansionChanged;
  final Function(SpiritualConfiguration) onTrackTap;
  final String Function(String) getEmoji;
  final String Function(String) getCleanTitle;

  const _CategoryCard({
    required this.categoryName,
    required this.tracks,
    required this.style,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onTrackTap,
    required this.getEmoji,
    required this.getCleanTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 1.2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? style.color.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: onExpansionChanged,
          initiallyExpanded: isExpanded,
          key: PageStorageKey(categoryName),
          leading: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: style.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(style.icon, color: style.color, size: 20.sp),
          ),
          title: Text(
            getCleanTitle(categoryName),
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          trailing: Icon(
            isExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: Colors.white30,
          ),
          children: tracks
              .map(
                (track) => _TrackTile(
                  track: track,
                  onTap: () => onTrackTap(track),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ─── Track Tile ───────────────────────────────────────────────────────────────

class _TrackTile extends StatelessWidget {
  final SpiritualConfiguration track;
  final VoidCallback onTap;

  const _TrackTile({required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.5.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title ?? 'Untitled Prayer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${track.subcategory ?? track.subtitle ?? 'Prayer'} • ${track.duration ?? '15 MIN'}',
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      color: Colors.white38,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.black,
                size: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Prayer Begin Sheet ───────────────────────────────────────────────────────

class PrayerBeginSheet extends StatefulWidget {
  final SpiritualConfiguration track;

  const PrayerBeginSheet({super.key, required this.track});

  @override
  State<PrayerBeginSheet> createState() => _PrayerBeginSheetState();
}

class _PrayerBeginSheetState extends State<PrayerBeginSheet> {
  bool _isStarting = false;

  /// Parses "15 minutes" → 15
  int _parseDurationMins() {
    final raw = widget.track.duration ?? '15 minutes';
    final digits = RegExp(r'\d+').firstMatch(raw);
    return int.tryParse(digits?.group(0) ?? '15') ?? 15;
  }

  @override
  Widget build(BuildContext context) {
    final durationMins = _parseDurationMins();

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: EdgeInsets.all(4.w),
          padding: EdgeInsets.fromLTRB(6.w, 3.h, 6.w, 4.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title Row ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Begin Prayer',
                    style: GoogleFonts.lora(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // ── Track name + subcategory ──────────────────────────────────
              Text(
                widget.track.title ?? 'Prayer Session',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                widget.track.subcategory ??
                    widget.track.subtitle ??
                    'Daily Prayer',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: Colors.white38,
                ),
              ),

              // ── Description ───────────────────────────────────────────────
              if (widget.track.description != null) ...[
                SizedBox(height: 2.h),
                Text(
                  widget.track.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),
              ],

              SizedBox(height: 2.5.h),

              // ── Info chips ────────────────────────────────────────────────
              Row(
                children: [
                  _infoChip(
                    icon: Icons.access_time_rounded,
                    label: widget.track.duration ?? '$durationMins MIN',
                  ),
                  SizedBox(width: 3.w),
                  _infoChip(
                    icon: Icons.stars_rounded,
                    label: '+${widget.track.karmaPoints ?? 7} karma',
                    color: const Color(0xFFD4AF37),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // ── Begin Journey Button ──────────────────────────────────────
              GestureDetector(
                onTap: _isStarting
                    ? null
                    : () async {
                        setState(() => _isStarting = true);
                        try {
                          final repository = SpiritualRepository();
                          final clipsResponse = await repository.getClips(
                            widget.track.sId!,
                          );

                          if (clipsResponse != null &&
                              clipsResponse.success == true &&
                              clipsResponse.data != null &&
                              clipsResponse.data!.isNotEmpty) {
                            final clip = clipsResponse.data!.first;

                            Get.toNamed(
                              AppConstants.routeMeditationStart,
                              arguments: {
                                'duration': durationMins,
                                'config': widget.track,
                                'clips': [
                                  {
                                    'audioUrl': clip.audioUrl,
                                    'videoUrl': clip.videoUrl,
                                  },
                                ],
                              },
                            );
                          } else {
                            Utils.showToast('Failed to load prayer clips');
                          }
                        } catch (e) {
                          Utils.showToast(
                            'An error occurred. Please try again.',
                          );
                        } finally {
                          if (mounted) setState(() => _isStarting = false);
                        }
                      },
                child: Container(
                  width: double.infinity,
                  height: 7.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isStarting
                          ? [Colors.grey, Colors.grey.shade700]
                          : [
                              const Color(0xFFD4AF37),
                              const Color(0xFFB8860B),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      if (!_isStarting)
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                    ],
                  ),
                  child: Center(
                    child: _isStarting
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Begin Journey',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.black,
                                size: 22.sp,
                              ),
                            ],
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

  Widget _infoChip({
    required IconData icon,
    required String label,
    Color color = Colors.white54,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.sp),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Style helper ─────────────────────────────────────────────────────────────

class _CategoryStyle {
  final IconData icon;
  final Color color;
  _CategoryStyle({required this.icon, required this.color});
}
