import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/swapna_repository.dart';
import 'swapna_event.dart';
import 'swapna_state.dart';

class SwapnaBloc extends Bloc<SwapnaEvent, SwapnaState> {
  final SwapnaRepository repository;

  SwapnaBloc({required this.repository}) : super(SwapnaInitial()) {
    on<FetchSwapnaList>(_onFetchSwapnaList);
    on<FetchSwapnaDetail>(_onFetchSwapnaDetail);
  }

  Future<void> _onFetchSwapnaList(
    FetchSwapnaList event,
    Emitter<SwapnaState> emit,
  ) async {
    emit(SwapnaLoading());
    try {
      final swapnas = await repository.fetchSwapnaList();
      emit(SwapnaLoaded(swapnas: swapnas));
    } catch (e) {
      emit(SwapnaError(e.toString()));
    }
  }

  Future<void> _onFetchSwapnaDetail(
    FetchSwapnaDetail event,
    Emitter<SwapnaState> emit,
  ) async {
    emit(SwapnaDetailLoading());
    try {
      final swapna = await repository.fetchSwapnaDetail(event.id);
      emit(SwapnaDetailLoaded(swapna));
    } catch (e) {
      emit(SwapnaError(e.toString()));
    }
  }
}
