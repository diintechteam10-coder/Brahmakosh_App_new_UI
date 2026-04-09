import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../blocs/pooja_bloc.dart';
import '../blocs/pooja_event.dart';
import '../blocs/pooja_state.dart';
import '../models/pooja_model.dart';
import '../repositories/pooja_repository.dart';
import 'pooja_detail_screen.dart';
import 'package:brahmakosh/common/widgets/translated_text.dart';

class PoojaListScreen extends StatefulWidget {
  const PoojaListScreen({super.key});

  @override
  State<PoojaListScreen> createState() => _PoojaListScreenState();
}

class _PoojaListScreenState extends State<PoojaListScreen> {

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
            SizedBox(height: 2.h),
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    filled: true,
                    hintText: "search_hint".tr,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white.withOpacity(0.3), size: 18.sp),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.5.h),
            // Filter Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
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
            SizedBox(height: 2.5.h),
            // List
            Expanded(
              child: BlocBuilder<PoojaBloc, PoojaState>(
                builder: (context, state) {
                  if (state is PoojaLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PoojaLoaded) {
                    if (state.filteredPoojas.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.selectedCategory == 'Festival'
                                  ? Icons.event_busy
                                  : Icons.search_off,
                              color: Colors.white.withOpacity(0.2),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.selectedCategory == 'Festival'
                                  ? "no_festivals_found".tr
                                  : "no_poojas_found".tr,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
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
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
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
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(1.5.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  pooja.thumbnailUrl ?? "",
                  height: 20.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 20.h,
                    color: Colors.grey[900],
                    child: Icon(Icons.image_not_supported, color: Colors.white24, size: 24.sp),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 2.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    pooja.pujaName ?? "Unknown Puja",
                    style: GoogleFonts.lora(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  SizedBox(height: 1.5.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildInfoItem(
                          null,
                          pooja.category ?? "Pooja",
                          const Color(0xFFD4AF37),
                          isSvg: true,
                        ),
                      ),
                      Container(width: 1, height: 3.h, color: Colors.white.withOpacity(0.05), margin: EdgeInsets.symmetric(horizontal: 1.w)),
                      Expanded(
                        flex: 2,
                        child: _buildInfoItem(
                          Icons.access_time_filled,
                          "min_suffix".trParams({'min': (pooja.duration ?? 0).toString()}),
                          const Color(0xFFD4AF37),
                        ),
                      ),
                      Container(width: 1, height: 3.h, color: Colors.white.withOpacity(0.05), margin: EdgeInsets.symmetric(horizontal: 1.w)),
                      Expanded(
                        flex: 3,
                        child: _buildInfoItem(
                          Icons.calendar_month,
                          pooja.bestDay ?? "Friday",
                          const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.5.h),
                  Center(
                    child: SizedBox(
                      width: 70.w,
                      height: 5.h,
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
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "view_btn".tr,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
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

  Widget _buildInfoItem(IconData? icon, String text, Color iconColor, {bool isSvg = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSvg)
          SvgPicture.asset(
            'assets/icons/diya.svg',
            width: 14.sp,
            height: 14.sp,
            // colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          )
        else if (icon != null)
          Icon(icon, size: 14.sp, color: iconColor),
        SizedBox(width: 1.5.w),
        Expanded(
          child: TranslatedText(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
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

