import 'package:brahmakosh/core/custom_widgets/auth_logo.dart';
import 'package:brahmakosh/core/custom_widgets/input_filed.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFF8EC), Color(0xffFDFDFD)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                const AuthLogoAvatar(),

                const SizedBox(height: 6),

                Text(
                  "Complete Your Profile",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Tell us a little about yourself",
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 18),

                /// 🧾 FORM CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AppInputField(
                        label: "Full Name",
                        hint: "Full name",
                        icon: Icons.person_outline,
                        controller: controller.nameController,
                      ),

                      const SizedBox(height: 12),

                      /// DOB
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            controller.dobController.text =
                                "${pickedDate.day.toString().padLeft(2, '0')}-"
                                "${pickedDate.month.toString().padLeft(2, '0')}-"
                                "${pickedDate.year}";
                          }
                        },
                        child: AbsorbPointer(
                          child: AppInputField(
                            label: "Date of Birth",
                            hint: "DD-MM-YYYY",
                            icon: Icons.calendar_today_outlined,
                            controller: controller.dobController,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// TIME
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            controller.timeController.text = pickedTime.format(
                              context,
                            );
                          }
                        },
                        child: AbsorbPointer(
                          child: AppInputField(
                            label: "Time of Birth",
                            hint: "HH:MM",
                            icon: Icons.access_time_outlined,
                            controller: controller.timeController,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Place of Birth",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: GooglePlaceAutoCompleteTextField(
                              textEditingController: controller.placeController,
                              focusNode: controller.placeFocusNode,
                              googleAPIKey:
                                  "AIzaSyB1N1fd5YovpLgcOwzSqDMhrTGg98lkUoI", // Replace with your API Key
                              inputDecoration: InputDecoration(
                                hintText: "Place",
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                                prefixIcon: const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                              ),
                              getPlaceDetailWithLatLng: (Prediction prediction) {
                                // print("Place details: ${prediction.lat} ${prediction.lng}");
                              },
                              itemClick: (Prediction prediction) {
                                controller.placeController.text =
                                    prediction.description!;
                                controller.placeController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: prediction.description!.length,
                                      ),
                                    );
                              },
                              textStyle: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      AppInputField(
                        label: "Profession",
                        hint: "Profession",
                        icon: Icons.auto_awesome_outlined,
                        controller: controller.gowthraController,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// 🚀 SUBMIT
                Obx(
                  () => GestureDetector(
                    onTap: controller.isLoading.value
                        ? null
                        : controller.submitProfile,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGold,
                            AppTheme.primaryGold.withOpacity(0.85),
                          ],
                        ),
                      ),
                      child: Center(
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Submit Profile",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
