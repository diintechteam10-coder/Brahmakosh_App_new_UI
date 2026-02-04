import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/auth/controllers/complete_profile_controller.dart';
import 'package:brahmakosh/common_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class CompleteProfileView extends StatelessWidget {
  final String email;

  CompleteProfileView({super.key, required this.email});

  late final CompleteProfileController controller = Get.put(
    CompleteProfileController(email: email),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.landingBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Center(
                child: Text(
                  "Setup Your Profile",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5D4037),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "Tell Us Bit About Yourself",
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 30),

              _label("Full Name"),
              _buildTextField(
                controller: controller.nameController,
                hint: "Enter your full name",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              /// DOB
              _label("Date of Birth"),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.primaryGold,
                            onPrimary: Colors.white, // Selected text color
                            onSurface: Colors.black, // Default text color
                          ),
                          dialogBackgroundColor: Colors.white,
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    controller.dobController.text =
                        "${pickedDate.day.toString().padLeft(2, '0')}-"
                        "${pickedDate.month.toString().padLeft(2, '0')}-"
                        "${pickedDate.year}";
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: controller.dobController,
                    hint: "DD-MM-YYYY",
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// TIME
              _label("Time of Birth"),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.primaryGold,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          dialogBackgroundColor: Colors.white,
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedTime != null) {
                    controller.timeController.text = pickedTime.format(context);
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: controller.timeController,
                    hint: "HH:MM",
                    icon: Icons.access_time_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _label("Place of Birth"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Keep inputs white as per theme
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: controller.placeController,
                  focusNode: controller.placeFocusNode,
                  googleAPIKey: "AIzaSyB1N1fd5YovpLgcOwzSqDMhrTGg98lkUoI",
                  inputDecoration: InputDecoration(
                    hintText: "Search City",
                    hintStyle: GoogleFonts.inter(color: Colors.black38),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.black45,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  getPlaceDetailWithLatLng: (Prediction prediction) {},
                  itemClick: (Prediction prediction) {
                    controller.placeController.text = prediction.description!;
                    controller.placeController.selection =
                        TextSelection.fromPosition(
                          TextPosition(offset: prediction.description!.length),
                        );
                  },
                  textStyle: GoogleFonts.inter(fontSize: 15),
                ),
              ),

              const SizedBox(height: 20),

              _label("Profession"),
              _buildTextField(
                controller: controller.gowthraController,
                hint: "e.g. Software Engineer",
                icon: Icons.work_outline,
              ),

              const SizedBox(height: 40),

              /// 🚀 SUBMIT
              Obx(
                () => GestureDetector(
                  onTap: controller.isLoading.value
                      ? null
                      : controller.submitProfile,
                  child: Container(
                    height: 54, // Matches LoginView
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.landingButton, // Flat brown color
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Register",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xff5D4037),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.black38),
          prefixIcon: Icon(icon, color: Colors.black45, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
