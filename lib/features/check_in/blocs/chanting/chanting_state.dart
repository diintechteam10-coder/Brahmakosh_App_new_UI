part of 'chanting_bloc.dart';

abstract class ChantingState extends Equatable {
  const ChantingState();

  @override
  List<Object?> get props => [];
}

class ChantingInitial extends ChantingState {}

class ChantingLoading extends ChantingState {}

class ChantingLoaded extends ChantingState {
  final List<SpiritualConfiguration> allConfigurations;
  final List<SpiritualConfiguration> filteredConfigurations;
  final String? selectedEmotion;
  final SpiritualConfiguration? selectedConfig;
  final int selectedCount;
  final bool isStarting; // Loading state for starting session

  const ChantingLoaded({
    required this.allConfigurations,
    required this.filteredConfigurations,
    this.selectedEmotion,
    this.selectedConfig,
    required this.selectedCount,
    this.isStarting = false,
  });

  ChantingLoaded copyWith({
    List<SpiritualConfiguration>? allConfigurations,
    List<SpiritualConfiguration>? filteredConfigurations,
    String? selectedEmotion,
    SpiritualConfiguration? selectedConfig,
    int? selectedCount,
    bool? isStarting,
  }) {
    return ChantingLoaded(
      allConfigurations: allConfigurations ?? this.allConfigurations,
      filteredConfigurations:
          filteredConfigurations ?? this.filteredConfigurations,
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      selectedCount: selectedCount ?? this.selectedCount,
      isStarting: isStarting ?? this.isStarting,
    );
  }

  @override
  List<Object?> get props => [
    allConfigurations,
    filteredConfigurations,
    selectedEmotion,
    selectedConfig,
    selectedCount,
    isStarting,
  ];
}

class ChantingSessionReady extends ChantingState {
  final SpiritualConfiguration config;
  final int count;
  final String? audioUrl;
  final String? videoUrl;

  const ChantingSessionReady({
    required this.config,
    required this.count,
    this.audioUrl,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [config, count, audioUrl, videoUrl];
}

class ChantingError extends ChantingState {
  final String message;
  const ChantingError(this.message);

  @override
  List<Object> get props => [message];
}
