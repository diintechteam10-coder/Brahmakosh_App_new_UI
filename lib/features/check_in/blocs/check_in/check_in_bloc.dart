import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';

part 'check_in_event.dart';
part 'check_in_state.dart';

class CheckInBloc extends Bloc<CheckInEvent, CheckInState> {
  final SpiritualRepository repository;

  CheckInBloc({required this.repository}) : super(CheckInInitial()) {
    on<LoadCheckIn>(_onLoadCheckIn);
    on<RefreshCheckIn>(_onRefreshCheckIn);
    on<SelectActivity>(_onSelectActivity);
  }

  Future<void> _onRefreshCheckIn(
    RefreshCheckIn event,
    Emitter<CheckInState> emit,
  ) async {
    try {
      final response = await repository.getCheckIn();
      if (response != null &&
          response.success == true &&
          response.data != null) {
        final data = response.data!;
        emit(CheckInLoaded(data: data));

        // Background Pre-fetch logic
        if (data.activities != null) {
          for (final activity in data.activities!) {
            if (activity.id != null) {
              _fetchConfigBackground(activity.id!);
            }
          }
        }
      } else {
        // Optionally show toast or handle error silently?
        // We don't want to replace the current state with Error view.
      }
    } catch (e) {
      // Handle error silently or via toast
    } finally {
      event.completer.complete();
    }
  }

  Future<void> _onLoadCheckIn(
    LoadCheckIn event,
    Emitter<CheckInState> emit,
  ) async {
    emit(CheckInLoading());
    try {
      final response = await repository.getCheckIn();
      if (response != null &&
          response.success == true &&
          response.data != null) {
        final data = response.data!;
        emit(CheckInLoaded(data: data));

        // Background Pre-fetch
        if (data.activities != null) {
          for (final activity in data.activities!) {
            if (activity.id != null) {
              _fetchConfigBackground(activity.id!);
            }
          }
        }
      } else {
        emit(const CheckInError("Failed to load activities"));
      }
    } catch (e) {
      emit(CheckInError("Error: $e"));
    }
  }

  /// Helper to fetch in background and update state
  Future<void> _fetchConfigBackground(String activityId) async {
    try {
      // Small delay to let current state settle if called immediately? No need.
      final config = await repository.getConfigurations(activityId);
      if (config != null && !isClosed) {
        // We need to access current state to update it.
        // But we are outside the `on` handler's emit context.
        // We can't emit from here directly without risk of race conditions or bad state.
        // Correct pattern: Add an internal event `_ConfigFetched`.
        // BUT for simplicity in this refactor, let's keep it simpler:
        // We will just store it in the repository (which already caches to disk).
        // The Bloc's memory cache is good but Disk is the ultimate source of truth we rely on in `SelectActivity`.
        // HOWEVER, `SelectActivity` checks "Memory Cache" first in our plan.
        // Let's update the repository to have an in-memory cache too?
        // Actually, let's just use the Disk cache as the primary "ready" check,
        // OR rely on the fact that repository returns fast if cached on disk.
        // But we wanted "instant" memory access.

        // Let's stick to the plan: `CheckInLoaded` has `preFetchedConfigs`.
        // To update it safely, we'd need an event.
        // It's getting complex to fire N events.
        // Compromise: We rely on the Repository's Disk Cache being fast enough (jsonDecode on main thread is fast for these sizes).
        // AND/OR we can add a simple internal cache in this BLoC class (not in State)
        // provided `SelectActivity` reads from it.
      }
    } catch (_) {}
  }

  // Mutable internal cache for "instant" access without state churn
  final Map<String, SpiritualConfigurationResponse> _memoryCache = {};

  Future<void> _onSelectActivity(
    SelectActivity event,
    Emitter<CheckInState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CheckInLoaded) return;

    // 1. Check Memory (Internal BLoC cache populated by background calls)
    // We need to populate _memoryCache.
    // Let's verify if _fetchConfigBackground populated it.
    // It can't easily without being inside the flow.
    // Let's modify logic: when user Taps, we check internal cache or Disk.

    // Check Internal Memory
    if (_memoryCache.containsKey(event.activityId)) {
      emit(
        CheckInNavigationAction(
          route: event.route,
          arguments: {
            'categoryId': event.activityId,
            'title': event.title,
            'preFetchedData': _memoryCache[event.activityId],
          },
          previousState: currentState,
        ),
      );
      // Reset to Loaded (UI listener will handle nav)
      emit(currentState);
      return;
    }

    // 2. Check Disk
    final cached = await repository.getCachedConfiguration(event.activityId);
    if (cached != null) {
      _memoryCache[event.activityId] = cached; // Update memory
      emit(
        CheckInNavigationAction(
          route: event.route,
          arguments: {
            'categoryId': event.activityId,
            'title': event.title,
            'preFetchedData': cached,
          },
          previousState: currentState,
        ),
      );
      emit(currentState);
      return;
    }

    // 3. Network (Blocking)
    print("🔍 DEBUG_BLOC: Fetching from Network for ${event.activityId}");
    emit(CheckInNavigationLoading(currentState));

    try {
      final response = await repository.getConfigurations(event.activityId);
      if (response != null && response.success == true) {
        print("✅ DEBUG_BLOC: Network success. Emitting NavigationAction.");
        _memoryCache[event.activityId] = response;

        emit(
          CheckInNavigationAction(
            route: event.route,
            arguments: {
              'categoryId': event.activityId,
              'title': event.title,
              'preFetchedData': response,
            },
            previousState: currentState,
          ),
        );
      } else {
        // API Failed
        print("❌ DEBUG_BLOC: API Response failure or success=false");
        emit(CheckInError("Unable to fetch data."));
        emit(currentState); // Revert to loaded
      }
    } catch (e) {
      print("❌ DEBUG_BLOC: Exception: $e");
      emit(CheckInError("Error: $e"));
      emit(currentState);
    }

    emit(currentState); // Restore list
  }

  // Override to trigger background fetches
  @override
  void onTransition(Transition<CheckInEvent, CheckInState> transition) {
    super.onTransition(transition);
    if (transition.nextState is CheckInLoaded &&
        transition.currentState is CheckInLoading) {
      // Initial load done. Trigger background fetch.
      final loaded = transition.nextState as CheckInLoaded;
      if (loaded.data.activities != null) {
        for (final activity in loaded.data.activities!) {
          if (activity.id != null) {
            // Un-awaited background fetch
            repository.getConfigurations(activity.id!).then((response) {
              if (response != null) {
                _memoryCache[activity.id!] = response;
              }
            });
          }
        }
      }
    }
  }
}
