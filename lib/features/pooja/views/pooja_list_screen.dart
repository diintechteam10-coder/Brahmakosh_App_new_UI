import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';

import '../blocs/pooja_bloc.dart';
import '../blocs/pooja_event.dart';
import '../blocs/pooja_state.dart';
import '../models/pooja_model.dart';
import '../repositories/pooja_repository.dart';
import 'pooja_detail_screen.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';

class PoojaListScreen extends StatefulWidget {
  const PoojaListScreen({super.key});

  @override
  State<PoojaListScreen> createState() => _PoojaListScreenState();
}

class _PoojaListScreenState extends State<PoojaListScreen> {
  final Map<String, String> _dynamicTranslations = {};
  String _lastLang = 'en';

  Future<void> _translateAllContents(List<PoojaModel> poojas) async {
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
    for (var pooja in poojas) {
      if (pooja.pujaName != null) toTranslate.add(pooja.pujaName!);
      if (pooja.category != null) toTranslate.add(pooja.category!);
      if (pooja.bestDay != null) toTranslate.add(pooja.bestDay!);
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
          PoojaBloc(repository: PoojaRepository())..add(FetchPoojas()),
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
          title: null,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    filled: true,
                    hintText: "search_hint".tr,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white.withOpacity(0.3), size: 18),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<PoojaBloc, PoojaState>(
                builder: (context, state) {
                  String selectedCategory = 'All';
                  if (state is PoojaLoaded) {
                    selectedCategory = state.selectedCategory;
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterTab(
                          context,
                          "all_cap".tr,
                          selectedCategory == 'All',
                          'All',
                        ),
                        _buildFilterTab(
                          context,
                          "festival_cap".tr,
                          selectedCategory == 'Festival',
                          'Festival'
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // List
            Expanded(
              child: BlocBuilder<PoojaBloc, PoojaState>(
                builder: (context, state) {
                  if (state is PoojaLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PoojaLoaded) {
                    // Trigger translation
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _translateAllContents(state.filteredPoojas);
                    });
                    
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.filteredPoojas.length,
                      itemBuilder: (context, index) {
                        return _buildPoojaCard(
                          context,
                          state.filteredPoojas[index],
                        );
                      },
                    );
                  } else if (state is PoojaError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context,
    String label,
    bool isSelected,
    String categoryKey,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<PoojaBloc>().add(FilterPoojas(categoryKey));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildPoojaCard(BuildContext context, PoojaModel pooja) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoojaDetailScreen(poojaId: pooja.sId ?? ""),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                pooja.thumbnailUrl ?? "",
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[900],
                  child: const Icon(Icons.image_not_supported, color: Colors.white24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dynamicTranslations[pooja.pujaName] ?? (pooja.pujaName ?? "Unknown Puja"),
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildInfoItem(
                          Icons.local_fire_department,
                          _dynamicTranslations[pooja.category] ?? (pooja.category ?? "Pooja"),
                          const Color(0xFFD4AF37),
                        ),
                      ),
                      Container(width: 1, height: 16, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                      Expanded(
                        flex: 2,
                        child: _buildInfoItem(
                          Icons.access_time_filled,
                          "min_suffix".trParams({'min': (pooja.duration ?? 0).toString()}),
                          const Color(0xFFD4AF37),
                        ),
                      ),
                      Container(width: 1, height: 16, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                      Expanded(
                        flex: 3,
                        child: _buildInfoItem(
                          Icons.calendar_month,
                          _dynamicTranslations[pooja.bestDay] ?? (pooja.bestDay ?? "Friday"),
                          const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoojaDetailScreen(poojaId: pooja.sId ?? ""),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "view_btn".tr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

