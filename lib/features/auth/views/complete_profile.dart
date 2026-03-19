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
      backgroundColor: AppTheme.authBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Wavy Background Pattern
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_wavy_bg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.4),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "Setup Your Profile",
                      style: GoogleFonts.lora(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "Tell Us Bit About Yourself",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.authTextSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  _label("Full Name"),
                  _buildTextField(
                    controller: controller.nameController,
                    hint: "Enter your full name",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 24),

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
                              colorScheme: ColorScheme.dark(
                                primary: AppTheme.authPrimaryGold,
                                onPrimary: Colors.black,
                                surface: AppTheme.authSurface,
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: AppTheme.authSurface,
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

                  const SizedBox(height: 24),

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
                              colorScheme: ColorScheme.dark(
                                primary: AppTheme.authPrimaryGold,
                                onPrimary: Colors.black,
                                surface: AppTheme.authSurface,
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: AppTheme.authSurface,
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

                  const SizedBox(height: 24),

                  _label("Place of Birth"),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppTheme.authInputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: GooglePlaceAutoCompleteTextField(
                      isCrossBtnShown: false,
                      textEditingController: controller.placeController,
                      focusNode: controller.placeFocusNode,
                      googleAPIKey: "AIzaSyB1N1fd5YovpLgcOwzSqDMhrTGg98lkUoI",
                      inputDecoration: InputDecoration(
                        fillColor: Colors.transparent,
                        hintText: "Search City",
                        hintStyle: GoogleFonts.poppins(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.authPrimaryGold,
                          size: 20,
                        ),
                      
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          // vertical: 16,
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
                      textStyle: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _label("Profession"),
                  _buildTextField(
                    controller: controller.gowthraController,
                    hint: "e.g. Software Engineer",
                    icon: Icons.work_outline,
                  ),

                  const SizedBox(height: 48),

                  /// 🚀 SUBMIT
                  Obx(
                    () => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : controller.submitProfile,
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.authPrimaryGold,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!controller.isLoading.value)
                              BoxShadow(
                                color: AppTheme.authPrimaryGold.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
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
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  "Register",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
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
      height: 45,
      decoration: BoxDecoration(
        color: AppTheme.authInputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white70),
          prefixIcon: Icon(icon, color: AppTheme.authPrimaryGold, size: 20),
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
