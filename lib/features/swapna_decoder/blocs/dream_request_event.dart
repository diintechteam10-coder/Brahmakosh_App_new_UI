import 'package:equatable/equatable.dart';

abstract class DreamRequestEvent extends Equatable {
  const DreamRequestEvent();

  @override
  List<Object> get props => [];
}

class FetchDreamRequests extends DreamRequestEvent {}

class SubmitDreamRequest extends DreamRequestEvent {
  final String dreamSymbol;
  final String additionalDetails;
  final String clientId;

  const SubmitDreamRequest({
    required this.dreamSymbol,
    required this.additionalDetails,
    required this.clientId,
  });

  @override
  List<Object> get props => [dreamSymbol, additionalDetails, clientId];
}

class FetchDreamRequestDetail extends DreamRequestEvent {
  final String id;

  const FetchDreamRequestDetail(this.id);

  @override
  List<Object> get props => [id];
}
