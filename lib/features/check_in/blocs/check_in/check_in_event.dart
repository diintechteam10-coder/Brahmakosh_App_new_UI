part of 'check_in_bloc.dart';

abstract class CheckInEvent extends Equatable {
  const CheckInEvent();

  @override
  List<Object?> get props => [];
}

class LoadCheckIn extends CheckInEvent {}

class SelectActivity extends CheckInEvent {
  final String activityId;
  final String route;
  final String? title;

  const SelectActivity({
    required this.activityId,
    required this.route,
    this.title,
  });

  @override
  List<Object?> get props => [activityId, route, title];
}
