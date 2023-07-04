import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../widgets/LodingIndicator.dart';
import 'homepage.dart';

class FishPage extends StatefulWidget {
  FishPage({Key? key, required this.mlModel, required this.part, required this.access})
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
  late bool _showCameraIcons = true;
  bool showLoading = false;
  var model = 'sardine';
  var models = ['sardine', 'mackerel'];

  // Results
  late String result = '';
  late int numericVal;
  late int numberOfFishes;
  late int goodFishes;
  late int badFishes;
  String resultImage = '';

  String myImagePath = '',
      predictionResult = '',
      hour = 'CAM_TEST',
      details = '';
  Map<String, String> suffix = {'BANANA': 'Type', 'FISH': 'Freshness'};
  List<String> goMicro = ['0', '20', '40', '60', '80', '100', 'CAM_TEST'];

  FlutterTts ftts = FlutterTts();

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      deviceInfoPlugin.androidInfo.then((value) => setState(() => androidInfo = value));
    }
  }

  Future pickImageFromCamera() async {
    _showFishResult = false;
    _showCameraIcons = false;
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = XFile(pickedFile.path);
        getResult();
      } else {
        _showCameraIcons = true;
        debugPrint('No image selected.');
      }
    });
  }

  Future pickImage() async {
    _showFishResult = false;
    _showCameraIcons = false;
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = XFile(pickedFile.path);
        getResult();
      } else {
        _showCameraIcons = true;
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
          actions: const <Widget>[LogoutButton()],
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
      await getAccessToken();
      // Validate required fields
      if (_imageFile == null) {
        // Error dialog
        return;
      }

      var headers = {
        'Authorization': 'Bearer $accessT',
      };

      var request = http.MultipartRequest('POST', Uri.parse('http://43.204.133.133:8000/post/'));
      request.fields.addAll({
        'deviceModel': androidInfo.model,
        'brand': androidInfo.brand,
        'test': 'False',
        'mlModel': widget.mlModel,
        'part': widget.part,
        'hour': hour,
        'flash': flashOn ? 1.toString() : 0.toString(),
        'FishName': model,
      });
      request.files.add(await http.MultipartFile.fromPath('capture', _imageFile!.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        debugPrint(responseBody);
        var responseData = json.decode(responseBody);
        result = responseData['Species'] ?? '';
        numberOfFishes = responseData['Fishes detected'];
        goodFishes = responseData['Good fishes'];
        badFishes = responseData['Bad fishes'];
        resultImage = responseData['Image'];
        _showFishResult = true;

        await ftts.setLanguage("en-US");
        await ftts.setSpeechRate(0.4); //speed of speech
        await ftts.setVolume(1.0); //volume of speech
        await ftts.setPitch(1); //pitch of sound

        if(goodFishes > 0 && badFishes == 0){
          var speakResult = await ftts.speak("Fish Species $result, Number of Fish Detected $numberOfFishes, All Fishes Good");
          // if(speakResult == 1){}else{}
        } else if(badFishes > 0 && goodFishes == 0){
          var speakResult = await ftts.speak("Fish Species $result, Number of Fish Detected $numberOfFishes, All Fishes Bad");
          // if(speakResult == 1){}else{}
        } else {
          var speakResult = await ftts.speak("Fish Species $result, Number of Fish Detected $numberOfFishes, Number of Good Fishes $goodFishes, Number of Bad Fishes $badFishes ");
          // if(speakResult == 1){}else{}
        }

      } else {
        debugPrint(response.reasonPhrase);
        debugPrint("\nThe status code is : ${response.statusCode.toString()}");
        debugPrint("\nResponse Headers : ${response.headers.toString()}");
        debugPrint("\nThe Reason Phrase is : ${response.reasonPhrase.toString()}");
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

  Widget buildImageWidget() {
    if (resultImage.isNotEmpty) {
      List<int> decodedImage = base64Decode(resultImage);
      Uint8List uint8List = Uint8List.fromList(decodedImage);
      return Image.memory(uint8List);
    }
    return const SizedBox.shrink(); // Return an empty SizedBox if the image is empty
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Center(child: Text('Fish Model')),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showFishResult) ...[
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                child: buildImageWidget(), // Display the decoded image widget
              ),
            ),
          ],
          if (_showCameraIcons) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.green[200],
                      width: 150,
                      height: 60,
                      child: Center(
                        child: DropdownButton<String>(
                          value: model,
                          // hint: const Text('Select Fish Type'),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: models.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item, style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              model = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: MaterialButton(
                        height: 200,
                        minWidth: 200,
                        color: primaryColor,
                        onPressed: pickImageFromCamera,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                SizedBox(height: 20),
                                Text('Take Photo', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: MaterialButton(
                        height: 200,
                        minWidth: 200,
                        color: primaryColor,
                        onPressed: pickImage,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                SizedBox(height: 20),
                                Text('Upload Image', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (showLoading) ...[
            // Show the loading indicator
            LodingInd(
              msg: 'Loading...',
              model: widget.mlModel,
            ),
          ] else if (_showFishResult) ...[

            // Show the result
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Fish Species : $result',
                        style: const TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Fish Detected : $numberOfFishes',
                        style: const TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Good Fishes : $goodFishes',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Bad Fishes : $badFishes',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 80.0,
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 90,
                        color: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2.5,
                        bottom: 0,
                        top: -140,
                        child: InkWell(
                          onTap: () {
                            pickImageFromCamera();
                            // flutterTts.speak('Take Photo'); // Speak the action
                          },
                          child: Container(
                            width: 90.0,
                            height: 90.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor,
                              border: Border.all(
                                color: Colors.white,
                                width: 6.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ],
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
