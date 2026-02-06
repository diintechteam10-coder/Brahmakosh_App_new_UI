import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/gita_repository.dart';
import 'gita_verse_event.dart';
import 'gita_verse_state.dart';

class GitaVerseBloc extends Bloc<GitaVerseEvent, GitaVerseState> {
  final GitaRepository _repository;

  GitaVerseBloc({required GitaRepository repository})
    : _repository = repository,
      super(GitaVerseInitial()) {
    on<FetchGitaVerses>(_onFetchGitaVerses);
  }

  Future<void> _onFetchGitaVerses(
    FetchGitaVerses event,
    Emitter<GitaVerseState> emit,
  ) async {
    emit(GitaVerseLoading());
    try {
      final verses = await _repository.getVerses(event.chapterNumber);
      emit(GitaVerseLoaded(verses));
    } catch (e) {
      emit(GitaVerseError(e.toString()));
    }
  }
}
