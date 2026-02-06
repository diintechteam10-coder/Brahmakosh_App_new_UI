part of 'mantra_bloc.dart';

abstract class MantraState extends Equatable {
  const MantraState();

  @override
  List<Object?> get props => [];
}

class MantraInitial extends MantraState {}

class MantraSaving extends MantraState {}

class MantraSaved extends MantraState {
  final Map<String, dynamic> responseData;

  const MantraSaved(this.responseData);

  @override
  List<Object> get props => [responseData];
}

class MantraError extends MantraState {
  final String message;

  const MantraError(this.message);

  @override
  List<Object> get props => [message];
}
