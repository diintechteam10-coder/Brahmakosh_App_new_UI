import 'package:equatable/equatable.dart';
import '../models/pooja_model.dart';

abstract class PoojaState extends Equatable {
  const PoojaState();

  @override
  List<Object> get props => [];
}

class PoojaInitial extends PoojaState {}

class PoojaLoading extends PoojaState {}

class PoojaLoaded extends PoojaState {
  final List<PoojaModel> poojas;
  final List<PoojaModel> filteredPoojas;
  final String selectedCategory;
  final String searchQuery;

  const PoojaLoaded({
    required this.poojas,
    required this.filteredPoojas,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [poojas, filteredPoojas, selectedCategory, searchQuery];
}

class PoojaDetailLoading extends PoojaState {}

class PoojaDetailLoaded extends PoojaState {
  final PoojaModel pooja;

  const PoojaDetailLoaded(this.pooja);

  @override
  List<Object> get props => [pooja];
}

class PoojaError extends PoojaState {
  final String message;

  const PoojaError(this.message);

  @override
  List<Object> get props => [message];
}
