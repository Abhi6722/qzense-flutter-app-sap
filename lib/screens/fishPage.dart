import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

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

  //camera initialize
  CameraController? _cameraController;
  bool isCameraLoading = true;
  bool speciesSelected = false;
  Timer? _timer;


  //Text to Speech and Speech to Text
  FlutterTts ftts = FlutterTts();
  stt.SpeechToText speech = stt.SpeechToText();

  // Results
  late String result = '';
  late int numericVal;
  late int numberOfFishes;
  late int goodFishes;
  late int badFishes;
  String resultImage = '';
  String specialFeedback = '';

  String myImagePath = '',
      predictionResult = '',
      hour = 'CAM_TEST',
      details = '';
  Map<String, String> suffix = {'BANANA': 'Type', 'FISH': 'Freshness'};
  List<String> goMicro = ['0', '20', '40', '60', '80', '100', 'CAM_TEST'];


  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      deviceInfoPlugin.androidInfo.then((value) => setState(() => androidInfo = value));
    }
  }

  // Future pickImageFromCamera() async {
  //   _showFishResult = false;
  //   _showCameraIcons = false;
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _imageFile = XFile(pickedFile.path);
  //       getResult();
  //     } else {
  //       _showCameraIcons = true;
  //       debugPrint('No image selected.');
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _initializeCamera();
    initPlatformState();
    getAccessToken();

    // Listen to system volume changes
    VolumeController().listener((volume) {
      if (volume > 0) {
        // Volume Up button pressed
        _handleVolumeButtonPress();
      } else {
        // Volume Down button pressed
        _handleVolumeButtonPress();
      }
    });

    // Wait for 5 seconds and ask the user for the fish species
    Future.delayed(const Duration(seconds: 3), () {
      startListening();
    });
  }

  bool _takingPicture = false; // Add this state variable

  void _handleVolumeButtonPress() async {
    if (!_takingPicture) {
      _takingPicture = true;
      setState(() {});

      await pickImageFromCamera();

      setState(() {
        _takingPicture = false;
      });
    }
  }


  @override
  void dispose() {
    VolumeController().removeListener();
    _timer?.cancel(); // Cancel the timer if it is active
    _cameraController?.dispose(); // Dispose the camera controller
    super.dispose();
  }

  void _initializeTTS() async {
    await ftts.setLanguage("en-US");
    await ftts.setSpeechRate(0.4); // Speed of speech
    await ftts.setVolume(1.0); // Volume of speech
    await ftts.setPitch(1); // Pitch of sound
  }

  void startListening() async {
    bool isAvailable = await speech.initialize();
    if (isAvailable) {
      Map<String, List<String>> speciesVariations = {
        'sardine': [
          'sardine', 'sardines', 'sardin', 'sard', 'sardini',
          'sadden', 'sardi', 'sudden', 'stardean', 'sadi',
          'sadin', 'sadine', 'studying', 'star deen', 'sardeen',
          'Sardi', 'Sardine', 'Sadden', 'Sarding', 'sarding',
          'addin', 'saradin', 'serving', 'Sadden', 'Sardi',
          'Sudden', 'Stardean', 'Sadi', 'Sadin', 'Sadine',
          'Studying', 'Star deen', 'Sardeen', 'SARDINE', 'SARDINES',
          'SARDIN', 'SARD', 'SARDINI', 'SADDEN', 'SARDI',
          'SUDDEN', 'STARDEAN', 'SADI', 'SADIN', 'SADINE',
          'STUDYING', 'STAR DEEN', 'SARDEEN'
        ],
        'mackerel': [
          'mackerel', 'mackeral', 'mackerl', 'mackel', 'macker',
          'makarel', 'macrail', 'macal', 'mackrail', 'makrand',
          'makral', 'Mackerel', 'Mackel', 'Macaron', 'Mackeral',
          'Mackerayl', 'Makarai', 'Mackeray', 'Macrail', 'Makkel',
          'macrool', 'macross', 'macarrel', 'macral', 'macro',
          'macroe', 'macroil', 'makaralu', 'macarl', 'mascaral',
          'Macrail', 'Macal', 'Mackrail', 'Makrand', 'Makral',
          'MACROOL', 'MACROSS', 'MACARREL', 'MACRAL', 'MACRO',
          'MACROE', 'MACROIL', 'MAKARALU', 'MACARL', 'MASCARAL',
          'mackrail', 'makrand', 'makral', 'macrool', 'macross',
          'macarrel', 'macral', 'macro', 'macroe', 'macroil',
          'makaralu', 'macarl', 'mascaral', 'Mackrail', 'Makrand',
          'Makral', 'Macrool', 'Macross', 'Macarrel', 'Macral',
          'Macro', 'Macroe', 'Macroil', 'Makaralu', 'Macarl',
          'Mascaral'
        ],
        // Add more species and their variations if needed
      };

      String availableSpeciesString = models.join(", ");
      await ftts.speak("Please say the fish species among the following: $availableSpeciesString");

      await Future.delayed(const Duration(seconds: 4)); // Add a delay to ensure TTS finishes speaking

      bool validSpeciesRecognized = false; // Flag variable to track valid species recognition

      setState(() {
        speech.listen(
          onResult: (result) async {
            if (!mounted) return;
            String recognizedWord = result.recognizedWords.toLowerCase();
            debugPrint('Recognized Word: $recognizedWord');
            String? matchedSpecies;
            for (String species in speciesVariations.keys) {
              if (speciesVariations[species]!.contains(recognizedWord)) {
                matchedSpecies = species;
                break;
              }
            }
            if (matchedSpecies != null) {
              setState(() {
                model = matchedSpecies!;
                speciesSelected = true;
              });
              validSpeciesRecognized = true; // Set the flag to true
              speech.stop(); // Stop speech recognition
            }
          },
          listenFor: const Duration(minutes: 1), // Listen for 1 minute
        );
      });

    } else {
      // Speech recognition not available
      showSpeechNotAvailableDialog();
    }
  }

  Future<void> pickImageFromCamera() async {
    _showFishResult = false;
    _showCameraIcons = false;

    final imageDirectory = await getTemporaryDirectory();
    final imagePath = join(imageDirectory.path, 'fish_image.jpg');

    XFile? imageFile;
    try {
      imageFile = await _cameraController?.takePicture();
    } catch (e) {
      // Handle error if the image capture fails
      debugPrint('Error capturing image: $e');
    }

    if (imageFile != null) {
      final File savedImage = File(imageFile.path);
      await savedImage.copy(imagePath);
      setState(() {
        _imageFile = XFile(imagePath);
        getResult();
      });
    } else {
      // Handle case when no image is captured
      _showCameraIcons = true;
      debugPrint('No image captured.');
    }
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

  void showSpeechNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Speech Recognition Not Available'),
          content: const Text('Speech recognition is not supported on this device.'),
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
        specialFeedback = responseData['Species-Feedback'];
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

        // Start the timer
        _timer = Timer(const Duration(seconds: 15), () {
          // Reset the necessary flags and variables to return to the camera page
          setState(() {
            _showFishResult = false;
            _showCameraIcons = true;
            _imageFile = null;
          });
        });

      } else if(response.statusCode == 403){
        await ftts.setLanguage("en-US");
        await ftts.setSpeechRate(0.4); //speed of speech
        await ftts.setVolume(1.0); //volume of speech
        await ftts.setPitch(1); //pitch of sound
        var speak = await ftts.speak("No Fish Detected. Please try Again!");
        setState(() {
          _showCameraIcons = true;
        });
      }
      else {
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

  void captureImageAgain() {
    _timer?.cancel(); // Cancel the timer if it is active

    setState(() {
      _showFishResult = false;
      _showCameraIcons = true;
      _imageFile = null;
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _cameraController = CameraController(camera, ResolutionPreset.medium);

    // Wait for the camera initialization to complete
    await _cameraController!.initialize();

    // Update the loading flag
    setState(() {
      isCameraLoading = false;
    });
  }


  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
      aspectRatio: _cameraController!.value.aspectRatio,
      child: CameraPreview(_cameraController!),
    );
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
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
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

          if (_showCameraIcons || isCameraLoading) ...[
            Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.5,
                      child: _buildCameraPreview(),
                    ),
                    const SizedBox(height: 20,),
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
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: MaterialButton(
                        height: 150,
                        minWidth: 150,
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
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(100),
                    //   child: MaterialButton(
                    //     height: 150,
                    //     minWidth: 150,
                    //     color: primaryColor,
                    //     onPressed: pickImage,
                    //     child: const Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Column(
                    //           children: [
                    //             Icon(
                    //               Icons.photo_library,
                    //               color: Colors.white,
                    //               size: 40,
                    //             ),
                    //             SizedBox(height: 20),
                    //             Text('Upload Image', style: TextStyle(color: Colors.white)),
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],

            ),

          ],
          if (showLoading) ...[
            // Show the loading indicator
            Container(
              margin: EdgeInsetsDirectional.only(top: MediaQuery.of(context).size.height / 4),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              child: LodingInd(
                msg: 'Loading...',
                model: widget.mlModel,
              ),
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
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     Text(
                  //       'Special Feedback : $specialFeedback',
                  //       style: const TextStyle(
                  //         fontSize: 25.0,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
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
                            setState(() {
                              _showFishResult = false;
                              _showCameraIcons = true;
                            });
                            // pickImageFromCamera();
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
