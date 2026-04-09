import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:brahmakosh/features/report/controllers/report_controller.dart';
import 'package:brahmakosh/features/report/models/match_making_model.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class MatchMakingView extends StatefulWidget {
  const MatchMakingView({super.key});

  @override
  State<MatchMakingView> createState() => _MatchMakingViewState();
}

class _MatchMakingViewState extends State<MatchMakingView> {
  late final ReportController _ctrl;
  late final HomeController _homeController;
  late ConfettiController _confettiController;

  // Male fields
  final _mDay = TextEditingController(text: '23');
  final _mMonth = TextEditingController(text: '11');
  final _mYear = TextEditingController(text: '1985');
  final _mHour = TextEditingController(text: '12');
  final _mMin = TextEditingController(text: '40');
  final _mLat = TextEditingController(text: '28.7041');
  final _mLon = TextEditingController(text: '77.1025');

  // Female fields
  final _fDay = TextEditingController(text: '24');
  final _fMonth = TextEditingController(text: '6');
  final _fYear = TextEditingController(text: '1983');
  final _fHour = TextEditingController(text: '17');
  final _fMin = TextEditingController(text: '5');
  final _fLat = TextEditingController(text: '30.9');
  final _fLon = TextEditingController(text: '75.8573');

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ReportController>();
    _homeController = Get.find<HomeController>();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _ctrl.resetMatchMaking();
    _fillGroomFromProfile();

    // Listen for success to trigger confetti
    ever(_ctrl.matchMakingResult, (result) {
      if (result != null) {
        _confettiController.play();
      }
    });
  }

  void _fillGroomFromProfile() {
    final details = _homeController.userCompleteDetails?.data?.astrology?.birthDetails;
    if (details != null) {
      _mDay.text = (details.day ?? '').toString();
      _mMonth.text = (details.month ?? '').toString();
      _mYear.text = (details.year ?? '').toString();
      _mHour.text = (details.hour ?? '').toString();
      _mMin.text = (details.minute ?? '').toString();
      _mLat.text = (details.latitude ?? '').toString();
      _mLon.text = (details.longitude ?? '').toString();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    for (final c in [_mDay, _mMonth, _mYear, _mHour, _mMin, _mLat, _mLon,
                     _fDay, _fMonth, _fYear, _fHour, _fMin, _fLat, _fLon]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    try {
      final req = MatchMakingRequest(
        mDay: int.parse(_mDay.text),
        mMonth: int.parse(_mMonth.text),
        mYear: int.parse(_mYear.text),
        mHour: int.parse(_mHour.text),
        mMin: int.parse(_mMin.text),
        mLat: double.parse(_mLat.text),
        mLon: double.parse(_mLon.text),
        mTzone: 5.5,
        fDay: int.parse(_fDay.text),
        fMonth: int.parse(_fMonth.text),
        fYear: int.parse(_fYear.text),
        fHour: int.parse(_fHour.text),
        fMin: int.parse(_fMin.text),
        fLat: double.parse(_fLat.text),
        fLon: double.parse(_fLon.text),
        fTzone: 5.5,
      );
      _ctrl.generateMatchMaking(req);
    } catch (_) {
      Utils.showToast('fill_all_fields_error'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              sliver: SliverList(delegate: SliverChildListDelegate([
                SizedBox(height: 2.h),
                _buildIntroCard(),
                SizedBox(height: 3.h),
                _buildPersonSection(
                  label: 'groom_details'.tr,
                  items: [
                    IconButton(
                      onPressed: _fillGroomFromProfile,
                      icon: Icon(Icons.person_pin_rounded, color: Colors.white.withValues(alpha: 0.5), size: 2.2.h),
                      tooltip: 'fill_from_profile'.tr,
                    ),
                  ],
                  emoji: '🤵',
                  color: const Color(0xFF4A90D9),
                  gradient: const [Color(0xFF1A3A5C), Color(0xFF4A90D9)],
                  controllers: [_mDay, _mMonth, _mYear, _mHour, _mMin, _mLat, _mLon],
                  labels: ['day'.tr, 'month'.tr, 'year'.tr, 'hour'.tr, 'minute'.tr, 'latitude'.tr, 'longitude'.tr],
                  hints: ['23', '11', '1985', '12', '40', '28.7041', '77.1025'],
                ),
                SizedBox(height: 2.5.h),
                _buildPersonSection(
                  label: 'bride_details'.tr,
                  emoji: '👰',
                  color: const Color(0xFFDD2476),
                  gradient: const [Color(0xFF5E1030), Color(0xFFDD2476)],
                  controllers: [_fDay, _fMonth, _fYear, _fHour, _fMin, _fLat, _fLon],
                  labels: ['day'.tr, 'month'.tr, 'year'.tr, 'hour'.tr, 'minute'.tr, 'latitude'.tr, 'longitude'.tr],
                  hints: ['24', '6', '1983', '17', '5', '30.9', '75.8573'],
                ),
                SizedBox(height: 3.h),
                _buildSubmitButton(),
                SizedBox(height: 3.h),
                Obx(() {
                  final result = _ctrl.matchMakingResult.value;
                  if (result == null) return const SizedBox.shrink();
                  return _buildResultCard(result);
                }),
                SizedBox(height: 10.h),
              ])),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
          createParticlePath: _drawStar,
        ),
      ),
    ],
  ),
);
}

