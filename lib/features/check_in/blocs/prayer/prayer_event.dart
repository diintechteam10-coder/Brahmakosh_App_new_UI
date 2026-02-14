part of 'prayer_bloc.dart';

abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerConfigs extends PrayerEvent {
  final String categoryId;
  const LoadPrayerConfigs({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}

class SelectPrayerEmotion extends PrayerEvent {
  final String emotion;
  const SelectPrayerEmotion(this.emotion);

  @override
  List<Object> get props => [emotion];
}

class SelectPrayerMantra extends PrayerEvent {
  final SpiritualConfiguration config;
  const SelectPrayerMantra(this.config);

  @override
  List<Object> get props => [config];
}

class StartPrayerSession extends PrayerEvent {
  const StartPrayerSession();
}
