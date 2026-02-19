import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final response = await repository.getNotifications();
      emit(
        NotificationLoaded(
          notifications: response.data,
          unreadCount: response.unreadCount,
          total: response.total,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