Path _drawStar(Size size) {
  // Method to draw a star
  double degToRad(double deg) => deg * (pi / 180.0);

  const numberOfPoints = 5;
  final halfWidth = size.width / 2;
  final externalRadius = halfWidth;
  final internalRadius = halfWidth / 2.5;
  final degreesPerStep = degToRad(360 / numberOfPoints);
  final halfDegreesPerStep = degreesPerStep / 2;
  final path = Path();
  final fullAngle = degToRad(-90);

  path.moveTo(size.width, halfWidth + externalRadius * sin(fullAngle));

  for (double step = 0; step < degToRad(360); step += degreesPerStep) {
    path.lineTo(halfWidth + externalRadius * cos(step + fullAngle),
        halfWidth + externalRadius * sin(step + fullAngle));
    path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep + fullAngle),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep + fullAngle));
  }
  path.close();
  return path;
}

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 10.w, height: 10.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 1.8.h, color: Colors.white),
          ),
        ),
        SizedBox(width: 3.w),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('compatibility_match'.tr,
              style: GoogleFonts.lora(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('vedic_kundali_matching'.tr,
              style: GoogleFonts.poppins(fontSize: 9.sp, color: Colors.white.withValues(alpha: 0.45))),
        ]),
      ]),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D0A3E), Color(0xFF1A0A2E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8E2DE2).withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: const Color(0xFF8E2DE2).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.favorite_rounded, color: const Color(0xFFDD2476), size: 2.5.h),
        ),
        SizedBox(width: 3.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ashtakoot_matching'.tr, style: GoogleFonts.lora(
              fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 0.5.h),
          Text('ashtakoot_desc'.tr,
              style: GoogleFonts.poppins(fontSize: 8.5.sp,
                  color: Colors.white.withValues(alpha: 0.6), height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _buildPersonSection({
    required String label,
    required String emoji,
    required Color color,
    required List<Color> gradient,
    required List<TextEditingController> controllers,
    required List<String> labels,
    required List<String> hints,
    List<Widget>? items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient,
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: TextStyle(fontSize: 2.h)),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(label, style: GoogleFonts.lora(fontSize: 13.sp,
                fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          if (items != null) ...items,
        ]),
        SizedBox(height: 2.h),
        // Date row
        Row(children: [
          _field(controllers[0], labels[0], hints[0], color, isNum: true, flex: 1),
          SizedBox(width: 2.w),
          _field(controllers[1], labels[1], hints[1], color, isNum: true, flex: 1),
          SizedBox(width: 2.w),
          _field(controllers[2], labels[2], hints[2], color, isNum: true, flex: 2),
        ]),
        SizedBox(height: 1.5.h),
        // Time row
        Row(children: [
          _field(controllers[3], labels[3], hints[3], color, isNum: true, flex: 1),
          SizedBox(width: 2.w),
          _field(controllers[4], labels[4], hints[4], color, isNum: true, flex: 1),
        ]),
        SizedBox(height: 1.5.h),
        // Coords row
        Row(children: [
          _field(controllers[5], labels[5], hints[5], color, flex: 1),
          SizedBox(width: 2.w),
          _field(controllers[6], labels[6], hints[6], color, flex: 1),
        ]),
        SizedBox(height: 1.h),
        Text('coords_note'.tr,
            style: GoogleFonts.poppins(fontSize: 8.sp, color: Colors.white.withValues(alpha: 0.3))),
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint, Color accent,
      {bool isNum = false, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 8.5.sp,
                color: Colors.white.withValues(alpha: 0.5))),
        SizedBox(height: 0.4.h),
        TextField(
          controller: ctrl,
          keyboardType: isNum ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.2)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => GestureDetector(
      onTap: _ctrl.isGeneratingMatchMaking.value ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 1.8.h),
        decoration: BoxDecoration(
          gradient: _ctrl.isGeneratingMatchMaking.value
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFFDD2476)],
                  begin: Alignment.centerLeft, end: Alignment.centerRight),
          color: _ctrl.isGeneratingMatchMaking.value
              ? Colors.white.withValues(alpha: 0.05) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _ctrl.isGeneratingMatchMaking.value ? [] : [
            BoxShadow(
              color: const Color(0xFF8E2DE2).withValues(alpha: 0.4),
              blurRadius: 20, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _ctrl.isGeneratingMatchMaking.value
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 2.h, height: 2.h,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))),
                SizedBox(width: 3.w),
                Text('analysing_compatibility'.tr,
                    style: GoogleFonts.poppins(fontSize: 11.sp,
                        fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.6))),
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.favorite_rounded, color: Colors.white, size: 2.2.h),
                SizedBox(width: 2.w),
                Text('check_compatibility'.tr,
                    style: GoogleFonts.poppins(fontSize: 12.sp,
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
      ),
    ));
  }

  Widget _buildResultCard(MatchMakingData result) {
    final pct = result.compatibilityPercent;
    final Color scoreColor = pct >= 70
        ? const Color(0xFF2ECC71)
        : pct >= 50
            ? const Color(0xFFF39C12)
            : const Color(0xFFE74C3C);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('compatibility_result'.tr,
          style: GoogleFonts.lora(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
      SizedBox(height: 1.5.h),
      // Score header
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Text('${result.totalPoints ?? 0} / ${result.maxPoints ?? 36}',
              style: GoogleFonts.lora(fontSize: 36.sp,
                  fontWeight: FontWeight.bold, color: scoreColor)),
          Text('compatibility_score_label'.tr,
              style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.5))),
          SizedBox(height: 2.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 1.h,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(scoreColor),
            ),
          ),
          SizedBox(height: 1.h),
          Text('match_percent'.trParams({'percent': pct.toStringAsFixed(1)}),
              style: GoogleFonts.poppins(fontSize: 10.sp,
                  fontWeight: FontWeight.w600, color: scoreColor)),
          if (result.conclusion != null && result.conclusion!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scoreColor.withValues(alpha: 0.2)),
              ),
              child: Text(result.conclusion!,
                  style: GoogleFonts.poppins(fontSize: 9.5.sp,
                      color: Colors.white.withValues(alpha: 0.8), height: 1.6)),
            ),
          ],
        ]),
      ),
      // Koota details
      if (result.kootaDetails != null && result.kootaDetails!.isNotEmpty) ...[
        SizedBox(height: 2.5.h),
        Text('koota_analysis'.tr,
            style: GoogleFonts.lora(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 1.5.h),
        ...result.kootaDetails!.map((k) => _kootaRow(k)),
      ],
    ]);
  }

  Widget _kootaRow(KootaDetail k) {
    final max = k.totalPoints ?? 1;
    final obtained = k.obtainedPoints ?? 0;
    final pct = max > 0 ? obtained / max : 0.0;
    final Color c = pct >= 0.7
        ? const Color(0xFF2ECC71) : pct >= 0.5
            ? const Color(0xFFF39C12) : const Color(0xFFE74C3C);
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(k.name ?? '',
              style: GoogleFonts.poppins(fontSize: 10.sp,
                  fontWeight: FontWeight.w600, color: Colors.white))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$obtained / $max',
                style: GoogleFonts.poppins(fontSize: 9.sp,
                    fontWeight: FontWeight.w700, color: c)),
          ),
        ]),
        SizedBox(height: 0.8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.toDouble(),
            minHeight: 0.6.h,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation(c),
          ),
        ),
        if (k.description != null && k.description!.isNotEmpty) ...[
          SizedBox(height: 0.6.h),
          Text(k.description!,
              style: GoogleFonts.poppins(fontSize: 8.5.sp,
                  color: Colors.white.withValues(alpha: 0.45))),
        ],
      ]),
    );
  }
}
