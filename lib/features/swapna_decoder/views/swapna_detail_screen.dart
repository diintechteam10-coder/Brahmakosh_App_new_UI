import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
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
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                "Failed to load details",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5D4037),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _error!,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          swapna.symbolName,
          style: GoogleFonts.lora(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Hero Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: CachedNetworkImage(
                      imageUrl: swapna.thumbnailUrl ?? '',
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 220,
                        color: const Color(0xFF2C2C2E),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 220,
                        color: const Color(0xFF2C2C2E),
                        child: const Icon(
                          Icons.nights_stay_outlined,
                          size: 60,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          swapna.symbolName,
                          style: GoogleFonts.lora(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (swapna.symbolNameHindi.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            swapna.symbolNameHindi,
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildMetadataItem(
                              Icons.category_outlined,
                              swapna.category,
                            ),
                            const SizedBox(width: 16),
                            if (swapna.subcategory.isNotEmpty)
                              _buildMetadataItem(
                                Icons.auto_awesome_outlined,
                                swapna.subcategory,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Interpretation
            _buildSectionTitle("Detailed Significance", Icons.info_outline),
            const SizedBox(height: 16),
            Text(
              swapna.detailedInterpretation ??
                  swapna.shortDescription ??
                  '',
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 32),


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
                        const Color(0xff4CAF50),
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
                        const Color(0xffF44336),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

            // Remedies
            if (swapna.remedies != null) ...[
              _buildSectionTitle("Remedies & Precautions", Icons.self_improvement),
              const SizedBox(height: 16),

              // Mantras
              if (swapna.remedies!.mantras != null &&
                  swapna.remedies!.mantras!.isNotEmpty) ...[
                _buildRemedyCard(
                  "Sacred Mantras",
                  Icons.self_improvement,
                  swapna.remedies!.mantras!,
                  const Color(0xFFD4AF37),
                ),
                const SizedBox(height: 16),
              ],

              // Precautions
              if (swapna.remedies!.precautions != null &&
                  swapna.remedies!.precautions!.isNotEmpty) ...[
                _buildRemedyCard(
                  "Important Precautions",
                  Icons.warning_amber_rounded,
                  swapna.remedies!.precautions!,
                  const Color(0xFFFFB300),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAspectCard(
    String title,
    String description,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              accentColor == const Color(0xff4CAF50)
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              size: 20,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemedyCard(
    String title,
    IconData icon,
    List<String> items,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accentColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[400],
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

