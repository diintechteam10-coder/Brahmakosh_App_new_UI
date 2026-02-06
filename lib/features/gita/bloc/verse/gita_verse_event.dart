import 'package:equatable/equatable.dart';

abstract class GitaVerseEvent extends Equatable {
  const GitaVerseEvent();

  @override
  List<Object> get props => [];
}

class FetchGitaVerses extends GitaVerseEvent {
  final int chapterNumber;

  const FetchGitaVerses(this.chapterNumber);

  @override
  List<Object> get props => [chapterNumber];
}
