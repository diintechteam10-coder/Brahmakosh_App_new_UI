import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(const NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkReadEvent>(_onMarkRead);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final currentUnreadCount = state.unreadCount;
    emit(NotificationLoading(unreadCount: currentUnreadCount));
    try {
      final response = await repository.getNotifications(limit: event.limit, skip: 0);
      emit(
        NotificationLoaded(
          notifications: response.data,
          unreadCount: response.unreadCount,
          total: response.total,
          hasReachedMax: response.data.length >= response.total,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString(), unreadCount: currentUnreadCount));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded && !currentState.hasReachedMax) {
      try {
        final response = await repository.getNotifications(
          limit: event.limit,
          skip: currentState.notifications.length,
        );
        
        final allNotifications = List<NotificationModel>.from(currentState.notifications)
          ..addAll(response.data);
          
        emit(
          currentState.copyWith(
            notifications: allNotifications,
            unreadCount: response.unreadCount,
            total: response.total,
            hasReachedMax: allNotifications.length >= response.total,
          ),
        );
      } catch (e) {
        // Silent failure for pagination
      }
    }
  }

  Future<void> _onMarkRead(
    MarkReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.id) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            body: n.body,
            type: n.type,
            data: n.data,
            description: n.description,
            createdAt: n.createdAt,
            isRead: true,
            category: n.category,
          );
        }
        return n;
      }).toList();

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: (currentState.unreadCount - 1).clamp(0, currentState.total).toInt(),
      ));

      await repository.markAsRead(event.id);
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((n) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          data: n.data,
          description: n.description,
          createdAt: n.createdAt,
          isRead: true,
          category: n.category,
        );
      }).toList();

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));

      await repository.markAllAsRead();
    }
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    try {
      final count = await repository.getUnreadCount();
      debugPrint("BLOC REFRESH UNREAD COUNT: $count (Current state: ${currentState.runtimeType})");
      if (currentState is NotificationLoaded) {
        emit(currentState.copyWith(unreadCount: count));
      } else {
        // Just update the count in base state if not loaded
        if (currentState is NotificationInitial) {
          emit(NotificationInitial(unreadCount: count));
        } else if (currentState is NotificationLoading) {
          emit(NotificationLoading(unreadCount: count));
        } else if (currentState is NotificationError) {
          emit(NotificationError(currentState.message, unreadCount: count));
        }
      }
    } catch (_) {}
  }
}
