import 'package:brahmakosh/core/common_imports.dart';
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
        backgroundColor: Colors.black,
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
                                  "PRAYER",
                                  style: GoogleFonts.lora(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'How are you feeling today?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
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
                                    color: Colors.white54,
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
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                        ),
                      ),
                  ],
                );
              }

              if (state is PrayerError) {
                return Center(child: Text(state.message, style: TextStyle(color: Colors.white)));
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {},
            ),
          ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Dark Background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white, // White Icon Background
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  size: 16,
                  color: Color(0xffE67E22), // Orange icon
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Prayer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                            ? const Color(0xFF1C1C1E)
                            : Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD4AF37)
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
                                  ? const Color(0xFFD4AF37)
                                  : Colors.white70,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Dark Background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Summary',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
              const SizedBox(width: 6),
              Text(
                'Finish to earn ',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              Text(
                '+${state.selectedConfig?.karmaPoints ?? 0} ',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 13),
              const SizedBox(width: 4),
              Text(
                'karma Points',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String icon, String label) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, PrayerLoaded state) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xffE67E22), // Orange Button
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<PrayerBloc>().add(const StartPrayerSession());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          'START',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
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
                        fontSize: isSelected ? 12 : 10,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white54,
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

