import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/gita_repository.dart';
import 'gita_chapter_event.dart';
import 'gita_chapter_state.dart';

class GitaChapterBloc extends Bloc<GitaChapterEvent, GitaChapterState> {
  final GitaRepository _repository;

  GitaChapterBloc({required GitaRepository repository})
    : _repository = repository,
      super(GitaChapterInitial()) {
    on<FetchGitaChapters>(_onFetchGitaChapters);
  }

  Future<void> _onFetchGitaChapters(
    FetchGitaChapters event,
    Emitter<GitaChapterState> emit,
  ) async {
    emit(GitaChapterLoading());
    try {
      final chapters = await _repository.getChapters();
      emit(GitaChapterLoaded(chapters));
    } catch (e) {
      emit(GitaChapterError(e.toString()));
    }
  }
}
