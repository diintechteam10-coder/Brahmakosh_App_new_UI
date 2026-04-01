import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/translate_helper.dart';

import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import 'sankalp_progress_screen.dart';
import 'choose_sankalp_screen.dart';

class MySankalpTab extends StatefulWidget {
  const MySankalpTab({super.key});

  @override
  State<MySankalpTab> createState() => _MySankalpTabState();
}

class _MySankalpTabState extends State<MySankalpTab> {
  final Map<String, String> _dynamicTranslations = {};
  String _lastLang = 'en';

  Future<void> _translateAllContents(List<UserSankalpModel> sankalps) async {
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

    for (var us in sankalps) {
      if (us.sankalp.title.isNotEmpty) {
        toTranslate.add(us.sankalp.title);
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
    return BlocBuilder<SankalpBloc, SankalpState>(
      builder: (context, state) {
        if (state is SankalpLoading && state is! SankalpLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SankalpError) {
          return Center(child: Text(state.message));
        }

        List<UserSankalpModel> activeSankalps = [];
        if (state is SankalpLoaded) {
          activeSankalps = state.userSankalps
              .where((s) => s.status == 'active')
              .toList();
          _translateAllContents(activeSankalps);
        }


        if (activeSankalps.isEmpty) {
          if (state is SankalpLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<SankalpBloc>().add(FetchUserSankalps());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: _buildEmptyState(context),
              ),
            ),
          );
        }

        return BlocListener<SankalpBloc, SankalpState>(
          listener: (context, state) {
            if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;

            if (state is SankalpOperationSuccess) {
              _showSuccessDialog(context, state.message);
            } else if (state is SankalpError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<SankalpBloc>().add(FetchUserSankalps());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: activeSankalps.length,
                    itemBuilder: (context, index) {
                      final userSankalp = activeSankalps[index];
                      return _buildSankalpCard(context, userSankalp);
                    },
                  ),
                ),
              ),
              
              // Bottom Action Button: Choose Another Sankalp
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      final bloc = context.read<SankalpBloc>();
                      Get.to(
                        () => BlocProvider.value(
                          value: bloc,
                          child: const ChooseSankalpScreen(),
                        ),
                        transition: Transition.downToUp,
                      )?.then((_) => bloc.add(FetchUserSankalps()));
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.5), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      foregroundColor: AppTheme.primaryGold,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "choose_another_sankalp".tr,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.add, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image
          Positioned(
            top: -50,
            child: Image.asset(
              'assets/icons/sankalpbg.png',
              height: 500,
              width: 500,
              fit: BoxFit.contain,
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 180),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "start_first_sankalp".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "Sankalp",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                    "sankalp_journey_desc".tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  final bloc = context.read<SankalpBloc>();
                  Get.to(
                    () => BlocProvider.value(
                      value: bloc,
                      child: const ChooseSankalpScreen(),
                    ),
                    transition: Transition.downToUp,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "choose_sankalp".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "your_spiritual_path".tr,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSankalpCard(BuildContext context, UserSankalpModel userSankalp) {
    final completedDays = userSankalp.dailyReports
        .where((r) => r.status == 'yes')
        .length;
    double progress = userSankalp.totalDays > 0
        ? completedDays / userSankalp.totalDays
        : 0;

    final sankalp = userSankalp.sankalp;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _dynamicTranslations[sankalp.title] ?? sankalp.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled,
                    size: 18,
                    color: AppTheme.primaryGold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    userSankalp.reminderTime ?? "06:00 AM",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Banner Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                sankalp.bannerImage.isNotEmpty
                    ? sankalp.bannerImage
                    : "https://images.unsplash.com/photo-1604881991720-f91add269bed",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white.withOpacity(0.05),
                  child: const Icon(Icons.image_not_supported, color: Colors.white24),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "daily_progress".tr,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 0.5,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$completedDays",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "/${userSankalp.totalDays} days",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // View Progress Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final bloc = context.read<SankalpBloc>();
                Get.to(
                  () => BlocProvider.value(
                    value: bloc,
                    child: SankalpProgressScreen(sankalpId: userSankalp.id),
                  ),
                  transition: Transition.rightToLeft,
                )?.then((_) {
                  bloc.add(FetchUserSankalps());
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "view_progress".tr,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    final sankalpBloc = context.read<SankalpBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.2)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
              const SizedBox(height: 16),
              Text(
                "great_job".tr,
                style: GoogleFonts.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    sankalpBloc.add(ClearSankalpOperationStatus());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "keep_going".tr,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

