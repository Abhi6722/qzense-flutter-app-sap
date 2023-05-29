import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/LodingIndicator.dart';
import 'homepage.dart';

class FishPage extends StatefulWidget {
  FishPage(
      {Key? key,
      required this.mlModel,
      required this.part,
      required this.access})
      : super(key: key);
  String mlModel = '';
  String part = '';
  String access = '';

  @override
  State<FishPage> createState() => _FishPageState();
}

class _FishPageState extends State<FishPage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  bool cameraOn = true;
  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iosInformation;
  late int R, G, B;
  dynamic size;
  bool isRightHanded = true;
  XFile? _imageFile;
  bool isBanana = false;
  File? croppedImage;
  int predictionNumeric = -1;
  bool flashOn = false;
  var accessT = '';
  final picker = ImagePicker();
  late bool _showFishResult = false;
  bool showLoading = false;

  // Results
  late String result = '';
  late int numericVal;
  late int numberOfFishes;

  String myImagePath = '',
      predictionResult = '',
      hour = 'CAM_TEST',
      details = '';
  Map<String, String> suffix = {'BANANA': 'Type', 'FISH': 'Freshness'};
  List<String> goMicro = ['0', '20', '40', '60', '80', '100', 'CAM_TEST'];

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      deviceInfoPlugin.androidInfo
          .then((value) => setState(() => {androidInfo = value}));
    }
  }

  Future pickImageFromCamera() async {
    _showFishResult = false;
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = XFile(pickedFile.path);
      } else {
        // print('No image selected.');
      }
    });
  }

  Future pickImage() async {
    _showFishResult = false;
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = XFile(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: const <Widget>[
            LogoutButton()
          ],
        );
      },
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessT = prefs.getString('token')!;
    debugPrint('Access Token : $accessT');
  }

  Future getResult() async {
    try {
      setState(() {
        showLoading = true;
      });

      getAccessToken();
      // Validate required fields
      if (_imageFile == null) {
        // Error dialog
        return;
      }

      var headers = {
        'Authorization': 'Bearer $accessT',
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('http://15.206.190.168:8000/post/'));
      request.fields.addAll({
        'deviceModel': androidInfo.model,
        'brand': androidInfo.brand,
        'test': 'False',
        'mlModel': widget.mlModel,
        'part': widget.part,
        'hour': hour,
        'flash': flashOn ? 1.toString() : 0.toString(),
      });
      request.files
          .add(await http.MultipartFile.fromPath('capture', _imageFile!.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        debugPrint(responseBody);
        var responseData = json.decode(responseBody);
        result = responseData['result'];
        numericVal = responseData['numericVal'];
        R = responseData['R'];
        G = responseData['G'];
        B = responseData['B'];
        numberOfFishes = responseData['NumberOfFishes'];
        _showFishResult = true;
      } else {
        debugPrint(response.reasonPhrase);
        debugPrint("\nThe status code is : ${response.statusCode.toString()}");
        debugPrint("\nResponse Headers : ${response.headers.toString()}");
        debugPrint(
            "\nThe Reason Phrase is : ${response.reasonPhrase.toString()}");
        debugPrint('Res: $response');
        showErrorDialog("Session Expired. Login Again !!");
      }
    } catch (e) {
      debugPrint('error Message is ${e.toString()}');
    } finally {
      setState(() {
        showLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getAccessToken();
    debugPrint(widget.mlModel);
    debugPrint(accessT);
  }

  void setCameraOn() {
    setState(() {
      cameraOn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Center(child: Text('Predict Fish Freshness')),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_imageFile != null) ...[
            Image.file(
              File(_imageFile!.path),
              width: 250.0,
              height: 250.0,
              fit: BoxFit.cover,
            ),
          ],
          const SizedBox(height: 15.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: MaterialButton(
                    height: 70,
                    color: primaryColor,
                    onPressed: pickImageFromCamera,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.camera_alt, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Take Photo',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  flex: 1,
                  child: MaterialButton(
                    height: 70,
                    color: primaryColor,
                    onPressed: pickImage,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.photo_library, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Upload Image',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              onPressed: getResult,
              color: primaryColor,
              height: 50,
              child: const Text('Get Results',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 50.0),
          if (showLoading) ...[
            // Show the loading indicator
            LodingInd(
              msg: 'Loading...',
              model: widget.mlModel,
            ),
          ] else
            if (_showFishResult) ...[
              // Show the result
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          result,
                          style: const TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IndicatorIcon(R: R, G: G, B: B),
                      ],
                    ),
                    const SizedBox(height: 50.0),
                    Container(
                      color: primaryColor,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 120,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0),
                              alignment: Alignment.center,
                              child: const Text(
                                "*Results are Only Indicative To Aid Consumers",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class IndicatorIcon extends StatelessWidget {
  final int R, G, B;
  const IndicatorIcon(
      {Key? key, required this.R, required this.G, required this.B})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      FontAwesomeIcons.solidCircle,
      color: Color.fromARGB(255, R, G, B),
      size: 40,
    );
  }
}
