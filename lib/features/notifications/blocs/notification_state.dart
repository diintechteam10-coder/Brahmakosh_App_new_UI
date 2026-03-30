part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  final int unreadCount;
  const NotificationState({this.unreadCount = 0});

  @override
  List<Object> get props => [unreadCount];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial({int unreadCount = 0}) : super(unreadCount: unreadCount);
}

class NotificationLoading extends NotificationState {
  const NotificationLoading({int unreadCount = 0}) : super(unreadCount: unreadCount);

  @override
  List<Object> get props => [unreadCount];
}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int total;
  final bool hasReachedMax;

  const NotificationLoaded({
    required this.notifications,
    required int unreadCount,
    required this.total,
    this.hasReachedMax = false,
  }) : super(unreadCount: unreadCount);

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    int? total,
    bool? hasReachedMax,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [notifications, unreadCount, total, hasReachedMax];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message, {int unreadCount = 0})
      : super(unreadCount: unreadCount);

  @override
  List<Object> get props => [message, unreadCount];
}
