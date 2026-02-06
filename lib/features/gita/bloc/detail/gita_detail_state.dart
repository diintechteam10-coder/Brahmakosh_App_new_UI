import 'package:equatable/equatable.dart';
import '../../data/models/verse_model.dart';

abstract class GitaDetailState extends Equatable {
  const GitaDetailState();

  @override
  List<Object> get props => [];
}

class GitaDetailInitial extends GitaDetailState {}

class GitaDetailLoading extends GitaDetailState {}

class GitaDetailLoaded extends GitaDetailState {
  final VerseModel verse;

  const GitaDetailLoaded(this.verse);

  @override
  List<Object> get props => [verse];
}

class GitaDetailError extends GitaDetailState {
  final String message;

  const GitaDetailError(this.message);

  @override
  List<Object> get props => [message];
}
