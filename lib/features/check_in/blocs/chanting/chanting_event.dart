part of 'chanting_bloc.dart';

abstract class ChantingEvent extends Equatable {
  const ChantingEvent();

  @override
  List<Object?> get props => [];
}

class LoadChantingConfigs extends ChantingEvent {
  final String categoryId;
  const LoadChantingConfigs({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}

class SelectChantingEmotion extends ChantingEvent {
  final String emotion;
  const SelectChantingEmotion(this.emotion);

  @override
  List<Object> get props => [emotion];
}

class SelectChantingMantra extends ChantingEvent {
  final SpiritualConfiguration config;
  const SelectChantingMantra(this.config);

  @override
  List<Object> get props => [config];
}

class SelectChantingCount extends ChantingEvent {
  final int count;
  const SelectChantingCount(this.count);

  @override
  List<Object> get props => [count];
}

class StartChantingSession extends ChantingEvent {
  const StartChantingSession();
}
