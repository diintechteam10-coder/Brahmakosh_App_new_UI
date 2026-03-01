import 'package:equatable/equatable.dart';
import '../models/sankalp_model.dart';
import '../models/sankalp_progress_model.dart';

abstract class SankalpState extends Equatable {
  const SankalpState();

  @override
  List<Object?> get props => [];
}

class SankalpInitial extends SankalpState {}

class SankalpLoading extends SankalpState {}

class SankalpLoaded extends SankalpState {
  final List<SankalpModel> availableSankalps;
  final List<UserSankalpModel> userSankalps;
  final SankalpModel? selectedSankalp;
  final bool isDetailLoading;

  const SankalpLoaded({
    this.availableSankalps = const [],
    this.userSankalps = const [],
    this.selectedSankalp,
    this.isDetailLoading = false,
  });

  SankalpLoaded copyWith({
    List<SankalpModel>? availableSankalps,
    List<UserSankalpModel>? userSankalps,
    SankalpModel? selectedSankalp,
    bool? isDetailLoading,
  }) {
    return SankalpLoaded(
      availableSankalps: availableSankalps ?? this.availableSankalps,
      userSankalps: userSankalps ?? this.userSankalps,
      selectedSankalp: selectedSankalp ?? this.selectedSankalp,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
    );
  }

  @override
  List<Object?> get props => [
    availableSankalps,
    userSankalps,
    selectedSankalp,
    isDetailLoading,
  ];
}

class SankalpOperationSuccess extends SankalpState {
  final String message;

  const SankalpOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SankalpError extends SankalpState {
  final String message;

  const SankalpError(this.message);

  @override
  List<Object?> get props => [message];
}

class SankalpProgressLoaded extends SankalpState {
  final SankalpProgressModel progressData;

  const SankalpProgressLoaded(this.progressData);

  @override
  List<Object?> get props => [progressData];
}
