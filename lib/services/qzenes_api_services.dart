import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';

class QzenesApiServices {
  Future<http.StreamedResponse> uploadImage(
      path, deviceModel, part, hour, brand, mlModel, flashOn) async {
    debugPrint("in api Services");
    debugPrint(path);
    debugPrint(deviceModel);
    debugPrint(part);
    debugPrint("hour is $hour");
    debugPrint(brand);
    debugPrint(mlModel);
    debugPrint(flashOn.toString());

    var request = http.MultipartRequest('post', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('capture', path));
    request.fields['deviceModel'] = deviceModel;
    request.fields['mlModel'] = mlModel;
    request.fields['brand'] = brand;
    request.fields['part'] = part;
    request.fields['hour'] = hour;
    request.fields['flash'] = flashOn ? 1.toString() : 0.toString();

    ///if test is true, image wont be pushed to database on api, else pushed
    request.fields['test'] = 'False'; // DB PUSH BOOLEAN

    var res = await request.send();
    debugPrint("\nThe status code is : ${res.statusCode.toString()}");
    debugPrint("\nResponse Headers : ${res.headers.toString()}");
    debugPrint("\nThe Reason Phrase is : ${res.reasonPhrase.toString()}");

    debugPrint('Res: $res');
    return res;
  }
}
