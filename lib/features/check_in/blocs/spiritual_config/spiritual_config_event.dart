part of 'spiritual_config_bloc.dart';

abstract class SpiritualConfigEvent extends Equatable {
  const SpiritualConfigEvent();

  @override
  List<Object?> get props => [];
}

class LoadConfig extends SpiritualConfigEvent {
  final String categoryId;
  final SpiritualConfigurationResponse? preFetchedData;

  const LoadConfig({required this.categoryId, this.preFetchedData});

  @override
  List<Object?> get props => [categoryId, preFetchedData];
}

class SelectEmotion extends SpiritualConfigEvent {
  final String emotion;
  const SelectEmotion(this.emotion);

  @override
  List<Object> get props => [emotion];
}

class SelectDuration extends SpiritualConfigEvent {
  final int duration;
  const SelectDuration(this.duration);

  @override
  List<Object> get props => [duration];
}

class StartSession extends SpiritualConfigEvent {}
