import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../blocs/pooja_bloc.dart';
import '../blocs/pooja_event.dart';
import '../blocs/pooja_state.dart';

import '../repositories/pooja_repository.dart';
import 'pooja_vidhi_screen.dart';
import 'package:brahmakosh/common/widgets/translated_text.dart';

class PoojaDetailScreen extends StatefulWidget {
  final String poojaId;
  const PoojaDetailScreen({super.key, required this.poojaId});

  @override
  State<PoojaDetailScreen> createState() => _PoojaDetailScreenState();
}

class _PoojaDetailScreenState extends State<PoojaDetailScreen> {

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
            margin: EdgeInsets.all(1.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 14.sp,
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

              return Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Image Card (Preserved data)
                      // Redesigned Header Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          child: Container(
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
                                      height: 25.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 25.h,
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
                                    pooja.pujaName ?? "",
                                    style: GoogleFonts.lora(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                      ),
                                      SizedBox(height: 1.5.h),
                                      Divider(color: Colors.white.withOpacity(0.05), height: 1),
                                      SizedBox(height: 2.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                         
                                            child: _buildSmallInfo(
                                              null,
                                              pooja.category ?? "Pooja",
                                              isSvg: true,
                                            ),
                                          ),
                                      
                                          Expanded(
                                            child: _buildSmallInfo(
                                              Icons.access_time_filled,
                                              "${pooja.duration ?? 0} Mins",
                                            ),
                                          ),
                                         
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (pooja.description != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader("puja_significance".tr),
                                  SizedBox(height: 1.5.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_month, size: 14.sp, color: Color(0xFFD4AF37)),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                      child: TranslatedText(
                                      "best_timing".trParams({
                                        'day': pooja.bestDay ?? "Friday",
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
                                  SizedBox(height: 2.h),
                                  TranslatedText(
                                    pooja.description ?? "",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: Colors.white.withOpacity(0.5),
                                      height: 1.6,
                                    ),
                                    // maxLines: 6,
                                    // overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(child: SizedBox(height: 3.h)),

                      if (pooja.purpose != null && pooja.purpose!.trim().isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader("benefits_results".tr),
                                SizedBox(height: 1.5.h),
                                // This would ideally be a list, but we'll adapt the single purpose string
                                ... (pooja.purpose!.split('.').where((e) => e.trim().isNotEmpty).map((point) => 
                                  Container(
                                    margin: EdgeInsets.all(1.h),
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111111),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8.w,
                                          height: 8.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            size: 14.sp,
                                            color: const Color(0xFFD4AF37),
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TranslatedText(
                                                point.trim(),
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
                        )
                      else
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader("Benefits/Results"),
                                SizedBox(height: 1.h),
                                Text(
                                  "Detailed benefits for this ritual will be added soon.",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.white.withOpacity(0.4),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: 12.h),
                      ), // Space for button
                    ],
                  ),

                  // Start Button
                  Positioned(
                    bottom: 3.h,
                    left: 6.w,
                    right: 6.w,
                    child: Container(
                      height: 6.h,
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
                            Icon(
                              Icons.play_circle_filled,
                              color: Colors.black,
                              size: 18.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              "start_puja_vidhi".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
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
          width: 0.5.w,
          height: 2.h,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInfo(IconData? icon, String text, {bool isSvg = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSvg)
          SvgPicture.asset(
            'assets/icons/diya.svg',
            width: 14.sp,
            height: 14.sp,
            // colorFilter: const ColorFilter.mode(Color(0xFFD4AF37), BlendMode.srcIn),
          )
        else if (icon != null)
          Icon(icon, size: 14.sp, color: const Color(0xFFD4AF37)),
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
          ),
        ),
      ],
    );
  }
}

