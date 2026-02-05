import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/features/check_in/controllers/chanting_configuration_controller.dart';

class ChantingConfigurationView
    extends GetView<ChantingConfigurationController> {
  const ChantingConfigurationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<ChantingConfigurationController>()) {
      Get.put(ChantingConfigurationController());
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF8E7), // Light beige background
      body: SafeArea(
        bottom: false,
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
                      const SizedBox(
                        height: 5,
                      ), // Reduced from 20 to 5 to match Spiritual
                      Text(
                        'Chanting',
                        style: GoogleFonts.poppins(
                          fontSize: 22, // Reduced from 28
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 5), // Reduced from 15 to 5
                      Text(
                        'How are you feeling today?',
                        style: GoogleFonts.poppins(
                          fontSize: 14, // Reduced from 16
                          color: const Color(0xff1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 15), // Reduced from 30 to 15
                      _buildEmotionSelector(),
                      const SizedBox(height: 30), // Reduced from 40 to 30
                      _buildMantraSelector(),
                      const SizedBox(height: 30), // Reduced from 40 to 30
                      _buildCountSelector(),
                      const SizedBox(height: 15), // Reduced from 40 to 15
                      _buildSummary(),
                      const SizedBox(height: 15), // Reduced from 40 to 15
                      _buildStartButton(),
                      const SizedBox(height: 10), // Reduced from 20 to 10
                      Text(
                        'You can stop anytime',
                        style: GoogleFonts.poppins(
                          fontSize: 12, // Reduced from 14 to 12
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10), // Reduced from 20 to 10
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

  Widget _buildEmotionSelector() {
    return SizedBox(height: 110, child: _EmotionList(controller: controller));
  }

  Widget _buildMantraSelector() {
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
                Icons.music_note_outlined,
                size: 20,
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              Text(
                'Mantra',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Obx(() {
            if (controller.filteredConfigurations.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    "No mantras available for this mood.",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 100, // Adjust height as needed
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.filteredConfigurations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final config = controller.filteredConfigurations[index];
                  return Obx(() {
                    final isSelected =
                        controller.selectedConfiguration.value == config;
                    return GestureDetector(
                      onTap: () => controller.onConfigurationSelected(config),
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xffFFF3E0)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xffFF9B44)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              config.chantingType ?? "Mantra",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tiroDevanagariHindi(
                                fontSize: 16,
                                color: isSelected
                                    ? const Color(0xffFF9B44)
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCountSelector() {
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
                'Select Count',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Obx(() {
            final counts = controller.availableCounts;
            final selected = controller.selectedCount.value;
            final currentIndex = counts.indexOf(selected).toDouble();

            return Column(
              children: [
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
                    max: (counts.length - 1).toDouble(),
                    divisions: counts.length - 1,
                    label: '${counts[currentIndex.toInt()]}',
                    onChanged: (value) {
                      final index = value.toInt();
                      if (index >= 0 && index < counts.length) {
                        controller.selectCount(counts[index]);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${counts.first}',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      Text(
                        '${counts.last}',
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

  Widget _buildSummary() {
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
                '📿', // Rosary/Mala icon
                '${controller.selectedCount.value} Counts',
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
            // Dynamic Karma points
            Obx(() {
              final karma =
                  controller.selectedConfiguration.value?.karmaPoints ?? 0;
              return Text(
                '+$karma karma Points',
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

  Widget _buildStartButton() {
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
  final ChantingConfigurationController controller;
  const _EmotionList({required this.controller});

  @override
  State<_EmotionList> createState() => _EmotionListState();
}

class _EmotionListState extends State<_EmotionList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  void _scrollToSelected() {
    final selectedEmotion = widget.controller.selectedEmotion.value;
    if (selectedEmotion != null) {
      final emotions = widget.controller.emotionEmojis.keys.toList();
      final index = emotions.indexOf(selectedEmotion);
      if (index != -1) {
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalPadding = 40.0; // 20.0 * 2 from parent
        final viewportWidth = screenWidth - horizontalPadding;
        final itemWidth = screenWidth / 3;

        final position =
            (index * itemWidth) + (itemWidth / 2) - (viewportWidth / 2);

        // Ensure within bounds
        double target = position;
        if (target < 0) target = 0;
        if (target > _scrollController.position.maxScrollExtent) {
          target = _scrollController.position.maxScrollExtent;
        }

        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

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
                final screenWidth = MediaQuery.of(context).size.width;
                final horizontalPadding = 40.0;
                final viewportWidth = screenWidth - horizontalPadding;
                final position =
                    (index * itemWidth) + (itemWidth / 2) - (viewportWidth / 2);

                _scrollController.animateTo(
                  position < 0 ? 0 : position,
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
                      width: 55, // 75 -> 55
                      height: 55, // 75 -> 55
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent, // Removed orange background
                      ),
                      child: Text(
                        emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 30 : 22,
                        ), // 40/30 -> 30/22
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
