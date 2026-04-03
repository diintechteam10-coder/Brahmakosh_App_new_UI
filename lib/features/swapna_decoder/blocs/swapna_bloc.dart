import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/swapna_repository.dart';
import 'swapna_event.dart';
import 'swapna_state.dart';
import 'package:get/get.dart';
import '../../../core/localization/translate_helper.dart';

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
      if (Get.locale?.languageCode == 'hi') {
        for (var s in swapnas) {
          s.symbolName = await TranslateHelper.translate(s.symbolName);
          s.category = await TranslateHelper.translate(s.category);
          s.shortDescription = await TranslateHelper.translate(s.shortDescription ?? "");
        }
      }
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
      if (Get.locale?.languageCode == 'hi') {
        swapna.symbolName = await TranslateHelper.translate(swapna.symbolName);
        swapna.category = await TranslateHelper.translate(swapna.category);
        swapna.subcategory = await TranslateHelper.translate(swapna.subcategory);
        swapna.shortDescription = await TranslateHelper.translate(swapna.shortDescription ?? "");
        swapna.detailedInterpretation = await TranslateHelper.translate(swapna.detailedInterpretation ?? "");
        swapna.astrologicalSignificance = await TranslateHelper.translate(swapna.astrologicalSignificance ?? "");
        swapna.vedicReferences = await TranslateHelper.translate(swapna.vedicReferences ?? "");
        swapna.frequencyImpact = await TranslateHelper.translate(swapna.frequencyImpact ?? "");

        if (swapna.positiveAspects != null) {
          for (var p in swapna.positiveAspects!) {
            p.point = await TranslateHelper.translate(p.point);
            p.description = await TranslateHelper.translate(p.description);
          }
        }
        if (swapna.negativeAspects != null) {
          for (var p in swapna.negativeAspects!) {
            p.point = await TranslateHelper.translate(p.point);
            p.description = await TranslateHelper.translate(p.description);
          }
        }
        if (swapna.contextVariations != null) {
          for (var c in swapna.contextVariations!) {
            c.context = await TranslateHelper.translate(c.context);
            c.meaning = await TranslateHelper.translate(c.meaning);
          }
        }
        if (swapna.remedies != null) {
          if (swapna.remedies!.mantras != null) {
            swapna.remedies!.mantras = await TranslateHelper.translateList(swapna.remedies!.mantras!);
          }
          if (swapna.remedies!.pujas != null) {
            swapna.remedies!.pujas = await TranslateHelper.translateList(swapna.remedies!.pujas!);
          }
        }
        if (swapna.timeSignificance != null) {
          swapna.timeSignificance!.morning = await TranslateHelper.translate(swapna.timeSignificance!.morning ?? "");
          swapna.timeSignificance!.night = await TranslateHelper.translate(swapna.timeSignificance!.night ?? "");
          swapna.timeSignificance!.brahmaMuhurat = await TranslateHelper.translate(swapna.timeSignificance!.brahmaMuhurat ?? "");
        }
      }
      emit(SwapnaDetailLoaded(swapna));
    } catch (e) {
      emit(SwapnaError(e.toString()));
    }
  }
}
