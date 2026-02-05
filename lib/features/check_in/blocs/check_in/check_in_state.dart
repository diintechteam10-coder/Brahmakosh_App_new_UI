part of 'check_in_bloc.dart';

abstract class CheckInState extends Equatable {
  const CheckInState();

  @override
  List<Object?> get props => [];
}

class CheckInInitial extends CheckInState {}

class CheckInLoading extends CheckInState {}

class CheckInLoaded extends CheckInState {
  final Data data;
  final Map<String, SpiritualConfigurationResponse> preFetchedConfigs;

  const CheckInLoaded({required this.data, this.preFetchedConfigs = const {}});

  CheckInLoaded copyWith({
    Data? data,
    Map<String, SpiritualConfigurationResponse>? preFetchedConfigs,
  }) {
    return CheckInLoaded(
      data: data ?? this.data,
      preFetchedConfigs: preFetchedConfigs ?? this.preFetchedConfigs,
    );
  }

  @override
  List<Object?> get props => [data, preFetchedConfigs];
}

class CheckInError extends CheckInState {
  final String message;

  const CheckInError(this.message);

  @override
  List<Object> get props => [message];
}

/// Helper state for One-Off Navigation Action
/// We will emit this briefly then return to Loaded.
class CheckInNavigationAction extends CheckInState {
  final String route;
  final Object? arguments;
  final CheckInLoaded previousState; // To restore after navigation

  const CheckInNavigationAction({
    required this.route,
    this.arguments,
    required this.previousState,
  });

  @override
  List<Object?> get props => [route, arguments, previousState];
}

/// Loading state specifically for navigation (blocking loader)
class CheckInNavigationLoading extends CheckInState {
  final CheckInLoaded previousState;

  const CheckInNavigationLoading(this.previousState);

  @override
  List<Object> get props => [previousState];
}
