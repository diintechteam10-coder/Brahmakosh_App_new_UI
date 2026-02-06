import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_session_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';

part 'mantra_event.dart';
part 'mantra_state.dart';

class MantraBloc extends Bloc<MantraEvent, MantraState> {
  final SpiritualRepository repository;

  MantraBloc({required this.repository}) : super(MantraInitial()) {
    on<SaveMantraSession>(_onSaveSession);
  }

  Future<void> _onSaveSession(
    SaveMantraSession event,
    Emitter<MantraState> emit,
  ) async {
    emit(MantraSaving());

    try {
      final result = await repository.saveSession(event.sessionData);

      // Check success based on response structure
      // Expected: { success: true, data: { ... } }
      if (result['success'] == true) {
        emit(MantraSaved(result));
      } else {
        emit(MantraError(result['message'] ?? 'Failed to save session'));
      }
    } catch (e) {
      emit(MantraError(e.toString()));
    }
  }
}
