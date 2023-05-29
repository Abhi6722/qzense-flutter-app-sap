import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/custom_error.dart';
import '../../models/predictionsmodel.dart';
import '../../repository/predictionrepo.dart';

part 'prediction_cubit_state.dart';

class PredictionCubit extends Cubit<PredictionState> {
  final PredictionRepository predictionRepository;

  PredictionCubit({required this.predictionRepository})
      : super(PredictionState.initial());

  Future<void> fetchPredictions(
      path, deviceModel, part, hour, brand, mlModel, flashOn) async {
    emit(state.copyWith(status: PredictioStatus.loading));
    debugPrint("in cubit and emitting state");
    try {
      Predictions? predictionss = await predictionRepository.getPrediction(
          path, deviceModel, part, hour, brand, mlModel, flashOn);

      emit(state.copyWith(
          status: PredictioStatus.loaded, predictions: predictionss));
      debugPrint('PREDICTION IS $predictionss');
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
