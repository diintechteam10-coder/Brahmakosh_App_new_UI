part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

/// Initial fetch with limit and skip=0
class FetchNotifications extends NotificationEvent {
  final int limit;
  const FetchNotifications({this.limit = 20});

  @override
  List<Object> get props => [limit];
}

/// Load more for pagination with incremented skip
class LoadMoreNotifications extends NotificationEvent {
  final int limit;
  const LoadMoreNotifications({this.limit = 20});

  @override
  List<Object> get props => [limit];
}

/// Mark a single notification as read
class MarkReadEvent extends NotificationEvent {
  final String id;
  const MarkReadEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// Mark all notifications as read for current user
class MarkAllReadEvent extends NotificationEvent {}

/// Manually refresh the unread count dot
class RefreshUnreadCount extends NotificationEvent {}
