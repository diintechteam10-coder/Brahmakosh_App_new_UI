part of 'spiritual_stats_bloc.dart';

abstract class SpiritualStatsState extends Equatable {
  const SpiritualStatsState();

  @override
  List<Object> get props => [];
}

class SpiritualStatsInitial extends SpiritualStatsState {}

class SpiritualStatsLoading extends SpiritualStatsState {}

class SpiritualStatsLoaded extends SpiritualStatsState {
  final SpiritualStatsData data;

  const SpiritualStatsLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class SpiritualStatsError extends SpiritualStatsState {
  final String message;

  const SpiritualStatsError(this.message);

  @override
  List<Object> get props => [message];
}
