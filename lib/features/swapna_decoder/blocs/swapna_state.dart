import 'package:equatable/equatable.dart';
import '../models/swapna_model.dart';

abstract class SwapnaState extends Equatable {
  const SwapnaState();

  @override
  List<Object?> get props => [];
}

class SwapnaInitial extends SwapnaState {}

class SwapnaLoading extends SwapnaState {}

class SwapnaLoaded extends SwapnaState {
  final List<SwapnaModel> swapnas;

  const SwapnaLoaded({required this.swapnas});

  @override
  List<Object> get props => [swapnas];
}

class SwapnaDetailLoading extends SwapnaState {}

class SwapnaDetailLoaded extends SwapnaState {
  final SwapnaModel swapna;

  const SwapnaDetailLoaded(this.swapna);

  @override
  List<Object> get props => [swapna];
}

class SwapnaError extends SwapnaState {
  final String message;

  const SwapnaError(this.message);

  @override
  List<Object> get props => [message];
}
