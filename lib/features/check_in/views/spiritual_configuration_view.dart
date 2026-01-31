import 'package:brahmakosh/features/check_in/controllers/spiritual_configuration_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SpiritualConfigurationView extends StatelessWidget {
  const SpiritualConfigurationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpiritualConfigurationController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFDF8), Color(0xffFFF2D9), Color(0xffFFE4B5)],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final configurations = controller.configurations;
            if (configurations.isEmpty) {
              return Center(
                child: Text(
                  'No configurations found',
                  style: GoogleFonts.lora(),
                ),
              );
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEmotionSelector(controller),
                        const SizedBox(height: 30),
                        _buildDurationSlider(controller),
                        const SizedBox(height: 30),
                        _buildConfigurationSummary(controller),
                        const SizedBox(height: 40),
                        _buildStartButton(controller),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xff7B4A12)),
            onPressed: () => Get.back(),
          ),
          Text(
            'CONFIGURE SESSIONS',
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xff7B4A12),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildEmotionSelector(SpiritualConfigurationController controller) {
    // ScrollController to center items if needed, but for simple list Row is okay.
    // To "move to middle", we effectively need a scrollable list where selected item is centered.
    // Using a simple horizontal list for now.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5D3A1A),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.emotionEmojis.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final entry = controller.emotionEmojis.entries.elementAt(index);
              final emotion = entry.key;
              final emoji = entry.value;

              return Obx(() {
                final isSelected = controller.selectedEmotion.value == emotion;
                return GestureDetector(
                  onTap: () => controller.onEmotionSelected(emotion),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff7B4A12).withOpacity(0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: const Color(0xff7B4A12),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          emoji,
                          style: TextStyle(fontSize: isSelected ? 32 : 24),
                        ),
                        if (isSelected)
                          Text(
                            emotion,
                            style: GoogleFonts.lora(
                              fontSize: 10,
                              color: const Color(0xff7B4A12),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSlider(SpiritualConfigurationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Duration',
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5D3A1A),
              ),
            ),
            Obx(
              () => Text(
                '${controller.sliderValue.value.toInt()} minutes',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff7B4A12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: const Color(0xff7B4A12),
              inactiveTrackColor: const Color(0xff7B4A12).withOpacity(0.2),
              thumbColor: const Color(0xff7B4A12),
              overlayColor: const Color(0xff7B4A12).withOpacity(0.1),
              valueIndicatorColor: const Color(0xff7B4A12),
            ),
            child: Slider(
              value: controller.sliderValue.value,
              min: 1,
              max: 60,
              divisions: 59,
              label: '${controller.sliderValue.value.toInt()} min',
              onChanged: (value) => controller.updateDuration(value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationSummary(
    SpiritualConfigurationController controller,
  ) {
    return Obx(() {
      final config = controller.selectedConfig.value;
      if (config == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xff7B4A12).withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7B4A12).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'SUMMARY',
              style: GoogleFonts.cinzel(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: const Color(0xff7B4A12),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              config.title ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5D3A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // Remove "Rashmi" or other specific text if present in specific placeholders,
              // but mostly just display description.
              config.description ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xffC9A24D).withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Gain ${config.karmaPoints ?? 0} Karma Points',
                style: GoogleFonts.lora(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff7B4A12),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStartButton(SpiritualConfigurationController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Fetch clips and navigate to MeditationStart
          controller.startSession();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff7B4A12),
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'START SESSION',
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
