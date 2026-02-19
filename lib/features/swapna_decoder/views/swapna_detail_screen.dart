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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: CustomColors.lightPinkColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(child: Text("Error: $_error")),
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
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xff5D4037),
                  size: 20,
                ),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: swapna.thumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    swapna.symbolName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5D4037),
                    ),
                  ),
                  if (swapna.symbolNameHindi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      swapna.symbolNameHindi,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        color: const Color(0xff8D6E63),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionTitle("Interpretation"),
                  const SizedBox(height: 8),
                  Text(
                    swapna.detailedInterpretation ??
                        swapna.shortDescription ??
                        '',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (swapna.positiveAspects != null &&
                      swapna.positiveAspects!.isNotEmpty) ...[
                    _buildSectionTitle("Positive Aspects"),
                    ...swapna.positiveAspects!.map(
                      (e) => _buildBulletPoint(
                        e.point,
                        e.description,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (swapna.negativeAspects != null &&
                      swapna.negativeAspects!.isNotEmpty) ...[
                    _buildSectionTitle("Negative Aspects"),
                    ...swapna.negativeAspects!.map(
                      (e) => _buildBulletPoint(
                        e.point,
                        e.description,
                        Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (swapna.remedies != null) ...[
                    _buildSectionTitle("Remedies"),
                    const SizedBox(height: 8),
                    // Mantras
                    if (swapna.remedies!.mantras != null &&
                        swapna.remedies!.mantras!.isNotEmpty) ...[
                      Text(
                        "Mantras:",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      ...swapna.remedies!.mantras!.map(
                        (m) => Text("• $m", style: GoogleFonts.inter()),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Precautions
                    if (swapna.remedies!.precautions != null &&
                        swapna.remedies!.precautions!.isNotEmpty) ...[
                      Text(
                        "Precautions:",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      ...swapna.remedies!.precautions!.map(
                        (p) => Text("• $p", style: GoogleFonts.inter()),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xff5D4037),
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(color: Colors.black87, height: 1.4),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
