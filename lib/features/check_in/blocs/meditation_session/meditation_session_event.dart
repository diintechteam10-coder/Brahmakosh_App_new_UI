part of 'meditation_session_bloc.dart';

abstract class MeditationSessionEvent extends Equatable {
  const MeditationSessionEvent();
  @override
  List<Object> get props => [];
}

class SaveSession extends MeditationSessionEvent {
  final SpiritualSessionRequest request;
  const SaveSession(this.request);
  @override
  List<Object> get props => [request];
}
