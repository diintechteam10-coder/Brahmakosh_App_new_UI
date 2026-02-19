import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/sankalp_model.dart';
import '../repositories/sankalp_repository.dart';
import 'sankalp_event.dart';
import 'sankalp_state.dart';

class SankalpBloc extends Bloc<SankalpEvent, SankalpState> {
  final SankalpRepository repository;

  SankalpBloc({required this.repository}) : super(SankalpInitial()) {
    on<FetchAvailableSankalps>(_onFetchAvailableSankalps);
    on<FetchUserSankalps>(_onFetchUserSankalps);
    on<JoinSankalp>(_onJoinSankalp);
    on<ReportDailyStatus>(_onReportDailyStatus);
    on<FetchSankalpDetail>(_onFetchSankalpDetail);
    on<FetchSankalpProgress>(_onFetchSankalpProgress);
  }

  Future<void> _onFetchAvailableSankalps(
    FetchAvailableSankalps event,
    Emitter<SankalpState> emit,
  ) async {
    // If we are already loaded, we want to keep current data while loading?
    // Or simpler: just emit loading if it's a fresh fetch.
    // Let's emit Loading for now to show spinner.
    // Better pattern: if state is Loaded, start with that data.
    List<dynamic> currentAvailable = [];
    List<dynamic> currentUser = [];

    if (state is SankalpLoaded) {
      currentAvailable = (state as SankalpLoaded).availableSankalps;
      currentUser = (state as SankalpLoaded).userSankalps;
      // We don't emit Loading here to prevent UI flicker if we want background refresh
      // But typically for "screen load" we want loading.
    } else {
      emit(SankalpLoading());
    }

    try {
      final sankalps = await repository.fetchAvailableSankalps();

      // If we had user sankalps, keep them
      final List<UserSankalpModel> userSankalps = state is SankalpLoaded
          ? (state as SankalpLoaded).userSankalps
          : [];

      emit(
        SankalpLoaded(availableSankalps: sankalps, userSankalps: userSankalps),
      );
    } catch (e) {
      emit(SankalpError(e.toString()));
    }
  }

  Future<void> _onFetchUserSankalps(
    FetchUserSankalps event,
    Emitter<SankalpState> emit,
  ) async {
    if (state is! SankalpLoaded) {
      emit(SankalpLoading());
    }

    try {
      final userSankalps = await repository.fetchUserSankalps();
      final List<SankalpModel> availableSankalps = state is SankalpLoaded
          ? (state as SankalpLoaded).availableSankalps
          : [];

      emit(
        SankalpLoaded(
          availableSankalps: availableSankalps,
          userSankalps: userSankalps,
        ),
      );
    } catch (e) {
      emit(SankalpError(e.toString()));
    }
  }

  Future<void> _onJoinSankalp(
    JoinSankalp event,
    Emitter<SankalpState> emit,
  ) async {
    // We might want to show a loading dialog or state
    // But since this is an action, we usually rely on UI to show loader
    // or we emit a specific "Joining" state if we want.
    // Simplest: just do it and then refresh user sankalps.
    try {
      await repository.joinSankalp(
        sankalpId: event.sankalpId,
        customDays: event.customDays,
        reminderTime: event.reminderTime,
      );
      // After joining, refresh user sankalps
      add(FetchUserSankalps());
      emit(const SankalpOperationSuccess("Successfully joined Sankalp"));
      // Note: The UI should listen for Success to navigate or show snackbar,
      // then we might want to go back to Loaded state?
      // Actually, add(FetchUserSankalps) will trigger a new emission eventually.
    } catch (e) {
      emit(SankalpError(e.toString()));
    }
  }

  Future<void> _onReportDailyStatus(
    ReportDailyStatus event,
    Emitter<SankalpState> emit,
  ) async {
    try {
      final result = await repository.reportDailyStatus(
        event.userSankalpId,
        event.status,
      );

      if (result['success'] == true) {
        add(FetchUserSankalps());
        // We can pass the full data if we want to show motivation message in UI
        // For now, passing the message is good.
        // If we want to show a custom dialog with motivation, we might need a custom State
        // or just pass it in the message or a new field in Success state.
        // Let's stick to standard Success for now, UI can fetch fresh data or we can assume message has it.
        emit(SankalpOperationSuccess(result['message']));
      } else {
        emit(SankalpError(result['message']));
      }
    } catch (e) {
      emit(SankalpError("An error occurred: $e"));
    }
  }

  Future<void> _onFetchSankalpDetail(
    FetchSankalpDetail event,
    Emitter<SankalpState> emit,
  ) async {
    if (state is SankalpLoaded) {
      emit((state as SankalpLoaded).copyWith(isDetailLoading: true));
    }

    try {
      final sankalp = await repository.fetchSankalpDetail(event.sankalpId);

      if (sankalp == null) {
        emit(const SankalpError("Failed to fetch Sankalp details"));
        // restore loaded state with previous data if needed, or stay in error
        // But since we might be on a previous screen, Error state might be okay to show snackbar
        if (state is SankalpLoaded) {
          // Re-emit loaded but with error message?
          // Current architecture handles SankalpError as a separate state.
          // If we want to keep the list visible while showing error, we need a different approach.
          // But for now, let's just emit Error so UI can handle it.
          // Actually, looking at UI, if state is SankalpError, it shows error text.
          // Ideally we want to stay on the list (if we are there) and show a snackbar.
          // The UI uses BlocConsumer to show snackbar on Error.
        }
      } else {
        if (state is SankalpLoaded) {
          emit(
            (state as SankalpLoaded).copyWith(
              selectedSankalp: sankalp,
              isDetailLoading: false,
            ),
          );
        } else {
          // Should not happen usually if we flow correctly, but safe fallback
          emit(
            SankalpLoaded(
              availableSankalps: [],
              userSankalps: [],
              selectedSankalp: sankalp,
            ),
          );
        }
      }
    } catch (e) {
      emit(SankalpError("Error fetching details: $e"));
    }
  }

  Future<void> _onFetchSankalpProgress(
    FetchSankalpProgress event,
    Emitter<SankalpState> emit,
  ) async {
    emit(SankalpLoading());
    try {
      final progress = await repository.fetchSankalpProgress(
        event.userSankalpId,
      );
      if (progress != null) {
        emit(SankalpProgressLoaded(progress));
      } else {
        emit(const SankalpError("Failed to fetch Sankalp progress"));
      }
    } catch (e) {
      emit(SankalpError("Error fetching progress: $e"));
    }
  }
}
