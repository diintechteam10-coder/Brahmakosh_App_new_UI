import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../common/colors.dart';
import '../models/swapna_model.dart';
import '../repositories/swapna_repository.dart';

class SwapnaDetailScreen extends StatefulWidget {
  final String id;
  final SwapnaModel? swapna;

  const SwapnaDetailScreen({super.key, required this.id, this.swapna});

  @override
  State<SwapnaDetailScreen> createState() => _SwapnaDetailScreenState();
}

class _SwapnaDetailScreenState extends State<SwapnaDetailScreen> {
  SwapnaModel? _swapna;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.swapna != null) {
      _swapna = widget.swapna;
    } else {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = SwapnaRepository();
      final detail = await repo.fetchSwapnaDetail(widget.id);
      setState(() {
        _swapna = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: CustomColors.lightPinkColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xffFF7438)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: CustomColors.lightPinkColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                "Failed to load details",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5D4037),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _error!,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_swapna == null) {
      return const SizedBox.shrink();
    }

    final swapna = _swapna!;

    return Scaffold(
      backgroundColor: CustomColors.lightPinkColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: CustomColors.lightPinkColor,
            elevation: 0,
            expandedHeight: 300,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xff5D4037),
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: swapna.thumbnailUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: const Color(0xffF4E9E0)),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xffF4E9E0),
                      child: const Icon(
                        Icons.nights_stay_outlined,
                        size: 60,
                        color: Color(0xffFEDA87),
                      ),
                    ),
                  ),
                  // Bottom gradient for smooth transition
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            CustomColors.lightPinkColor.withOpacity(0.8),
                            CustomColors.lightPinkColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffFFFDF5),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xffFEDA87),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Symbol name
                  Text(
                    swapna.symbolName,
                    style: GoogleFonts.lora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff4E342E),
                    ),
                  ),

                  // Hindi name
                  if (swapna.symbolNameHindi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      swapna.symbolNameHindi,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        color: const Color(0xff8D6E63),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],

                  // Category badge
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xffFEDA87).withOpacity(0.4),
                          const Color(0xffFEDA87).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xffFEDA87).withOpacity(0.6),
                      ),
                    ),
                    child: Text(
                      swapna.category,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff5D4037),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Interpretation
                  _buildSectionTitle("Interpretation", Icons.auto_stories_outlined),
                  const SizedBox(height: 12),
                  Text(
                    swapna.detailedInterpretation ??
                        swapna.shortDescription ??
                        '',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.7,
                      color: const Color(0xff4E342E),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Positive Aspects
                  if (swapna.positiveAspects != null &&
                      swapna.positiveAspects!.isNotEmpty) ...[
                    _buildSectionTitle(
                      "Positive Aspects",
                      Icons.wb_sunny_outlined,
                    ),
                    const SizedBox(height: 12),
                    ...swapna.positiveAspects!.map(
                      (e) => _buildAspectCard(
                        e.point,
                        e.description,
                        const Color(0xff2E7D32),
                        const Color(0xffE8F5E9),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Negative Aspects
                  if (swapna.negativeAspects != null &&
                      swapna.negativeAspects!.isNotEmpty) ...[
                    _buildSectionTitle(
                      "Negative Aspects",
                      Icons.warning_amber_outlined,
                    ),
                    const SizedBox(height: 12),
                    ...swapna.negativeAspects!.map(
                      (e) => _buildAspectCard(
                        e.point,
                        e.description,
                        const Color(0xffC62828),
                        const Color(0xffFFEBEE),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Remedies
                  if (swapna.remedies != null) ...[
                    _buildSectionTitle("Remedies", Icons.self_improvement),
                    const SizedBox(height: 12),

                    // Mantras
                    if (swapna.remedies!.mantras != null &&
                        swapna.remedies!.mantras!.isNotEmpty) ...[
                      _buildRemedyCard(
                        "Mantras",
                        "🕉",
                        swapna.remedies!.mantras!,
                        const Color(0xffFF7438),
                        const Color(0xffFFF3E0),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Precautions
                    if (swapna.remedies!.precautions != null &&
                        swapna.remedies!.precautions!.isNotEmpty) ...[
                      _buildRemedyCard(
                        "Precautions",
                        "⚠️",
                        swapna.remedies!.precautions!,
                        const Color(0xffF57F17),
                        const Color(0xffFFFDE7),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xffFF7438),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 20, color: const Color(0xff8D6E63)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff4E342E),
          ),
        ),
      ],
    );
  }

  Widget _buildAspectCard(
    String title,
    String description,
    Color accentColor,
    Color bgColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xff4E342E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemedyCard(
    String title,
    String emoji,
    List<String> items,
    Color accentColor,
    Color bgColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xff4E342E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
