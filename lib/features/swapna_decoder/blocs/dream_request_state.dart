import 'package:equatable/equatable.dart';
import '../models/dream_request_model.dart';

abstract class DreamRequestState extends Equatable {
  const DreamRequestState();

  @override
  List<Object?> get props => [];
}

class DreamRequestInitial extends DreamRequestState {}

class DreamRequestLoading extends DreamRequestState {}

class DreamRequestLoaded extends DreamRequestState {
  final List<DreamRequestModel> requests;

  const DreamRequestLoaded({required this.requests});

  @override
  List<Object> get props => [requests];
}

class DreamRequestSuccess extends DreamRequestState {
  final String message;

  const DreamRequestSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class DreamRequestDetailLoading extends DreamRequestState {}

class DreamRequestDetailLoaded extends DreamRequestState {
  final DreamRequestModel request;

  const DreamRequestDetailLoaded(this.request);

  @override
  List<Object> get props => [request];
}

class DreamRequestError extends DreamRequestState {
  final String message;

  const DreamRequestError(this.message);

  @override
  List<Object> get props => [message];
}
