part of 'prayer_bloc.dart';

abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final List<SpiritualConfiguration> allConfigurations;
  final List<SpiritualConfiguration> filteredConfigurations;
  final String? selectedEmotion;
  final SpiritualConfiguration? selectedConfig;
  final bool isStarting; // Loading state for starting session

  const PrayerLoaded({
    required this.allConfigurations,
    required this.filteredConfigurations,
    this.selectedEmotion,
    this.selectedConfig,
    this.isStarting = false,
  });

  PrayerLoaded copyWith({
    List<SpiritualConfiguration>? allConfigurations,
    List<SpiritualConfiguration>? filteredConfigurations,
    String? selectedEmotion,
    SpiritualConfiguration? selectedConfig,
    bool? isStarting,
  }) {
    return PrayerLoaded(
      allConfigurations: allConfigurations ?? this.allConfigurations,
      filteredConfigurations:
          filteredConfigurations ?? this.filteredConfigurations,
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      isStarting: isStarting ?? this.isStarting,
    );
  }

  @override
  List<Object?> get props => [
    allConfigurations,
    filteredConfigurations,
    selectedEmotion,
    selectedConfig,
    isStarting,
  ];
}

class PrayerSessionReady extends PrayerState {
  final SpiritualConfiguration config;
  final String? audioUrl;
  final String? videoUrl;

  const PrayerSessionReady({
    required this.config,
    this.audioUrl,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [config, audioUrl, videoUrl];
}

class PrayerError extends PrayerState {
  final String message;
  const PrayerError(this.message);

  @override
  List<Object> get props => [message];
}
