import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/colors.dart';
import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';

class SankalpDetailScreen extends StatefulWidget {
  final SankalpModel sankalp;
  const SankalpDetailScreen({super.key, required this.sankalp});

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
    debugPrint("SankalpDetailScreen: build called");
    return BlocConsumer<SankalpBloc, SankalpState>(
      listener: (context, state) {
        if (state is SankalpOperationSuccess) {
          Get.back(); // Close dialog if open? No, dialog closes before event.
          Get.back(); // Go back to Choose Screen or My Sankalp
          Get.snackbar(
            "Success",
            state.message,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (state is SankalpError) {
          Get.snackbar(
            "Error",
            state.message,
            backgroundColor: Colors.red,
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
          backgroundColor: CustomColors.lightPinkColor,
          body: Stack(
            children: [
              // Background Image/Effect
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.network(
                    "https://images.unsplash.com/photo-1604881991720-f91add269bed?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: CustomColors.lightPinkColor,
                    elevation: 0,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xff5D4037),
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        ),
                        child: Image.network(
                          displaySankalp.bannerImage.isNotEmpty
                              ? displaySankalp.bannerImage
                              : "https://images.unsplash.com/photo-1604881991720-f91add269bed?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLoading)
                            const Center(child: LinearProgressIndicator()),
                          // About Card
                          _buildAboutCard(displaySankalp),
                          const SizedBox(height: 24),

                          // Duration Section
                          Text(
                            "Duration",
                            style: GoogleFonts.lora(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff4E342E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDurationOption("5 Days", 0),
                              _buildDurationOption("14 Days", 1),
                              _buildDurationOption("21 Days", 2),
                              _buildDurationOption("Custom", 3),
                            ],
                          ),

                          // Custom Days Input
                          if (_selectedDurationIndex == 3) ...[
                            const SizedBox(height: 16),
                            _buildCustomDaysInput(),
                          ],

                          const SizedBox(height: 24),

                          // Daily Reminder Section
                          _buildReminderCard(context),

                          const SizedBox(height: 24),

                          // Start Sankalp Button
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xffff7438), Color(0xffE65100)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xffff7438).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {
                                  if (_selectedDurationIndex == 3 &&
                                      _currentTotalDays <= 0) {
                                    Get.snackbar(
                                      "Invalid Duration",
                                      "Please enter a valid number of days.",
                                    );
                                    return;
                                  }
                                  _showStartConfirmation(context);
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.bolt, color: Colors.white, size: 22),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Start Sankalp",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutCard(SankalpModel sankalp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "About this Sankalp",
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff4E342E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.monetization_on,
                size: 16,
                color: Color(0xffD4AF37),
              ),
              const SizedBox(width: 4),
              Text(
                "Karma Points ${sankalp.karmaPointsPerDay} Per Day",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff8D6E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sankalp.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xff5D4037),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xffEEEEEE)),
        ],
      ),
    );
  }

  Widget _buildDurationOption(String label, int index) {
    bool isSelected = _selectedDurationIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDurationIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.transparent : Colors.white,
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xffFEDA87), Color(0xffFFD54F)])
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xff8D6E63).withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xffFEDA87).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xff4E342E) : const Color(0xff8D6E63),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDaysInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            "Number of Days",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff4E342E),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 50,
            child: TextField(
              controller: _customDaysController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "0",
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xff4E342E),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),
          const Icon(Icons.edit, size: 16, color: Color(0xffff9800)),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Reminder",
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xff4E342E),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Color(0xffff9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Status ${_isReminderActive ? 'Active' : 'Inactive'}",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff4E342E),
                ),
              ),
              const Spacer(),
              Switch(
                value: _isReminderActive,
                activeColor: const Color(0xffff9800),
                onChanged: (val) {
                  setState(() {
                    _isReminderActive = val;
                  });
                },
              ),
            ],
          ),
          if (_isReminderActive) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xffEEEEEE)),
            ),
            InkWell(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xffff9800),
                          onPrimary: Colors.white,
                          onSurface: Color(0xff4E342E),
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xffff9800),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _reminderTime = picked;
                  });
                }
              },
              child: Row(
                children: [
                  Text(
                    "Notify me at",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffff9800),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _reminderTime.format(context),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffff9800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 16, color: Color(0xffff9800)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showStartConfirmation(BuildContext context) {
    // Capture bloc here because Dialog context might not have access to it
    // if the provider is scoped to the screen route.
    final bloc = context.read<SankalpBloc>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xffFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: Color(0xffff7438),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Confirm Sankalp?",
                style: GoogleFonts.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff4E342E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Are you ready to commit to this $_currentTotalDays-day journey?",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xff8D6E63),
                ),
              ),
              if (_isReminderActive) ...[
                const SizedBox(height: 8),
                Text(
                  "Reminder set for ${_reminderTime.format(context)}",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xffff9800),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xff8D6E63)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          color: const Color(0xff8D6E63),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop(); // Close dialog for both Get and Nav
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
                        backgroundColor: const Color(0xffff7438),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Yes, I'm Ready",
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
