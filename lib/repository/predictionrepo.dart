import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/predictionsmodel.dart';
import '../services/qzenes_api_services.dart';

class PredictionRepository {
  final QzenesApiServices qzenesApiService;
  PredictionRepository({required this.qzenesApiService});

  Future<Predictions?> getPrediction(
      path, deviceModel, part, hour, brand, mlModel, flashOn) async {
    final Predictions? predictions;

    var res = await qzenesApiService.uploadImage(
        path, deviceModel, part, hour, brand, mlModel, flashOn);
    debugPrint('FIRST RES VALUE : $res');
    var value = await res.stream.bytesToString();
    debugPrint('type of second value : ${value.runtimeType}');
    debugPrint('SECOND RES VALUE : $value');
    predictions = Predictions.fromJson(jsonDecode(value));
    debugPrint('Prediction : $predictions');
    return predictions;
  }
}
