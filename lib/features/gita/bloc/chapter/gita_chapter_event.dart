import 'package:equatable/equatable.dart';

abstract class GitaChapterEvent extends Equatable {
  const GitaChapterEvent();

  @override
  List<Object> get props => [];
}

class FetchGitaChapters extends GitaChapterEvent {}
