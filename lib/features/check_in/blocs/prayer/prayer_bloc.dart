import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:collection/collection.dart'; // for firstWhereOrNull

part 'prayer_event.dart';
part 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final SpiritualRepository repository;
  static const String _cacheKey = 'prayer_configurations_cache';

  // Static emotion map for UI (Emojis) - Reusing from ChantingBloc logic
  static const Map<String, String> emotionEmojis = {
    'Loved': '🥰',
    'Surprised': '😲',
    'Calm': '😌',
    'Happy': '😊',
    'Stressed': '😣',
    'Neutral': '😐',
    'Sad': '😢',
    'Angry': '😠',
    'Afraid': '😨',
    'Disgusted': '🤢',
  };

  PrayerBloc({required this.repository}) : super(PrayerInitial()) {
    on<LoadPrayerConfigs>(_onLoadConfigs);
    on<SelectPrayerEmotion>(_onSelectEmotion);
    on<SelectPrayerMantra>(_onSelectMantra);
    on<StartPrayerSession>(_onStartSession);
  }

  Future<void> _onLoadConfigs(
    LoadPrayerConfigs event,
    Emitter<PrayerState> emit,
  ) async {
    emit(PrayerLoading());

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

      // ═══════════════════════════════════════════════════════════════
      // 🚨 DEBUG LOG: PRAYER API RESPONSE
      // ═══════════════════════════════════════════════════════════════
      print('🚨 DEBUG_PRAYER: ─────────────────────────────────────────');
      print('🚨 DEBUG_PRAYER: CategoryId = ${event.categoryId}');
      print('🚨 DEBUG_PRAYER: success = ${response?.success}');
      print('🚨 DEBUG_PRAYER: Total items = ${response?.data?.length ?? 0}');
      if (response?.data != null) {
        final byCategory = <String, List<dynamic>>{};
        for (final c in response!.data!) {
          final cat = c.category ?? 'Uncategorised';
          byCategory.putIfAbsent(cat, () => []).add(c);
        }
        print('🚨 DEBUG_PRAYER: Categories (${byCategory.keys.length}):');
        byCategory.forEach((cat, items) {
          print('   📂 $cat (${items.length} items)');
          for (final item in items) {
            print('      • [${item.sId}] ${item.title ?? item.chantingType ?? "(no title)"} | duration=${item.duration} | emotion=${item.emotion} | karma=${item.karmaPoints} | subcategory=${item.subcategory}');
          }
        });
      }
      print('🚨 DEBUG_PRAYER: ─────────────────────────────────────────');
      // ═══════════════════════════════════════════════════════════════

      if (response != null &&
          response.success == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        configs = response.data!;
        // Update Cache
        _cacheConfigToDisk(configs);

        _initializeState(emit, configs);
      } else if (configs.isEmpty) {
        _emitFallback(emit);
      }
    } catch (e) {
      if (configs.isEmpty) {
        _emitFallback(emit);
      }
    }
  }

  Future<void> _cacheConfigToDisk(List<SpiritualConfiguration> configs) async {
    try {
      // We only cache the list
      final jsonList = configs.map((e) => e.toJson()).toList();
      await StorageService.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      print("PrayerBloc Cache Error: $e");
    }
  }

  void _initializeState(
    Emitter<PrayerState> emit,
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
    }

    final filtered = _filterByEmotion(configs, initialEmotion);
    final initialConfig = filtered.isNotEmpty ? filtered.first : null;

    emit(
      PrayerLoaded(
        allConfigurations: configs,
        filteredConfigurations: filtered,
        selectedEmotion: initialEmotion,
        selectedConfig: initialConfig,
      ),
    );
  }

  void _emitFallback(Emitter<PrayerState> emit) {
    // Fallback if needed, though mostly we expect data
    // For Prayer, let's just emit empty or specific fallback if configured
    emit(PrayerError("No configurations found"));
  }

  Future<void> _onSelectEmotion(
    SelectPrayerEmotion event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is PrayerLoaded) {
      final current = state as PrayerLoaded;

      final filtered = _filterByEmotion(
        current.allConfigurations,
        event.emotion,
      );
      final newSelectedConfig = filtered.isNotEmpty ? filtered.first : null;

      emit(
        current.copyWith(
          selectedEmotion: event.emotion,
          filteredConfigurations: filtered,
          selectedConfig: newSelectedConfig,
        ),
      );
    }
  }

  Future<void> _onSelectMantra(
    SelectPrayerMantra event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is PrayerLoaded) {
      final current = state as PrayerLoaded;
      emit(current.copyWith(selectedConfig: event.config));
    }
  }

  Future<void> _onStartSession(
    StartPrayerSession event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is PrayerLoaded) {
      final current = state as PrayerLoaded;

      if (current.selectedConfig == null) {
        return;
      }

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
        }

        emit(
          PrayerSessionReady(
            config: current.selectedConfig!,
            audioUrl: audioUrl,
            videoUrl:
                (clipResponse?.data != null && clipResponse!.data!.isNotEmpty)
                ? clipResponse.data!.first.videoUrl
                : null,
          ),
        );
      } catch (e) {
        emit(current.copyWith(isStarting: false));
        print("Error fetching clips: $e");
        // Proceed without clip?
        emit(PrayerSessionReady(config: current.selectedConfig!));
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
