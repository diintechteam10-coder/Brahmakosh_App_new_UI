import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sankalp_success_screen.dart';

import '../../../../core/theme/app_theme.dart';

import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';

class SankalpDetailScreen extends StatefulWidget {
  final SankalpModel sankalp;
  SankalpDetailScreen({super.key, required this.sankalp}) {
    debugPrint("SankalpDetailScreen: CONSTRUCTOR CALLED for ${sankalp.id}");
  }

  @override
  State<SankalpDetailScreen> createState() => _SankalpDetailScreenState();
}

class _SankalpDetailScreenState extends State<SankalpDetailScreen> {
  // Duration Selection: 0->5, 1->14, 2->21, 3->Custom
  int _selectedDurationIndex = 0;
  final TextEditingController _customDaysController = TextEditingController();

  // Reminder
  bool _isReminderActive = false;
  TimeOfDay _reminderTime = const TimeOfDay(
    hour: 6,
    minute: 0,
  ); // Default 6:00 AM

  @override
  void initState() {
    super.initState();
    debugPrint("SankalpDetailScreen: initState for ${widget.sankalp.id}");
    context.read<SankalpBloc>().add(FetchSankalpDetail(widget.sankalp.id));
  }

  @override
  void dispose() {
    debugPrint("SankalpDetailScreen: dispose for ${widget.sankalp.id}");
    _customDaysController.dispose();
    super.dispose();
  }

  int get _currentTotalDays {
    switch (_selectedDurationIndex) {
      case 0:
        return 5;
      case 1:
        return 14;
      case 2:
        return 21;
      case 3:
        return int.tryParse(_customDaysController.text) ?? 0;
      default:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "SankalpDetailScreen: building with sankalp ${widget.sankalp.title}",
    );
    return BlocConsumer<SankalpBloc, SankalpState>(
      listenWhen: (previous, current) {
        debugPrint(
          "SankalpDetailScreen: state change from $previous to $current",
        );
        return current is SankalpOperationSuccess || current is SankalpError;
      },
      listener: (context, state) {
        if (state is SankalpOperationSuccess) {
          Get.off(
            () => SankalpSuccessScreen(sankalpTitle: widget.sankalp.title),
          );
        } else if (state is SankalpError) {
          Get.snackbar(
            "Error",
            state.message,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      },
      builder: (context, state) {
        SankalpModel displaySankalp = widget.sankalp;
        bool isLoading = false;

        if (state is SankalpLoaded) {
          if (state.selectedSankalp != null &&
              state.selectedSankalp!.id == widget.sankalp.id) {
            displaySankalp = state.selectedSankalp!;
          }
          isLoading = state.isDetailLoading;
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              onPressed: () => Get.back(),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/icons/sankalpbg.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 100, 12, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main card container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                displaySankalp.bannerImage.isNotEmpty
                                    ? displaySankalp.bannerImage
                                    : "https://images.unsplash.com/photo-1604881991720-f91add269bed",
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Title row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    "About this Sankalp".toUpperCase(),
                                    style: GoogleFonts.lora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildKarmaBadge(
                                  displaySankalp.karmaPointsPerDay,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              displaySankalp.description,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Duration Section
                      Text(
                        "Duration".toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildDurationOption("5 Days", 0),
                          const SizedBox(width: 8),
                          _buildDurationOption("14 Days", 1),
                          const SizedBox(width: 8),
                          _buildDurationOption("21 Days", 2),
                          const SizedBox(width: 8),
                          _buildDurationOption("Custom", 3),
                        ],
                      ),

                      if (_selectedDurationIndex == 3) ...[
                        const SizedBox(height: 12),
                        _buildCustomDaysRow(),
                      ],

                      const SizedBox(height: 32),
                      _buildReminderCard(context),
                      const SizedBox(height: 40),

                      // Start Sankalp Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedDurationIndex == 3 &&
                                _currentTotalDays <= 0) {
                              Get.snackbar(
                                "Invalid Duration",
                                "Please enter valid days",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            _showStartConfirmation(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Start Sankalp",
                                style: GoogleFonts.cinzel(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_right_alt, size: 28),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKarmaBadge(int points) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/icons/gold_coin.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/brahmkosh_logo.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.stars, color: AppTheme.primaryGold, size: 16),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "+$points Karma / Day",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGold,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationOption(String label, int index) {
    bool isSelected = _selectedDurationIndex == index;
    bool isCustom = index == 3;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDurationIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isCustom ? AppTheme.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected || isCustom
                  ? AppTheme.primaryGold
                  : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCustom
                  ? Colors.black
                  : (isSelected
                        ? AppTheme.primaryGold
                        : Colors.white.withOpacity(0.5)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDaysRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Number of Days",
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                height: 40,
                child: TextField(
                  controller: _customDaysController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    // isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    hintText: "0",
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.edit, color: AppTheme.primaryGold, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Reminder".toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: AppTheme.primaryGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Status Active",
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isReminderActive,
                activeColor: AppTheme.primaryGold,
                onChanged: (val) => setState(() => _isReminderActive = val),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10),
          ),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (picked != null) setState(() => _reminderTime = picked);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Notify me at",
                  style: GoogleFonts.cinzel(
                    color: AppTheme.primaryGold.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _reminderTime.format(context),
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit,
                      color: AppTheme.primaryGold,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStartConfirmation(BuildContext context) {
    final bloc = context.read<SankalpBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Confirm Commitment",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          "Are you ready for this $_currentTotalDays day journey?",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                bloc.add(
                  JoinSankalp(
                    sankalpId: widget.sankalp.id,
                    customDays: _currentTotalDays,
                    reminderTime:
                        "${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}",
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "I'M READY",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
