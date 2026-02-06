import 'package:equatable/equatable.dart';

abstract class GitaDetailEvent extends Equatable {
  const GitaDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchGitaVerseDetail extends GitaDetailEvent {
  final String verseId;

  const FetchGitaVerseDetail(this.verseId);

  @override
  List<Object> get props => [verseId];
}
