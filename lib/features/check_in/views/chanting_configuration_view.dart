import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/features/check_in/blocs/chanting/chanting_bloc.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/custom_widgets/custom_fluid_slider.dart';

class ChantingConfigurationView extends StatelessWidget {
  const ChantingConfigurationView({
    super.key,
    required this.chantingCategoryId,
  });
  final String chantingCategoryId;

  // Hardcoded Category ID for "Chanting" from requirements
  //  static const String chantingCategoryId = "69787dcbbeaf7e42675a2212";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChantingBloc(repository: SpiritualRepository())
            ..add(LoadChantingConfigs(categoryId: chantingCategoryId)),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<ChantingBloc, ChantingState>(
            listener: (context, state) {
              if (state is ChantingSessionReady) {
                // Navigate to Mantra Chanting
                Get.toNamed(
                  AppConstants.routeMantraChanting,
                  arguments: {
                    'emotion': state.config.emotion,
                    'count': state.count,
                    'configuration': state.config,
                    // Pass audioUrl to MantraChanting
                    'audioUrl': state.audioUrl,
                    'videoUrl': state.videoUrl, // Optional
                    // Passing these for safety
                    'mantra_title': state.config.chantingType,
                    'karma_points': state.config.karmaPoints,
                  },
                );
              } else if (state is ChantingError) {
                Utils.showToast(state.message);
              }
            },
            builder: (context, state) {
              if (state is ChantingLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ChantingLoaded || state is ChantingSessionReady) {
                // Even if ready, we show the loaded UI until navigation happens
                final loadedState = state is ChantingLoaded
                    ? state
                    // Fallback using data from SessionReady if needed, but Bloc doesn't guarantee 'state' preserves old data unless we structured it.
                    // Actually, SessionReady doesn't hold list.
                    // Issue: If we emit SessionReady, build is called. SessionReady has NO config list.
                    // Fix: ChantingSessionReady should probably extend ChantingLoaded or hold the previous loaded state to avoid UI flicker.
                    // For now, let's just show a loader or empty container if SessionReady is emitted, assuming navigation is fast.
                    // Or better, let's keep showing the UI if we can.
                    // But SessionReady doesn't have the lists.
                    : null;

                if (loadedState == null) {
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
                                  'CHANTING',
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
                                _buildMantraSelector(context, loadedState),
                                const SizedBox(height: 30),
                                _buildCountSelector(context, loadedState),
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
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                        ),
                      ),
                  ],
                );
              }

              if (state is ChantingError) {
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
              color: Colors.white.withValues(alpha: 0.05),
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
              color: Colors.white.withValues(alpha: 0.05),
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

  Widget _buildEmotionSelector(BuildContext context, ChantingLoaded state) {
    return SizedBox(
      height: 110,
      child: _EmotionList(
        selectedEmotion: state.selectedEmotion,
        onSelect: (emotion) {
          context.read<ChantingBloc>().add(SelectChantingEmotion(emotion));
        },
      ),
    );
  }

  Widget _buildMantraSelector(BuildContext context, ChantingLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Dark Background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
                  Icons.music_note_rounded,
                  size: 16,
                  color: const Color(0xFFD4AF37), // Gold icon
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Mantra',
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
                  "No mantras available for this mood.",
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
                      context.read<ChantingBloc>().add(
                        SelectChantingMantra(config),
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
                            _getDisplayMantraText(config),
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

  String _getDisplayMantraText(SpiritualConfiguration config) {
    if (config.chantingType != null &&
        config.chantingType!.isNotEmpty &&
        config.chantingType != "Other") {
      return config.chantingType!;
    } else if (config.customChantingType != null &&
        config.customChantingType!.isNotEmpty) {
      return config.customChantingType!;
    }
    return "Mantra";
  }

  Widget _buildCountSelector(BuildContext context, ChantingLoaded state) {
    const List<int> availableCounts = [27, 51, 108, 216, 324, 434, 540, 646];
    final selected = state.selectedCount;
    // Safely find index or default to 108's index or 0
    double currentIndex = availableCounts.indexOf(selected).toDouble();
    if (currentIndex < 0) currentIndex = 2.0; // 108

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Dark Background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
                  Icons.repeat,
                  size: 16,
                  color: const Color(0xFFD4AF37), // Gold icon
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Select Count',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Column(
            children: [
              CustomFluidSlider(
                valueIndex: currentIndex.toInt(),
                itemCount: availableCounts.length,
                labelBuilder: (i) => '${availableCounts[i]}',
                onChanged: (index) {
                  if (index >= 0 && index < availableCounts.length) {
                    context.read<ChantingBloc>().add(
                      SelectChantingCount(availableCounts[index]),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${availableCounts.first}',
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      '${availableCounts.last}',
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, ChantingLoaded state) {
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
                    ? (ChantingBloc.emotionEmojis[state.selectedEmotion] ?? '😐')
                    : '😐',
                'Mood',
              ),
              const SizedBox(width: 32),
              _summaryChip('📿', '${state.selectedCount} Counts'),
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

  Widget _buildStartButton(BuildContext context, ChantingLoaded state) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFD4AF37), // Gold Button
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<ChantingBloc>().add(const StartChantingSession());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black, // Dark text on gold
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
      final emotions = ChantingBloc.emotionEmojis.keys.toList();
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
      itemCount: ChantingBloc.emotionEmojis.length,
      itemBuilder: (context, index) {
        final entry = ChantingBloc.emotionEmojis.entries.elementAt(index);
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
                      color: Colors.black12,
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
                        color: isSelected ? const Color(0xFFD4AF37) : Colors.white54,
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

