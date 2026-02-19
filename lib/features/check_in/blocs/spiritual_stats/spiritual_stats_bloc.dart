import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_stats_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';

part 'spiritual_stats_event.dart';
part 'spiritual_stats_state.dart';

class SpiritualStatsBloc
    extends Bloc<SpiritualStatsEvent, SpiritualStatsState> {
  final SpiritualRepository repository;

  SpiritualStatsBloc({required this.repository})
    : super(SpiritualStatsInitial()) {
    on<LoadSpiritualStats>(_onLoadStats);
    on<RefreshSpiritualStats>(_onRefreshStats);
  }

  Future<void> _onLoadStats(
    LoadSpiritualStats event,
    Emitter<SpiritualStatsState> emit,
  ) async {
    emit(SpiritualStatsLoading());
    try {
      final response = await repository.getSpiritualStats();
      if (response != null &&
          response.success == true &&
          response.data != null) {
        // Check if profile image is missing
        String? profileImage = StorageService.getString(
          AppConstants.keyUserImage,
        );
        if (profileImage == null || profileImage.isEmpty) {
          // Fetch it
          profileImage = await repository.fetchUserProfileImage();
        }

        // Update model with image (even if null, to be consistent)
        if (response.data!.userDetails != null) {
          response.data!.userDetails!.profileImage = profileImage;
        }

        emit(SpiritualStatsLoaded(response.data!));
      } else {
        emit(const SpiritualStatsError("Failed to load spiritual statistics"));
      }
    } catch (e) {
      emit(SpiritualStatsError("Error: $e"));
    }
  }

  Future<void> _onRefreshStats(
    RefreshSpiritualStats event,
    Emitter<SpiritualStatsState> emit,
  ) async {
    try {
      final response = await repository.getSpiritualStats();
      if (response != null &&
          response.success == true &&
          response.data != null) {
        emit(SpiritualStatsLoaded(response.data!));
      }
    } catch (_) {
      // Keep current state on error during refresh
    } finally {
      event.completer.complete();
    }
  }
}
