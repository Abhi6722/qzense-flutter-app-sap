part of 'prediction_cubit_cubit.dart';

enum PredictioStatus {
  initial,
  loading,
  loaded,
  error,
}

class PredictionState extends Equatable {
  final PredictioStatus status;
  final Predictions predictions;
  final CustomError error;

  PredictionState(
      {required this.status, required this.predictions, required this.error});

  factory PredictionState.initial() {
    return PredictionState(
        status: PredictioStatus.initial,
        predictions: Predictions.initial(),
        error: CustomError());
  }

  @override
  List<Object> get props => [status, predictions, error];

  @override
  bool get stringify => true;
  PredictionState copyWith({
    PredictioStatus? status,
    Predictions? predictions,
    CustomError? error,
  }) {
    return PredictionState(
        status: status ?? this.status,
        predictions: predictions ?? this.predictions,
        error: error ?? this.error);
  }
}
