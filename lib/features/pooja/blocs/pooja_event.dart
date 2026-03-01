import 'package:equatable/equatable.dart';

abstract class PoojaEvent extends Equatable {
  const PoojaEvent();

  @override
  List<Object> get props => [];
}

class FetchPoojas extends PoojaEvent {}

class FetchPoojaDetail extends PoojaEvent {
  final String id;

  const FetchPoojaDetail(this.id);

  @override
  List<Object> get props => [id];
}

class FilterPoojas extends PoojaEvent {
  final String category; // 'All' or 'Festival' or others

  const FilterPoojas(this.category);

  @override
  List<Object> get props => [category];
}
