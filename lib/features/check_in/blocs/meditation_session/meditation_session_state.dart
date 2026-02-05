part of 'meditation_session_bloc.dart';

abstract class MeditationSessionState extends Equatable {
  const MeditationSessionState();
  @override
  List<Object> get props => [];
}

class SessionInitial extends MeditationSessionState {}

class SessionSaving extends MeditationSessionState {}

class SessionSaved extends MeditationSessionState {
  final Map<String, dynamic> response;
  const SessionSaved(this.response);
  @override
  List<Object> get props => [response];
}

class SessionError extends MeditationSessionState {
  final String message;
  const SessionError(this.message);
  @override
  List<Object> get props => [message];
}
