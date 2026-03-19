import 'package:equatable/equatable.dart';

abstract class SankalpEvent extends Equatable {
  const SankalpEvent();

  @override
  List<Object?> get props => [];
}

class FetchAvailableSankalps extends SankalpEvent {}

class FetchUserSankalps extends SankalpEvent {}

class JoinSankalp extends SankalpEvent {
  final String sankalpId;
  final int customDays;
  final String reminderTime;

  const JoinSankalp({
    required this.sankalpId,
    required this.customDays,
    required this.reminderTime,
  });

  @override
  List<Object> get props => [sankalpId, customDays, reminderTime];
}

class ReportDailyStatus extends SankalpEvent {
  final String userSankalpId;
  final String status;

  const ReportDailyStatus({required this.userSankalpId, required this.status});

  @override
  List<Object> get props => [userSankalpId, status];
}

class FetchSankalpDetail extends SankalpEvent {
  final String sankalpId;

  const FetchSankalpDetail(this.sankalpId);

  @override
  List<Object> get props => [sankalpId];
}

class FetchSankalpProgress extends SankalpEvent {
  final String userSankalpId;

  const FetchSankalpProgress(this.userSankalpId);

  @override
  List<Object> get props => [userSankalpId];
}

class ClearSankalpOperationStatus extends SankalpEvent {}
