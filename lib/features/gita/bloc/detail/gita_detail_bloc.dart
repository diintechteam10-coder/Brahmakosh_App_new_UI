import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/gita_repository.dart';
import 'gita_detail_event.dart';
import 'gita_detail_state.dart';

class GitaDetailBloc extends Bloc<GitaDetailEvent, GitaDetailState> {
  final GitaRepository _repository;

  GitaDetailBloc({required GitaRepository repository})
    : _repository = repository,
      super(GitaDetailInitial()) {
    on<FetchGitaVerseDetail>(_onFetchGitaVerseDetail);
  }

  Future<void> _onFetchGitaVerseDetail(
    FetchGitaVerseDetail event,
    Emitter<GitaDetailState> emit,
  ) async {
    emit(GitaDetailLoading());
    try {
      final verse = await _repository.getVerseDetail(event.verseId);
      if (verse != null) {
        emit(GitaDetailLoaded(verse));
      } else {
        emit(const GitaDetailError('Verse not found'));
      }
    } catch (e) {
      emit(GitaDetailError(e.toString()));
    }
  }
}
