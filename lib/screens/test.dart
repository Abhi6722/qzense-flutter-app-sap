// import 'dart:convert';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
//
// class FishPage extends StatefulWidget {
//   FishPage({Key? key, required this.mlModel, required this.part, required this.access})
//       : super(key: key);
//   String mlModel = '';
//   String part = '';
//   String access = '';
//
//   @override
//   State<FishPage> createState() => _FishPageState();
// }
//
// class _FishPageState extends State<FishPage> {
//
//   static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//   bool cameraOn = true;
//   late AndroidDeviceInfo androidInfo;
//   late IosDeviceInfo iosInformation;
//   late int R, G, B;
//   dynamic size;
//   bool isRightHanded = true;
//   XFile? _imageFile;
//   bool isBanana = false;
//   File? croppedImage;
//   int predictionNumeric = -1;
//   bool flashOn = false;
//
//   String myImagePath = '',
//       predictionResult = '',
//       hour = 'CAM_TEST',
//       details = '';
//   Map<String, String> suffix = {'BANANA': 'Type', 'FISH': 'Freshness'};
//   List<String> goMicro = ['0', '20', '40', '60', '80', '100', 'CAM_TEST'];
//
//   Future<void> initPlatformState() async {
//     if (Platform.isAndroid) {
//       deviceInfoPlugin.androidInfo
//           .then((value) => setState(() => {androidInfo = value}));
//     }
//   }
//
//   final picker = ImagePicker();
//   static String truckNumber = '';
//   late bool _showTruckNumber = false;
//
//   Future pickImageFromCamera() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     setState(() {
//       if (pickedFile != null) {
//         _imageFile = XFile(pickedFile.path);
//       } else {
//         // print('No image selected.');
//       }
//     });
//   }
//
//   Future pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         _imageFile = XFile(pickedFile.path);
//       } else {
//         if (kDebugMode) {
//           print('No image selected.');
//         }
//       }
//     });
//   }
//
//   void showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void showSuccessDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Success'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future getResult() async {
//     // Validate required fields
//     if (_imageFile == null) {
//       // Error dialog
//       return;
//     }
//
//     var headers = {
//       'Accept': 'application/json'
//     };
//
//     var request = http.MultipartRequest('POST', Uri.parse('http://65.0.56.125:8000/api/text_rekognition/'));
//     // var request = http.MultipartRequest('post', Uri.parse(url));
//     request.files.add(await http.MultipartFile.fromPath('capture', _imageFile!.path));
//     request.headers.addAll(headers);
//
//     // request.files.add(await http.MultipartFile.fromPath('capture', path));
//     request.fields['deviceModel'] = deviceModel;
//     request.fields['mlModel'] = widget.mlModel;
//     request.fields['brand'] = brand;
//     request.fields['part'] = part;
//     request.fields['hour'] = hour;
//     request.fields['flash'] = flashOn ? 1.toString() : 0.toString();
//
//     ///if test is true, image wont be pushed to database on api, else pushed
//     request.fields['test'] = 'False'; // DB PUSH BOOLEAN
//
//     http.Response response = await http.Response.fromStream(await request.send());
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       String responseBody = response.body;
//       if (kDebugMode) {
//         print(responseBody); // {"text":"RJ.09GA.0165"}
//
//         setState(() {
//           Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
//           truckNumber = jsonResponse['text'];
//           _showTruckNumber = true;
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.reasonPhrase);
//       }
//     }
//
//     debugPrint("\nThe status code is : ${response.statusCode.toString()}");
//     debugPrint("\nResponse Headers : ${response.headers.toString()}");
//     debugPrint("\nThe Reason Phrase is : ${response.reasonPhrase.toString()}");
//     debugPrint('Res: $response');
//
//     return response;
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//     debugPrint(widget.mlModel);
//   }
//
//   void setCameraOn() {
//     setState(() {
//       cameraOn = true;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF27485D),
//         title: const Center(child: Text('Qzense Labs')),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               if (_imageFile != null) ...[
//                 // const SizedBox(height: 10.0),
//                 Image.file(
//                   File(_imageFile!.path),
//                   width: 150.0,
//                   height: 200.0,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//
//               const SizedBox(height: 15.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Flexible(
//                     flex: 1,
//                     child: MaterialButton(
//                       height: 50,
//                       color: const Color(0xFF27485D),
//                       onPressed: pickImageFromCamera,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(Icons.camera_alt, color: Colors.white),
//                           SizedBox(width: 8),
//                           Text('Take Photo',
//                               style: TextStyle(color: Colors.white)),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Flexible(
//                     flex: 1,
//                     child: MaterialButton(
//                       height: 50,
//                       color: const Color(0xFF27485D),
//                       onPressed: pickImage,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(Icons.photo_library, color: Colors.white),
//                           SizedBox(width: 8),
//                           Text('Upload Image',
//                               style: TextStyle(color: Colors.white)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 10.0),
//               MaterialButton(
//                 onPressed: getResult,
//                 color: const Color(0xFF27485D),
//                 child: const Text('Get Truck Number',
//                     style: TextStyle(color: Colors.white)),
//               ),
//
//               const SizedBox(height: 10.0),
//               if (_showTruckNumber) ...[
//                 Container(
//                   padding: const EdgeInsets.all(10.0),
//                   color: Colors.grey[200],
//                   child: Row(
//                     children: [
//                       const Text(
//                         "Truck Number:",
//                         style: TextStyle(fontSize: 20.0),
//                       ),
//                       const SizedBox(width: 5.0),
//                       Text(
//                         truckNumber,
//                         style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10.0),
//                 MaterialButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/home');
//                   },
//                   color: const Color(0xFF27485D),
//                   child: const Text('Next',
//                       style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gallery_saver/files.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:qzenesapp/screens/homepage.dart';
//
// import '../constants/constants.dart';
// import '../cubits/prediction/prediction_cubit_cubit.dart';
// import '../widgets/Linksfooter.dart';
// import '../widgets/LodingIndicator.dart';
//
// class FishPage extends StatefulWidget {
//   String mlModel = '';
//   String part = '';
//   var access = '';
//
//   FishPage({Key? key, required this.mlModel, required this.part, required this.access})
//       : super(key: key);
//
//   @override
//   _FishPageState createState() => _FishPageState();
// }
//
// class _FishPageState extends State<FishPage> {
//   static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//   bool cameraOn = true;
//   late AndroidDeviceInfo androidInfo;
//   late IosDeviceInfo iosInformation;
//   late int R, G, B;
//   dynamic size;
//   bool isRightHanded = true;
//   XFile? imageFile;
//   bool isBanana = false;
//   File? croppedImage;
//   int predictionNumeric = -1;
//   bool flashOn = false;
//
//   String myImagePath = '',
//       predictionResult = '',
//       hour = 'CAM_TEST',
//       details = '';
//   Map<String, String> suffix = {'BANANA': 'Type', 'FISH': 'Freshness'};
//   List<String> goMicro = ['0', '20', '40', '60', '80', '100', 'CAM_TEST'];
//
//   Future<void> initPlatformState() async {
//     if (Platform.isAndroid) {
//       deviceInfoPlugin.androidInfo
//           .then((value) => setState(() => {androidInfo = value}));
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//     debugPrint(widget.mlModel);
//   }
//
//   void setCameraOn() {
//     setState(() {
//       cameraOn = true;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     size = MediaQuery
//         .of(context)
//         .size;
//
//     //for setting default orientation
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//     //instance of cubit to handle state management
//     var provider = BlocProvider.of<PredictionCubit>(context);
//
//     // method to implement the logic of camera and calling cubit & api
//     Future<WillPopScope> _getImage(ImageSource source) async {
//       try {
//         setState(() {
//           cameraOn = false;
//         });
//
//         //picking image from camera  and gallery
//         XFile? imageXfile = await ImagePicker().pickImage(
//           source: source,
//           imageQuality: 50,
//         );
//         if (imageXfile == null) {
//           setState(() {
//             cameraOn = true;
//           });
//         }
//
//         debugPrint('Image File : $imageXfile');
//         // code for getting dimension of selected image
//         File tempImage = File(imageXfile!.path);
//         var decodedImage = await decodeImageFromList(
//             tempImage.readAsBytesSync());
//         if (decodedImage.height != decodedImage.width) {
//           //if image is not square then cropper opens else call to api
//           croppedImage = (await ImageCropper().cropImage(
//             sourcePath: imageXfile.path,
//             aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//             compressQuality: 100,
//             maxWidth: 700,
//             maxHeight: 700,
//             compressFormat: ImageCompressFormat.png,
//           )) as File?;
//           if (croppedImage == null) {
//             setState(() {
//               cameraOn = true;
//             });
//           }
//
//           setState(() {
//             myImagePath = croppedImage!.path;
//             cameraOn = true;
//           });
//
//           //method for getting prediction
//           var headers = {
//             'Authorization':
//             'Bearer ${widget.access}',
//           };
//
//           var request = http.MultipartRequest(
//               'POST', Uri.parse('http://15.206.190.168:8000//post/'));
//           request.headers.addAll(headers);
//
//           request.fields['deviceModel'] = 'S22';
//           request.fields['brand'] = 'Samsung';
//           request.fields['test'] = 'False';
//           request.fields['mlModel'] = 'FISH';
//           request.fields['part'] = 'gills';
//           request.fields['hour'] = '100';
//           request.fields['flash'] = 'ON';
//           request.files.add(
//               await http.MultipartFile.fromPath('capture', croppedImage!.path));
//
//           http.StreamedResponse response = await request.send();
//
//           if (response.statusCode == 200) {
//             debugPrint(await response.stream.bytesToString());
//             var res = await response.stream.bytesToString();
//             // Navigator.pushNamed(context, resultPage, arguments: {
//             //   'mlModel': widget.mlModel,
//             //   'part': widget.part,
//             //   'details': res.action,
//             //   'R': res.R,
//             //   'G': res.G,
//             //   'B': res.B,
//             //   'predictionResults': res.result,
//             //   'imagePath': myImagePath,
//             // });
//             debugPrint(res);
//
//             //
//             //         var request = http.MultipartRequest('POST', Uri.parse('http://65.0.56.125:8000/api/text_rekognition/'));
//             //         request.headers.addAll(headers);
//             //
//             //         request.fields['deviceModel'] = androidInfo.model;
//             //         request.fields['brand'] = androidInfo.brand;
//             //         request.fields['test'] = 'False'; // DB PUSH BOOLEAN
//             //         request.fields['mlModel'] = widget.mlModel;
//             //         request.fields['part'] = widget.part;
//             //         request.fields['hour'] = hour;
//             //         request.fields['flash'] = flashOn ? 1.toString() : 0.toString();
//             //         request.files.add(await http.MultipartFile.fromPath('capture', croppedImage!.path));
//             //
//             //         var res = await request.send();
//             //
//             //         Navigator.pushNamed(context, resultPage, arguments: {
//             //           'mlModel': widget.mlModel,
//             //           'part': widget.part,
//             //           'details': res.action,
//             //           'R': res.R,
//             //           'G': res.G,
//             //           'B': res.B,
//             //           'predictionResults': res.result,
//             //           'imagePath': myImagePath,
//             //         });
//             //         debugPrint('${res.result}');
//             //
//             //         debugPrint("\nThe status code is : ${res.statusCode.toString()}");
//             //         debugPrint("\nResponse Headers : ${res.headers.toString()}");
//             //         debugPrint("\nThe Reason Phrase is : ${res.reasonPhrase.toString()}");
//             //
//             //         debugPrint('Res: $res');
//             //
//             //     await provider
//             //         .fetchPredictions(croppedImage!.path, androidInfo.model,
//             //         widget.part, hour, androidInfo.brand, widget.mlModel, false)
//             //         .whenComplete(() {
//             //       var mypredictions = provider.state.predictions;
//             //
//             //
//             //       debugPrint('${mypredictions.result}');
//             //     });
//             //   } else {
//             //     setState(() {
//             //       myImagePath = imageXfile.path;
//             //       cameraOn = true;
//             //     });
//             //
//             //     await provider
//             //         .fetchPredictions(imageXfile.path, androidInfo.model, widget.part,
//             //         hour, androidInfo.brand, widget.mlModel, false)
//             //         .whenComplete(() {
//             //       var mypredictions = provider.state.predictions;
//             //       //after calling if there is no error occurs then call automatically to resultpage
//             //       Navigator.pushNamed(context, resultPage, arguments: {
//             //         'mlModel': widget.mlModel,
//             //         'part': widget.part,
//             //         'details': mypredictions.action,
//             //         'R': mypredictions.R,
//             //         'G': mypredictions.G,
//             //         'B': mypredictions.B,
//             //         'predictionResults': mypredictions.result,
//             //         'imagePath': myImagePath,
//             //       });
//             //
//             //       debugPrint('${mypredictions.result}');
//             //     });
//             //   }
//             // } catch (e) {
//             //   debugPrint('error Message is ${e.toString()}');
//             // }
//           }
//
//           if (widget.mlModel == 'BANANA') {
//             setState(() {
//               isBanana = true;
//             });
//           }
//
//           return WillPopScope(
//             onWillPop: () async => true,
//             child: SafeArea(
//               child: Stack(
//                 children: [
//                   Scaffold(
//                     appBar: AppBar(
//                       backgroundColor: primaryColor,
//
//                       centerTitle: true,
//
//                       title: isBanana
//                           ? Text('Predict ${widget.mlModel} Stages',
//                           style: const TextStyle(fontSize: 18))
//                           : Text(
//                         'Predict ${widget.mlModel} ${suffix[widget
//                             .mlModel]} (${widget.part})',
//                         style: const TextStyle(fontSize: 18),
//                       ),
//
//                       //actions: [Image.asset('images/assets/Le_Marche.png')],
//                       toolbarHeight: 60,
//                     ),
//                     backgroundColor: Colors.white,
//                     body: BlocBuilder<PredictionCubit, PredictionState>(
//                       builder: (context, state) {
//                         if (state.status == PredictioStatus.loading) {
//                           return LodingInd(
//                               msg: "finding result", model: widget.mlModel);
//                         } else if (state.status == PredictioStatus.loaded ||
//                             state.status == PredictioStatus.initial) {
//                           return cameraOn
//                               ? Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                   padding: EdgeInsets.only(
//                                       top: MediaQuery
//                                           .of(context)
//                                           .size
//                                           .width *
//                                           0.4,
//                                       left: MediaQuery
//                                           .of(context)
//                                           .size
//                                           .width *
//                                           0.3,
//                                       right: MediaQuery
//                                           .of(context)
//                                           .size
//                                           .width *
//                                           0.3),
//                                   child: SizedBox.fromSize(
//                                       size: const Size(150, 150),
//                                       child: ClipOval(
//                                           child: Material(
//                                               color: const Color.fromRGBO(
//                                                   14, 80, 95, 1),
//                                               child: InkWell(
//                                                   splashColor:
//                                                   Colors.deepOrangeAccent,
//                                                   onTap: () {
//                                                     _getImage(
//                                                         ImageSource.gallery);
//                                                   },
//                                                   child: Column(
//                                                       mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .center,
//                                                       children: const [
//                                                         Text('Gallery',
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 fontSize: 15,
//                                                                 fontWeight:
//                                                                 FontWeight
//                                                                     .bold)),
//                                                         SizedBox(
//                                                           height: 10,
//                                                         ),
//                                                         Icon(Icons.image,
//                                                             size: 50,
//                                                             color:
//                                                             Colors.white),
//                                                       ])))))),
//                               Padding(
//                                   padding: EdgeInsets.only(
//                                       top: MediaQuery
//                                           .of(context)
//                                           .size
//                                           .width *
//                                           0.15,
//                                       left: MediaQuery
//                                           .of(context)
//                                           .size
//                                           .width *
//                                           0.3,
//                                       right: MediaQuery
//                                           .of(context)
//                                           .size
//                                           .width *
//                                           0.3),
//                                   child: SizedBox.fromSize(
//                                       size: const Size(150, 150),
//                                       child: ClipOval(
//                                           clipBehavior: Clip.antiAlias,
//                                           child: Material(
//                                               color: const Color.fromRGBO(
//                                                   14, 80, 95, 1),
//                                               child: InkWell(
//                                                   splashColor:
//                                                   Colors.deepOrangeAccent,
//                                                   onTap: () {
//                                                     _getImage(
//                                                         ImageSource.camera);
//                                                   },
//                                                   child: Column(
//                                                       mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .center,
//                                                       children: const [
//                                                         Text('Take a Snap',
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 fontSize: 15,
//                                                                 fontWeight:
//                                                                 FontWeight
//                                                                     .bold)),
//                                                         SizedBox(
//                                                           height: 10,
//                                                         ),
//                                                         Icon(Icons.camera_alt,
//                                                             size: 50,
//                                                             color:
//                                                             Colors.white),
//                                                       ])))))),
//                               const MySocialFooter(),
//                               Padding(
//                                 padding: EdgeInsets.only(
//                                     left: MediaQuery
//                                         .of(context)
//                                         .size
//                                         .width *
//                                         0.120,
//                                     right: MediaQuery
//                                         .of(context)
//                                         .size
//                                         .width *
//                                         0.120),
//                                 child: SizedBox(
//                                     height: MediaQuery
//                                         .of(context)
//                                         .size
//                                         .width *
//                                         0.1),
//                               )
//                             ],
//                           )
//                               : LodingInd(
//                               msg: "Loading..", model: widget.mlModel);
//                         }
//                         return Container();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       }
//     }
//   }
// }