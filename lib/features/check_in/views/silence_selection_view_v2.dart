import 'package:brahmakosh/features/check_in/controllers/silence_configuration_controller.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/common_imports.dart';

class SilenceSelectionViewV2 extends StatefulWidget {
  final String silenceCategoryId;
  const SilenceSelectionViewV2({super.key, required this.silenceCategoryId});

  @override
  State<SilenceSelectionViewV2> createState() => _SilenceSelectionViewV2State();
}

class _SilenceSelectionViewV2State extends State<SilenceSelectionViewV2> {
  final SilenceConfigurationController controller =
      Get.put(SilenceConfigurationController());
  String? _expandedCategoryId;

  @override
  void initState() {
    super.initState();
    controller.fetchConfigurations(widget.silenceCategoryId);
  }

  String _getEmoji(String text) {
    if (text.isEmpty) return '🔕';
    final characters = text.characters;
    if (characters.isEmpty) return '🔕';
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

  final Map<String, _CategoryStyle> _categoryStyles = {
    'Guided':
        _CategoryStyle(icon: Icons.self_improvement_rounded, color: const Color(0xFF80CBC4)),
    'Nature':
        _CategoryStyle(icon: Icons.park_rounded, color: const Color(0xFF81C784)),
    'Breath':
        _CategoryStyle(icon: Icons.air_rounded, color: const Color(0xFF64B5F6)),
    'Deep':
        _CategoryStyle(icon: Icons.nights_stay_rounded, color: const Color(0xFFCE93D8)),
    'Sound':
        _CategoryStyle(icon: Icons.music_note_rounded, color: const Color(0xFFF48FB1)),
    'Others':
        _CategoryStyle(icon: Icons.spa_rounded, color: const Color(0xFFD4AF37)),
  };

  _CategoryStyle _getStyle(String categoryName) {
    return _categoryStyles.entries
        .firstWhere(
          (e) => categoryName.toLowerCase().contains(e.key.toLowerCase()),
          orElse: () => _categoryStyles.entries.last,
        )
        .value;
  }

  void _showSilenceSheet(SpiritualConfiguration track) {
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
              child: SilenceBeginSheet(track: track),
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
            // ── Header ─────────────────────────────────────────────────────
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
                      'Silence',
                      style: GoogleFonts.lora(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Embrace the stillness within',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // ── Categories Label ──────────────────────────────────
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

                    // ── Content ────────────────────────────────────────────
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

                      // ── Empty state ────────────────────────────────────
                      if (grouped.isEmpty) {
                        return _buildEmptyState();
                      }

                      // ── Category cards ─────────────────────────────────
                      return Column(
                        children: grouped.entries.map((entry) {
                          final categoryName = entry.key;
                          final tracks = entry.value;
                          final style = _getStyle(categoryName);

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
                            onTrackTap: _showSilenceSheet,
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

  Widget _buildEmptyState() {
    return SizedBox(
      height: 50.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Soft glowing icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text('🔕', style: TextStyle(fontSize: 32.sp)),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Coming Soon',
            style: GoogleFonts.lora(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Silence sessions are being\nprepared for you.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.white38,
              height: 1.6,
            ),
          ),
          SizedBox(height: 4.h),
          // Decorative dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                width: i == 1 ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == 1
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
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
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
                    track.title ?? 'Untitled Silence',
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
                    '${track.subcategory ?? track.subtitle ?? 'Silent Session'} • ${track.duration ?? '10 MIN'}',
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

// ─── Silence Begin Sheet ──────────────────────────────────────────────────────

class SilenceBeginSheet extends StatefulWidget {
  final SpiritualConfiguration track;
  const SilenceBeginSheet({super.key, required this.track});

  @override
  State<SilenceBeginSheet> createState() => _SilenceBeginSheetState();
}

class _SilenceBeginSheetState extends State<SilenceBeginSheet> {
  int _selectedMins = 10;
  bool _isCustom = false;
  bool _isStarting = false;
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // ── Title Row ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Duration',
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
              SizedBox(height: 1.h),
              RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  children: [
                    const TextSpan(text: 'Choose your time for '),
                    TextSpan(
                      text: widget.track.title ?? 'Silence',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              // ── Duration Options ─────────────────────────────────────
              FittedBox(
                child: SizedBox(
                  width: 90.w,
                  height: 10.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _durationOption(5),
                      SizedBox(width: 2.w),
                      _durationOption(10),
                      SizedBox(width: 2.w),
                      _durationOption(15),
                      SizedBox(width: 2.w),
                      _durationOption(20),
                      SizedBox(width: 2.w),
                      _customOption(),
                    ],
                  ),
                ),
              ),

              if (_isCustom) ...[
                SizedBox(height: 3.h),
                TextField(
                  controller: _customController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.sp,
                  ),
                  cursorColor: const Color(0xFFD4AF37),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Enter custom minutes',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white24,
                      fontSize: 11.sp,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 5.h),

              // ── Begin Journey Button ──────────────────────────────────
              GestureDetector(
                onTap: _isStarting
                    ? null
                    : () async {
                        setState(() => _isStarting = true);
                        try {
                          final int duration = _isCustom
                              ? (int.tryParse(_customController.text) ?? 10)
                              : _selectedMins;

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
                                'duration': duration,
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
                            Utils.showToast('Failed to load silence clips');
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

  Widget _durationOption(int mins) {
    final isSelected = _selectedMins == mins && !_isCustom;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedMins = mins;
          _isCustom = false;
        }),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(isSelected ? 0 : 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$mins',
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.black : const Color(0xFFD4AF37),
                ),
              ),
              Text(
                'MINS',
                style: GoogleFonts.poppins(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.black : const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customOption() {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isCustom = true),
        child: Container(
          decoration: BoxDecoration(
            color: _isCustom ? const Color(0xFFD4AF37) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  const Color(0xFFD4AF37).withOpacity(_isCustom ? 0 : 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_rounded,
                size: 20.sp,
                color: _isCustom ? Colors.black : const Color(0xFFD4AF37),
              ),
              SizedBox(height: 0.2.h),
              FittedBox(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Text(
                    'CUSTOM',
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          _isCustom ? Colors.black : const Color(0xFFD4AF37),
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
}

// ─── Style helper ─────────────────────────────────────────────────────────────

class _CategoryStyle {
  final IconData icon;
  final Color color;
  _CategoryStyle({required this.icon, required this.color});
}
