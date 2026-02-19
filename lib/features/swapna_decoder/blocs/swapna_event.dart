import 'package:equatable/equatable.dart';

abstract class SwapnaEvent extends Equatable {
  const SwapnaEvent();

  @override
  List<Object> get props => [];
}

class FetchSwapnaList extends SwapnaEvent {}

class FetchSwapnaDetail extends SwapnaEvent {
  final String id;

  const FetchSwapnaDetail(this.id);

  @override
  List<Object> get props => [id];
}
