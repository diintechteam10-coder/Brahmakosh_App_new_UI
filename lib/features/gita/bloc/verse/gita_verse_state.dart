import 'package:equatable/equatable.dart';
import '../../data/models/verse_model.dart';

abstract class GitaVerseState extends Equatable {
  const GitaVerseState();

  @override
  List<Object> get props => [];
}

class GitaVerseInitial extends GitaVerseState {}

class GitaVerseLoading extends GitaVerseState {}

class GitaVerseLoaded extends GitaVerseState {
  final List<VerseModel> verses;

  const GitaVerseLoaded(this.verses);

  @override
  List<Object> get props => [verses];
}

class GitaVerseError extends GitaVerseState {
  final String message;

  const GitaVerseError(this.message);

  @override
  List<Object> get props => [message];
}
