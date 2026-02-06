import 'package:equatable/equatable.dart';
import '../../data/models/chapter_model.dart';

abstract class GitaChapterState extends Equatable {
  const GitaChapterState();

  @override
  List<Object> get props => [];
}

class GitaChapterInitial extends GitaChapterState {}

class GitaChapterLoading extends GitaChapterState {}

class GitaChapterLoaded extends GitaChapterState {
  final List<ChapterModel> chapters;

  const GitaChapterLoaded(this.chapters);

  @override
  List<Object> get props => [chapters];
}

class GitaChapterError extends GitaChapterState {
  final String message;

  const GitaChapterError(this.message);

  @override
  List<Object> get props => [message];
}
