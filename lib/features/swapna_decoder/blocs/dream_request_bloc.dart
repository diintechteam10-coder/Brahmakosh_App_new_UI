import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/swapna_repository.dart';
import 'dream_request_event.dart';
import 'dream_request_state.dart';

class DreamRequestBloc extends Bloc<DreamRequestEvent, DreamRequestState> {
  final SwapnaRepository repository;

  DreamRequestBloc({required this.repository}) : super(DreamRequestInitial()) {
    on<FetchDreamRequests>(_onFetchDreamRequests);
    on<SubmitDreamRequest>(_onSubmitDreamRequest);
    on<FetchDreamRequestDetail>(_onFetchDreamRequestDetail);
  }

  Future<void> _onFetchDreamRequests(
    FetchDreamRequests event,
    Emitter<DreamRequestState> emit,
  ) async {
    emit(DreamRequestLoading());
    try {
      final requests = await repository.fetchDreamRequests();
      emit(DreamRequestLoaded(requests: requests));
    } catch (e) {
      emit(DreamRequestError(e.toString()));
    }
  }

  Future<void> _onSubmitDreamRequest(
    SubmitDreamRequest event,
    Emitter<DreamRequestState> emit,
  ) async {
    print("DreamRequestBloc: _onSubmitDreamRequest received");
    emit(DreamRequestLoading());
    try {
      print("DreamRequestBloc: Calling repository...");
      await repository.createDreamRequest(
        dreamSymbol: event.dreamSymbol,
        additionalDetails: event.additionalDetails,
        clientId: event.clientId,
      );
      print("DreamRequestBloc: Repository call successful");
      emit(const DreamRequestSuccess("Dream request submitted successfully"));
      // Refresh the list after submission
      add(FetchDreamRequests());
    } catch (e) {
      print("DreamRequestBloc: Error caught: $e");
      emit(DreamRequestError(e.toString()));
    }
  }

  Future<void> _onFetchDreamRequestDetail(
    FetchDreamRequestDetail event,
    Emitter<DreamRequestState> emit,
  ) async {
    emit(DreamRequestDetailLoading());
    try {
      final request = await repository.fetchDreamRequestDetail(event.id);
      emit(DreamRequestDetailLoaded(request));
    } catch (e) {
      emit(DreamRequestError(e.toString()));
    }
  }
}
