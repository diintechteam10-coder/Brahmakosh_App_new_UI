part of 'spiritual_stats_bloc.dart';

abstract class SpiritualStatsEvent extends Equatable {
  const SpiritualStatsEvent();

  @override
  List<Object> get props => [];
}

class LoadSpiritualStats extends SpiritualStatsEvent {}

class RefreshSpiritualStats extends SpiritualStatsEvent {
  final Completer<void> completer;

  const RefreshSpiritualStats(this.completer);
}
