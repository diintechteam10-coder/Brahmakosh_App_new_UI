part of 'mantra_bloc.dart';

abstract class MantraEvent extends Equatable {
  const MantraEvent();

  @override
  List<Object> get props => [];
}

class SaveMantraSession extends MantraEvent {
  final SpiritualSessionRequest sessionData;

  const SaveMantraSession(this.sessionData);

  @override
  List<Object> get props => [sessionData];
}
