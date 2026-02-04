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
      backgroundColor: const Color(0xffFFF8E7), // Light beige background
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
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
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Mediate',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'How are you feeling today?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xff1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildEmotionSelector(controller),
                      const SizedBox(height: 40),
                      _buildDurationSelector(controller),
                      const SizedBox(height: 40),
                      _buildConfigurationSummary(controller),
                      const SizedBox(height: 40),
                      _buildStartButton(controller),
                      const SizedBox(height: 20),
                      Text(
                        'You can stop anytime',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          Text(
            'Back',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
          const Spacer(),
          const Icon(Icons.more_vert, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildEmotionSelector(SpiritualConfigurationController controller) {
    return SizedBox(height: 160, child: _EmotionList(controller: controller));
  }

  Widget _buildDurationSelector(SpiritualConfigurationController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
              const Icon(
                Icons.check_circle_outline,
                size: 20,
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              Text(
                'Select Duration',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Obx(() {
            final durations = controller.availableDurations;
            final currentIndex = durations
                .indexOf(controller.selectedDuration.value)
                .toDouble();

            // Map slider value (index) to duration
            return Column(
              children: [
                // Custom tooltip-like label logic could go here,
                // but Slider doesn't support easy custom permanent tooltips above thumb.
                // We'll trust the default label behaviour or just show the value.
                // The design has a prominent bubble above the thumb.
                // Flutter's Slider `label` shows on drag.

                // Let's rely on standard Slider with nice colors.
                SliderTheme(
                  data: SliderTheme.of(Get.context!).copyWith(
                    activeTrackColor: const Color(0xffFF9B44),
                    inactiveTrackColor: Colors.orange.withOpacity(0.2),
                    thumbColor: Colors.white,
                    overlayColor: const Color(0xffFF9B44).withOpacity(0.1),
                    valueIndicatorColor: const Color(0xffFF9B44),
                    valueIndicatorTextStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: currentIndex < 0 ? 0 : currentIndex,
                    min: 0,
                    max: (durations.length - 1).toDouble(),
                    divisions: durations.length - 1,
                    label: _formatDuration(durations[currentIndex.toInt()]),
                    onChanged: (value) {
                      final index = value.toInt();
                      if (index >= 0 && index < durations.length) {
                        controller.selectDuration(durations[index]);
                      }
                    },
                  ),
                ),

                // Labels below slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(durations.first),
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      Text(
                        _formatDuration(durations.last),
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '$hours Hr';
      return '$hours Hr $mins Min';
    }
    return '$minutes Min';
  }

  Widget _buildConfigurationSummary(
    SpiritualConfigurationController controller,
  ) {
    return Column(
      children: [
        Text(
          'Summary',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xff1E1E1E),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => _summaryChip(
                controller.selectedEmotion.value == null
                    ? '😐'
                    : controller.emotionEmojis[controller
                              .selectedEmotion
                              .value] ??
                          '😐',
                'Mood',
              ),
            ),
            const SizedBox(width: 24),
            Obx(
              () => _summaryChip(
                '🕒',
                _formatDuration(controller.selectedDuration.value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Color(0xffFF9B44), size: 20),
            const SizedBox(width: 8),
            Text(
              'Finish to earn ',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xff1E1E1E),
              ),
            ),
            Obx(() {
              final points =
                  controller.selectedConfig.value?.karmaPoints ??
                  10; // Default 10 if null
              return Text(
                '+$points karma Points',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffFF9B44),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _summaryChip(String icon, String label) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xff1E1E1E),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(SpiritualConfigurationController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => controller.startSession(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffFF8C00), // Orange
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Start',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EmotionList extends StatefulWidget {
  final SpiritualConfigurationController controller;
  const _EmotionList({required this.controller});

  @override
  State<_EmotionList> createState() => _EmotionListState();
}

class _EmotionListState extends State<_EmotionList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final itemWidth = width / 3;

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: (width - itemWidth) / 2),
      itemCount: widget.controller.emotionEmojis.length,
      itemBuilder: (context, index) {
        final entry = widget.controller.emotionEmojis.entries.elementAt(index);
        final emotion = entry.key;
        final emoji = entry.value;

        return SizedBox(
          width: itemWidth,
          child: Obx(() {
            final isSelected =
                widget.controller.selectedEmotion.value == emotion;
            return GestureDetector(
              onTap: () {
                widget.controller.onEmotionSelected(emotion);
                _scrollController.animateTo(
                  index * itemWidth,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              },
              child: AnimatedScale(
                scale: isSelected ? 1.3 : 0.8,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xffFFD194), Color(0xffFF9B44)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Colors.grey[200],
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xffFF9B44,
                                  ).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: isSelected ? 40 : 30),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isSelected ? 1.0 : 0.6,
                      child: Text(
                        emotion,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSelected ? 16 : 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: const Color(0xff1E1E1E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
