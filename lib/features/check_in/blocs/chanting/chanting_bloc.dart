import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:collection/collection.dart'; // for firstWhereOrNull

part 'chanting_event.dart';
part 'chanting_state.dart';

class ChantingBloc extends Bloc<ChantingEvent, ChantingState> {
  final SpiritualRepository repository;
  static const String _cacheKey = 'spiritual_configurations_cache';

  // Static emotion map for UI (Emojis)
  static const Map<String, String> emotionEmojis = {
    'Loved': '🥰',
    'Surprised': '😲',
    'Calm': '😌',
    'Happy': '😊',
    'Stressed': '😣', // UI uses "Stressed", API sends "stressed" or "stress"
    'Neutral': '😐',
    'Sad': '😢',
    'Angry': '😠',
    'Afraid': '😨',
    'Disgusted': '🤢',
  };

  ChantingBloc({required this.repository}) : super(ChantingInitial()) {
    on<LoadChantingConfigs>(_onLoadConfigs);
    on<SelectChantingEmotion>(_onSelectEmotion);
    on<SelectChantingMantra>(_onSelectMantra);
    on<SelectChantingCount>(_onSelectCount);
    on<StartChantingSession>(_onStartSession);
  }

  Future<void> _onLoadConfigs(
    LoadChantingConfigs event,
    Emitter<ChantingState> emit,
  ) async {
    emit(ChantingLoading());

    List<SpiritualConfiguration> configs = [];

    // 1. Try Cache
    try {
      final cachedData = StorageService.getString(_cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final jsonList = (jsonDecode(cachedData) as List)
            .cast<Map<String, dynamic>>();
        configs = jsonList
            .map((e) => SpiritualConfiguration.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error parsing cached configurations: $e");
    }

    if (configs.isNotEmpty) {
      _initializeState(emit, configs);
    }

    // 2. Fetch API
    try {
      final response = await repository.getConfigurations(event.categoryId);
      if (response != null &&
          response.success == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        configs = response.data!;
        // Update Cache
        // Note: Repository might already cache to disk, but sticking to controller pattern of Controller
        // Actually, Repository.getConfigurations already call _cacheConfigToDisk.
        // So we don't strictly need to do it here if Repository does it.
        // Repository uses 'cache_config_$categoryId'. Controller used 'spiritual_configurations_cache'.
        // Let's rely on Repository fetching it fresh.

        _initializeState(emit, configs);
      } else if (configs.isEmpty) {
        _emitFallback(emit);
      }
    } catch (e) {
      if (configs.isEmpty) {
        _emitFallback(emit);
      } else {
        // Keep showing cached data but maybe show toast?
        // Utils.showToast("Failed to refresh configurations");
        // Since we already emitted loaded state with cache, we can just return or emit error
        // But better to silently fail if we have cache.
      }
    }
  }

  void _initializeState(
    Emitter<ChantingState> emit,
    List<SpiritualConfiguration> configs,
  ) {
    // Logic to set initial emotion
    final availableEmotions = configs
        .map((e) => e.emotion)
        .where((e) => e != null)
        .toSet();

    String initialEmotion = 'Happy';

    if (availableEmotions.isNotEmpty) {
      bool hasHappy = availableEmotions.any((e) => e!.toLowerCase() == 'happy');
      if (hasHappy) {
        initialEmotion = 'Happy';
      } else {
        String? firstApiEmotion = availableEmotions.first!;
        String? matchedKey = emotionEmojis.keys.firstWhereOrNull(
          (k) => k.toLowerCase() == firstApiEmotion.toLowerCase(),
        );
        initialEmotion = matchedKey ?? firstApiEmotion;
      }
    } else {
      // Fallback if no emotions found?
      initialEmotion = 'Happy';
    }

    final filtered = _filterByEmotion(configs, initialEmotion);
    final initialConfig = filtered.isNotEmpty ? filtered.first : null;

    emit(
      ChantingLoaded(
        allConfigurations: configs,
        filteredConfigurations: filtered,
        selectedEmotion: initialEmotion,
        selectedConfig: initialConfig,
        selectedCount: 108, // Default
      ),
    );
  }

  void _emitFallback(Emitter<ChantingState> emit) {
    final fallback = SpiritualConfiguration(
      sId: "fallback_radhe",
      chantingType: "Radhe Radhe",
      emotion: "Happy",
      karmaPoints: 11,
      description: "Radhe Radhe Chanting",
      isActive: true,
    );
    emit(
      ChantingLoaded(
        allConfigurations: [fallback],
        filteredConfigurations: [fallback],
        selectedEmotion: "Happy",
        selectedConfig: fallback,
        selectedCount: 108,
      ),
    );
  }

  Future<void> _onSelectEmotion(
    SelectChantingEmotion event,
    Emitter<ChantingState> emit,
  ) async {
    if (state is ChantingLoaded) {
      final current = state as ChantingLoaded;

      // Don't do anything if emotion is same?
      // Actually user might tap again.
      // Filter list
      final filtered = _filterByEmotion(
        current.allConfigurations,
        event.emotion,
      );
      final newSelectedConfig = filtered.isNotEmpty ? filtered.first : null;

      emit(
        current.copyWith(
          selectedEmotion: event.emotion,
          filteredConfigurations: filtered,
          selectedConfig: newSelectedConfig, // Auto-select first
        ),
      );
    }
  }

  Future<void> _onSelectMantra(
    SelectChantingMantra event,
    Emitter<ChantingState> emit,
  ) async {
    if (state is ChantingLoaded) {
      final current = state as ChantingLoaded;
      emit(current.copyWith(selectedConfig: event.config));
    }
  }

  Future<void> _onSelectCount(
    SelectChantingCount event,
    Emitter<ChantingState> emit,
  ) async {
    if (state is ChantingLoaded) {
      final current = state as ChantingLoaded;
      emit(current.copyWith(selectedCount: event.count));
    }
  }

  Future<void> _onStartSession(
    StartChantingSession event,
    Emitter<ChantingState> emit,
  ) async {
    if (state is ChantingLoaded) {
      final current = state as ChantingLoaded;

      if (current.selectedConfig == null) {
        // Validation failed
        // We can emit error state or just handle it.
        // Here we just ignore or could emit error to show snackbar in listener
        return;
      }

      // 1. Emit Loading state (via isStarting)
      emit(current.copyWith(isStarting: true));

      try {
        final configId = current.selectedConfig!.sId!;
        final clipResponse = await repository.getClips(configId);

        String? audioUrl;
        if (clipResponse != null &&
            clipResponse.success == true &&
            clipResponse.data != null &&
            clipResponse.data!.isNotEmpty) {
          audioUrl = clipResponse.data!.first.audioUrl;
          // Log or debug
          print("Fetched Audio URL: $audioUrl");
        }

        // 2. Emit SessionReady
        emit(
          ChantingSessionReady(
            config: current.selectedConfig!,
            count: current.selectedCount,
            audioUrl: audioUrl,
            videoUrl:
                (clipResponse?.data != null && clipResponse!.data!.isNotEmpty)
                ? clipResponse.data!.first.videoUrl
                : null,
          ),
        );

        // Note: After this, UI listener handles navigation.
        // We might want to revert logic to Loaded after navigation or just stay there?
        // Since View is likely popped or replaced, BLoC might be closed.
        // If we come back, we reload?
      } catch (e) {
        emit(current.copyWith(isStarting: false)); // Stop loading
        // Emit logic to show error?
        // Maybe emit ChantingError? But that wipes screen.
        // Ideally should use a one-off event.
        // For now, print error.
        print("Error fetching clips: $e");

        // Proceed without clip?
        emit(
          ChantingSessionReady(
            config: current.selectedConfig!,
            count: current.selectedCount,
          ),
        );
      }
    }
  }

  List<SpiritualConfiguration> _filterByEmotion(
    List<SpiritualConfiguration> all,
    String emotion,
  ) {
    return all.where((config) {
      return config.emotion?.toLowerCase() == emotion.toLowerCase();
    }).toList();
  }
}
