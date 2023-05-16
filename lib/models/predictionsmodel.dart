import 'package:equatable/equatable.dart';

class Predictions extends Equatable {
  final String? result;
  final String? action;
  final String? numericVal;
  final int R;
  final int G;
  final int B;

  const Predictions(
      {this.result,
      this.action,
      this.numericVal,
      required this.R,
      required this.G,
      required this.B});
  factory Predictions.initial() => const Predictions(
      result: 'No result found',
      action: 'null',
      numericVal: 'null',
      R: 255,
      G: 255,
      B: 255);

  factory Predictions.fromJson(Map<String, dynamic> json) {
    return Predictions(
        result: json['result'].toString(),
        action: json['action'].toString(),
        numericVal: json['numericVal'].toString(),
        R: json['R'] as int,
        G: json['G'] as int,
        B: json['B'] as int);
  }

  @override
  List<Object?> get props {
    return [result, action, numericVal, R, G, B];
  }

  @override
  bool get stringify => true;
}
