import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_session_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';

part 'meditation_session_event.dart';
part 'meditation_session_state.dart';

class MeditationSessionBloc
    extends Bloc<MeditationSessionEvent, MeditationSessionState> {
  final SpiritualRepository repository;

  MeditationSessionBloc({required this.repository}) : super(SessionInitial()) {
    on<SaveSession>(_onSaveSession);
  }

  Future<void> _onSaveSession(
    SaveSession event,
    Emitter<MeditationSessionState> emit,
  ) async {
    emit(SessionSaving());
    try {
      final response = await repository.saveSession(event.request);
      emit(SessionSaved(response));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
}
