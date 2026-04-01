import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../blocs/pooja_bloc.dart';
import '../blocs/pooja_event.dart';
import '../blocs/pooja_state.dart';

import '../repositories/pooja_repository.dart';
import '../models/pooja_model.dart';
import 'pooja_vidhi_screen.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';

class PoojaDetailScreen extends StatefulWidget {
  final String poojaId;
  const PoojaDetailScreen({super.key, required this.poojaId});

  @override
  State<PoojaDetailScreen> createState() => _PoojaDetailScreenState();
}

class _PoojaDetailScreenState extends State<PoojaDetailScreen> {
  final Map<String, String> _dynamicTranslations = {};
  String _lastLang = 'en';

  Future<void> _translateAllContents(PoojaModel pooja) async {
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
    if (pooja.pujaName != null) toTranslate.add(pooja.pujaName!);
    if (pooja.category != null) toTranslate.add(pooja.category!);
    if (pooja.bestDay != null) toTranslate.add(pooja.bestDay!);
    if (pooja.description != null) toTranslate.add(pooja.description!);
    if (pooja.purpose != null) {
      final points = pooja.purpose!.split('.').where((e) => e.trim().isNotEmpty);
      for (var p in points) {
        toTranslate.add(p.trim());
      }
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
          PoojaBloc(repository: PoojaRepository())
            ..add(FetchPoojaDetail(widget.poojaId)),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: BlocBuilder<PoojaBloc, PoojaState>(
          builder: (context, state) {
            if (state is PoojaDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PoojaDetailLoaded) {
              final pooja = state.pooja;
              // Trigger translation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _translateAllContents(pooja);
              });

              return Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Image Card (Preserved data)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              image: DecorationImage(
                                image: NetworkImage(pooja.thumbnailUrl ?? ""),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _dynamicTranslations[pooja.pujaName] ?? (pooja.pujaName ?? ""),
                                    style: GoogleFonts.lora(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildSmallInfo(
                                        Icons.local_fire_department,
                                        _dynamicTranslations[pooja.category] ?? (pooja.category ?? "Pooja"),
                                      ),
                                  Spacer(),
                                      _buildSmallInfo(Icons.access_time_filled, "min_suffix".trParams({'min': (pooja.duration ?? 0).toString()})),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (pooja.description != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader("puja_significance".tr),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.calendar_month, size: 16, color: Color(0xFFD4AF37)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "best_timing".trParams({
                                              'day': _dynamicTranslations[pooja.bestDay] ?? (pooja.bestDay ?? "Friday"),
                                            }),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFD4AF37),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _dynamicTranslations[pooja.description] ?? (pooja.description ?? ""),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.5),
                                      height: 1.6,
                                    ),
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // const SizedBox(height: 12),
                                  // GestureDetector(
                                  //   onTap: () {},
                                  //   child: Row(
                                  //     children: [
                                  //       Text(
                                  //         "Read More",
                                  //         style: GoogleFonts.poppins(
                                  //           fontSize: 13,
                                  //           fontWeight: FontWeight.w600,
                                  //           color: const Color(0xFFD4AF37),
                                  //         ),
                                  //       ),
                                  //       const SizedBox(width: 4),
                                  //       const Icon(
                                  //         Icons.arrow_forward,
                                  //         size: 14,
                                  //         color: Color(0xFFD4AF37),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      if (pooja.purpose != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader("benefits_results".tr),
                                const SizedBox(height: 16),
                                // This would ideally be a list, but we'll adapt the single purpose string
                                ... (pooja.purpose!.split('.').where((e) => e.trim().isNotEmpty).map((point) => 
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111111),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Color(0xFFD4AF37),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _dynamicTranslations[point.trim()] ?? point.trim(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "benefit_impact_details".tr,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.white.withOpacity(0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ), // Space for button
                    ],
                  ),

                  // Start Button
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => PoojaVidhiScreen(pooja: pooja));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_circle_filled,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "start_puja_vidhi".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is PoojaError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 2,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

