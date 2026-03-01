import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/pooja_repository.dart';
import 'pooja_event.dart';
import 'pooja_state.dart';

class PoojaBloc extends Bloc<PoojaEvent, PoojaState> {
  final PoojaRepository repository;

  PoojaBloc({required this.repository}) : super(PoojaInitial()) {
    on<FetchPoojas>(_onFetchPoojas);
    on<FilterPoojas>(_onFilterPoojas);
    on<FetchPoojaDetail>(_onFetchPoojaDetail);
  }

  Future<void> _onFetchPoojas(
    FetchPoojas event,
    Emitter<PoojaState> emit,
  ) async {
    emit(PoojaLoading());
    try {
      final poojas = await repository.fetchPoojas();
      emit(PoojaLoaded(poojas: poojas, filteredPoojas: poojas));
    } catch (e) {
      emit(PoojaError(e.toString()));
    }
  }

  void _onFilterPoojas(FilterPoojas event, Emitter<PoojaState> emit) {
    if (state is PoojaLoaded) {
      final currentState = state as PoojaLoaded;
      final allPoojas = currentState.poojas;
      final selectedCategory = event.category;

      if (selectedCategory == 'All') {
        emit(
          PoojaLoaded(
            poojas: allPoojas,
            filteredPoojas: allPoojas,
            selectedCategory: selectedCategory,
          ),
        );
      } else {
        // Assuming 'category' field in model or usage of tags.
        // Based on user request/JSON, category is "Daily Puja" etc.
        // User UI has "Festival" tab. Let's filter by category or subcategory containing 'Festival' or similar logic?
        // Or if the user meant specific "Festival" category.
        // For now, let's filter where category or subcategory matches, or if we define a mapping.
        // In the mock controller, it filtered by tags "FESTIVAL PUJA".
        // In new model, we have 'category', 'subcategory'.
        // Let's assume we filter by category for now.

        // However, user specifically asked for "All" and "Festival".
        // Let's implement basic filtering. If the category name contains 'Festival' or if we want exact match.
        // I will act conservatively and filter by category name contains the string, case insensitive.

        final filtered = allPoojas.where((p) {
          return (p.category?.toLowerCase().contains(
                    selectedCategory.toLowerCase(),
                  ) ??
                  false) ||
              (p.subcategory?.toLowerCase().contains(
                    selectedCategory.toLowerCase(),
                  ) ??
                  false);
        }).toList();

        emit(
          PoojaLoaded(
            poojas: allPoojas,
            filteredPoojas: filtered,
            selectedCategory: selectedCategory,
          ),
        );
      }
    }
  }

  Future<void> _onFetchPoojaDetail(
    FetchPoojaDetail event,
    Emitter<PoojaState> emit,
  ) async {
    // If we are already in PoojaDetailLoaded or other state, we might want to emit loading.
    // However, this might be used in a separate Bloc scope in Detail Screen or shared.
    // If shared, it changes the main state.
    // Ideally, detail screen should probably use a separate instance or we simply emit PoojaDetailLoaded.
    // But if we use same instance for list and detail, navigating back might be an issue if state is overwritten.
    // Strategy: Use a separate Bloc provider for Detail Screen OR handle state carefully.
    // Given the simple requirement, I'll emit specific state.
    // But wait, if I use the same global bloc, the list screen will rebuild.
    // Better to have the list screen listen to PoojaLoaded/Loading/Error, and Detail screen listen to PoojaDetail...
    // Or just fetch specific detail in a local Bloc/Cubit in Detail Screen.
    // The user said "integrate api bloc , repository", implying one bloc.

    // I will implementation two separate states is risky if one blocked is used.
    // Actually, usually List and Detail are separate.
    // I will implement _onFetchPoojaDetail to emit PoojaDetailLoaded.
    // The Detail Screen will use a fresh Bloc instance or the same one?
    // If same one, list state is lost.
    // Best practice: List Bloc for List, Detail Bloc for Detail.
    // OR: Single Bloc, but Detail Screen uses a generic "LoadDetail" method that doesn't disturb list if possible? No.
    // I will assume Detail Screen gets its own Bloc instance, or simply creates one.

    emit(PoojaDetailLoading());
    try {
      final pooja = await repository.fetchPoojaDetail(event.id);
      emit(PoojaDetailLoaded(pooja));
    } catch (e) {
      emit(PoojaError(e.toString()));
    }
  }
}
