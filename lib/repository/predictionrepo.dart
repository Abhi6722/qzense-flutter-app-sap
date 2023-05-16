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
    debugPrint('first REs VALUE : $res');
    var value = await res.stream.bytesToString();
    debugPrint('type of second value : ${value.runtimeType}');
    debugPrint('seconD REs VALUE : $value');
    predictions = Predictions.fromJson(jsonDecode(value));
    return predictions;

    // debugPrint(jsonDecode(value).toString());

    // debugPrint("Prediction is ${predictions!.result} ");

    //     .then((value) => {
    //           debugPrint('first REs VALUE : $value'),
    //           value.stream
    //               .bytesToString()
    //               .then((value) => {
    //                     debugPrint(
    //                         'type of second value : ${value.runtimeType}'),
    //                     debugPrint('seconD REs VALUE : $value'),
    //                     debugPrint(jsonDecode(value).toString()),
    //                     predictions = Predictions.fromJson(jsonDecode(value)),
    //                     debugPrint("Prediction is ${predictions!.result} "),
    //                   })
    //               .catchError((e) {
    //             predictions = Predictions.initial();
    //           }),
    //         })
    //     .catchError((e) {
    //   predictions = Predictions.initial();
    // });
    //debugPrint("Prediction is $predictions['result] ");
  }
}
