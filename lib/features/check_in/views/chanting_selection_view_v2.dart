import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/check_in/controllers/chanting_configuration_controller.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';


class ChantingSelectionViewV2 extends StatefulWidget {
  const ChantingSelectionViewV2({super.key});

  @override
  State<ChantingSelectionViewV2> createState() => _ChantingSelectionViewV2State();
}

class _ChantingSelectionViewV2State extends State<ChantingSelectionViewV2> {
  final ChantingConfigurationController controller = Get.put(ChantingConfigurationController());
  String? _expandedCategoryId;

  void _showCountSelection(SpiritualConfiguration config) {
    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: "CountSelection",
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
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart)),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CountSelectionSheet(config: config),
            ),
          ),
        );
      },
    );
  }

  String _getEmoji(String text) {
    if (text.isEmpty) return "📿";
    final characters = text.characters;
    if (characters.isEmpty) return "📿";
    return characters.first;
  }

  String _getCleanTitle(String text) {
    if (text.isEmpty) return "";
    final firstChar = text.characters.first;
    // Only strip if first char is non-ASCII (emoji/symbol)
    if (firstChar.codeUnits.any((u) => u > 127)) {
      return text.replaceFirst(firstChar, '').trim();
    }
    return text.trim();
  }

  // Category style map
  static const _kCategoryColors = {
    'Vedic':      Color(0xFFFFB74D),
    'Bhajan':     Color(0xFFF06292),
    'Mantra':     Color(0xFF4DB6AC),
    'Devotional': Color(0xFFCE93D8),
    'Classic':    Color(0xFF64B5F6),
    'Others':     Color(0xFFD4AF37),
  };
  static const _kCategoryIcons = {
    'Vedic':      Icons.auto_awesome_rounded,
    'Bhajan':     Icons.music_note_rounded,
    'Mantra':     Icons.self_improvement_rounded,
    'Devotional': Icons.favorite_rounded,
    'Classic':    Icons.queue_music_rounded,
    'Others':     Icons.spa_rounded,
  };

  Color _categoryColor(String name) {
    for (final e in _kCategoryColors.entries) {
      if (name.toLowerCase().contains(e.key.toLowerCase())) return e.value;
    }
    return const Color(0xFFD4AF37);
  }

  IconData _categoryIcon(String name) {
    for (final e in _kCategoryIcons.entries) {
      if (name.toLowerCase().contains(e.key.toLowerCase())) return e.value;
    }
    return Icons.spa_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.allConfigurations.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  );
                }

                if (controller.allConfigurations.isEmpty) {
                  return Center(
                    child: Text(
                      "No Chanting configurations found",
                      style: GoogleFonts.poppins(color: Colors.white60),
                    ),
                  );
                }

                final grouped = controller.groupedConfigurations;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      _sectionHeader("MANTRA LIBRARY"),
                      
                      ...grouped.entries.map((entry) {
                        final String categoryName = entry.key;
                        final List<SpiritualConfiguration> configs = entry.value;
                        
                        return _buildCategoryCard(categoryName, configs);
                      }),
                      
                      SizedBox(height: 5.h),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14.sp),
                ),
              ),
              Icon(Icons.more_vert, color: Colors.white, size: 18.sp),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            "Chanting",
            style: GoogleFonts.lora(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            "Align your mind and energy",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.white60,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 14.sp),
            SizedBox(width: 2.w),
          ],
          Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 1,
            ),
          ),
          SizedBox(width: 2.w),
          const Expanded(child: Divider(color: Colors.white10, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String categoryName, List<SpiritualConfiguration> configs) {
    bool isExpanded = _expandedCategoryId == categoryName;
    final color = _categoryColor(categoryName);
    final icon  = _categoryIcon(categoryName);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? color.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              onExpansionChanged: (expanded) {
                setState(() {
                  _expandedCategoryId = expanded ? categoryName : null;
                });
              },
              initiallyExpanded: isExpanded,
              key: PageStorageKey(categoryName),
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              title: Text(
                _getCleanTitle(categoryName),
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
              children: configs.map((config) => _buildTrackItem(config)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(SpiritualConfiguration config) {
    final trackTitle = config.title ?? config.chantingType ?? "Mantra";
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trackTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (config.subtitle != null || config.subcategory != null)
                  Text(
                    config.subcategory ?? config.subtitle ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      color: Colors.white38,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showCountSelection(config),
            child: Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow, color: Colors.black, size: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class CountSelectionSheet extends StatefulWidget {
  final SpiritualConfiguration config;
  const CountSelectionSheet({super.key, required this.config});

  @override
  State<CountSelectionSheet> createState() => _CountSelectionSheetState();
}

class _CountSelectionSheetState extends State<CountSelectionSheet> {
  double _countValue = 108;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Count",
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
                      child: Icon(Icons.close_rounded, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: "Set your count for "),
                      TextSpan(
                        text: widget.config.title ?? widget.config.chantingType ?? "Mantra",
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 6.h),

              // Styled Slider Area
              LayoutBuilder(
                builder: (context, constraints) {
                  double trackWidth = constraints.maxWidth - 32;
                  double thumbPosition = ((_countValue - 1) / (1008 - 1)) * trackWidth;
                  thumbPosition = thumbPosition.clamp(0.0, trackWidth);

                  return Column(
                    children: [
                      // Moving Count Bubble
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(height: 5.h, width: double.infinity),
                          Positioned(
                            left: thumbPosition - 35,
                            bottom: 0,
                            child: Container(
                              width: 70,
                              padding: EdgeInsets.symmetric(vertical: 0.6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${_countValue.toInt()} counts",
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, 4),
                                    child: CustomPaint(
                                      size: const Size(10, 6),
                                      painter: TrianglePainter(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Custom Themed Slider
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 8,
                          activeTrackColor: const Color(0xFFD4AF37),
                          inactiveTrackColor: Colors.white.withOpacity(0.1),
                          thumbColor: const Color(0xFFD4AF37),
                          overlayColor: const Color(0xFFD4AF37).withOpacity(0.1),
                          thumbShape: const PillSliderThumbShape(),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                          trackShape: const CustomTrackShape(),
                        ),
                        child: Slider(
                          value: _countValue,
                          min: 1,
                          max: 1008,
                          divisions: 1007,
                          onChanged: (value) {
                            setState(() {
                              _countValue = value;
                            });
                            Get.find<ChantingConfigurationController>().selectCount(value.toInt());
                          },
                        ),
                      ),

                      // Interval Dots
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            4,
                            (index) => Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 6.h),

              // Begin Journey Button
              GestureDetector(
                onTap: () {
                  final controller = Get.find<ChantingConfigurationController>();
                  controller.startSession(widget.config);
                },
                child: Container(
                  width: double.infinity,
                  height: 7.5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Begin Journey",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18.sp),
                    ],
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

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = const Color(0xFFD4AF37);
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PillSliderThumbShape extends SliderComponentShape {
  const PillSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(44, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    // Draw the pill-shaped thumb
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 44, height: 24),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, paint);

    // Draw the three vertical lines in the middle
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double lineSpacing = 4.0;
    const double lineHeight = 10.0;

    // Middle line
    canvas.drawLine(
      Offset(center.dx, center.dy - lineHeight / 2),
      Offset(center.dx, center.dy + lineHeight / 2),
      linePaint,
    );

    // Left line
    canvas.drawLine(
      Offset(center.dx - lineSpacing, center.dy - lineHeight / 2),
      Offset(center.dx - lineSpacing, center.dy + lineHeight / 2),
      linePaint,
    );

    // Right line
    canvas.drawLine(
      Offset(center.dx + lineSpacing, center.dy - lineHeight / 2),
      Offset(center.dx + lineSpacing, center.dy + lineHeight / 2),
      linePaint,
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  const CustomTrackShape();
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
