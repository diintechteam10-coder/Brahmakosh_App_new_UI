import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/features/check_in/blocs/prayer/prayer_bloc.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/common/utils.dart';

class PrayerConfigurationView extends StatelessWidget {
  const PrayerConfigurationView({super.key, required this.prayerCategoryId});
  final String prayerCategoryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PrayerBloc(repository: SpiritualRepository())
            ..add(LoadPrayerConfigs(categoryId: prayerCategoryId)),
      child: Scaffold(
        backgroundColor: const Color(0xffFFF8E7),
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<PrayerBloc, PrayerState>(
            listener: (context, state) {
              if (state is PrayerSessionReady) {
                // Navigate to Mantra/Prayer Session
                // Assuming we use the same route or a new one.
                // Plan said verify navigation. Using existing route for now.
                int durationMins = 10; // Default
                if (state.config.duration != null) {
                  final digits = state.config.duration!.replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  );
                  if (digits.isNotEmpty) {
                    durationMins = int.tryParse(digits) ?? 10;
                  }
                }

                Get.toNamed(
                  AppConstants.routeMeditationStart,
                  arguments: {
                    'duration': durationMins,
                    'config': state.config,
                    'clips': [
                      {'audioUrl': state.audioUrl, 'videoUrl': state.videoUrl},
                    ],
                  },
                );
              } else if (state is PrayerError) {
                Utils.showToast(state.message);
              }
            },
            builder: (context, state) {
              if (state is PrayerLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PrayerLoaded || state is PrayerSessionReady) {
                // Even if ready, we show the loaded UI until navigation happens
                final loadedState = state is PrayerLoaded
                    ? state
                    // Fallback using data from SessionReady if needed, but Bloc doesn't guarantee 'state' preserves old data unless we structured it.
                    // Actually, SessionReady doesn't hold list.
                    // Issue: If we emit SessionReady, build is called. SessionReady has NO config list.
                    // Fix: PrayerSessionReady should probably extend PrayerLoaded or hold the previous loaded state to avoid UI flicker.
                    // For now, let's just show a loader or empty container if SessionReady is emitted, assuming navigation is fast.
                    // Or better, let's keep showing the UI if we can.
                    // But SessionReady doesn't have the lists.
                    : null;

                if (loadedState == null) {
                  // If session ready doesn't hold data, just show loader or empty
                  // Ideally PrayerSessionReady should extend Loaded or hold it
                  return const Center(child: CircularProgressIndicator());
                }

                return Stack(
                  children: [
                    Column(
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
                                const SizedBox(height: 5),
                                Text(
                                  "Prayer",
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff1E1E1E),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'How are you feeling today?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xff1E1E1E),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildEmotionSelector(context, loadedState),
                                const SizedBox(height: 30),
                                _buildPrayerSelector(context, loadedState),
                                const SizedBox(height: 15),
                                _buildSummary(context, loadedState),
                                const SizedBox(height: 15),
                                _buildStartButton(context, loadedState),
                                const SizedBox(height: 10),
                                Text(
                                  'You can stop anytime',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (loadedState.isStarting)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                );
              }

              if (state is PrayerError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox();
            },
          ),
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

  Widget _buildEmotionSelector(BuildContext context, PrayerLoaded state) {
    return SizedBox(
      height: 110,
      child: _EmotionList(
        selectedEmotion: state.selectedEmotion,
        onSelect: (emotion) {
          context.read<PrayerBloc>().add(SelectPrayerEmotion(emotion));
        },
      ),
    );
  }

  Widget _buildPrayerSelector(BuildContext context, PrayerLoaded state) {
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
                Icons.spa_outlined, // Changed icon for Prayer
                size: 20,
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              Text(
                'Prayer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          if (state.filteredConfigurations.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  "No prayers available for this mood.",
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: state.filteredConfigurations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final config = state.filteredConfigurations[index];
                  final isSelected = state.selectedConfig?.sId == config.sId;

                  return GestureDetector(
                    onTap: () {
                      context.read<PrayerBloc>().add(
                        SelectPrayerMantra(config),
                      );
                    },
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
                            _getDisplayPrayerText(config),
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
                },
              ),
            ),
        ],
      ),
    );
  }

  String _getDisplayPrayerText(SpiritualConfiguration config) {
    if (config.prayerType != null && config.prayerType!.isNotEmpty) {
      return config.prayerType!;
    }
    // Fallback to chanting logic if prayerType missing
    if (config.chantingType != null &&
        config.chantingType!.isNotEmpty &&
        config.chantingType != "Other") {
      return config.chantingType!;
    } else if (config.customChantingType != null &&
        config.customChantingType!.isNotEmpty) {
      return config.customChantingType!;
    }
    return "Prayer";
  }

  Widget _buildSummary(BuildContext context, PrayerLoaded state) {
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
            _summaryChip(
              state.selectedEmotion != null
                  ? (PrayerBloc.emotionEmojis[state.selectedEmotion] ?? '😐')
                  : '😐',
              'Mood',
            ),
            // Removed Count chip
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
            Text(
              '+${state.selectedConfig?.karmaPoints ?? 0} karma Points',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xffFF9B44),
              ),
            ),
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

  Widget _buildStartButton(BuildContext context, PrayerLoaded state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.read<PrayerBloc>().add(const StartPrayerSession());
        },
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
  final String? selectedEmotion;
  final Function(String) onSelect;

  const _EmotionList({required this.selectedEmotion, required this.onSelect});

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
    final selectedEmotion = widget.selectedEmotion;
    if (selectedEmotion != null) {
      final emotions = PrayerBloc.emotionEmojis.keys.toList();
      final index = emotions.indexOf(selectedEmotion);
      if (index != -1) {
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalPadding = 40.0;
        final viewportWidth = screenWidth - horizontalPadding;
        final itemWidth = screenWidth / 3;

        final position =
            (index * itemWidth) + (itemWidth / 2) - (viewportWidth / 2);

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
  void didUpdateWidget(covariant _EmotionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedEmotion != widget.selectedEmotion) {
      _scrollToSelected();
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
    // Calculated item width same as view
    final itemWidth = width / 3;

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: PrayerBloc.emotionEmojis.length,
      itemBuilder: (context, index) {
        final entry = PrayerBloc.emotionEmojis.entries.elementAt(index);
        final emotion = entry.key;
        final emoji = entry.value;

        final isSelected = widget.selectedEmotion == emotion;

        return SizedBox(
          width: itemWidth,
          child: GestureDetector(
            onTap: () {
              widget.onSelect(emotion);
            },
            child: AnimatedScale(
              scale: isSelected ? 1.3 : 0.8,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: isSelected ? 30 : 22),
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
          ),
        );
      },
    );
  }
}
