import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qzenesapp/screens/homepage.dart';

import '../constants/constants.dart';
import '../cubits/prediction/prediction_cubit_cubit.dart';
import '../widgets/Linksfooter.dart';
import '../widgets/LodingIndicator.dart';

class CameraApp extends StatefulWidget {
  String mlModel = '';
  String part = '';

  CameraApp({Key? key, required this.mlModel, required this.part})
      : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  bool cameraOn = true;
  // String mlModel = 'BANANA';
  // String part = 'BANANA';

  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iosInformation;
  late int R, G, B;
  dynamic size;
  bool isRightHanded = true;

  XFile? imageFile;

  bool isBanana = false;

  // bool notCropped = false;
  File? croppedImage;
  int predictionNumeric = -1;
  bool flashOn = false;

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

  @override
  void initState() {
    super.initState();
    initPlatformState();
    debugPrint(widget.mlModel);
  }

  void setCameraOn() {
    setState(() {
      cameraOn = true;
    });
  }


  @override
  build(BuildContext context) {
    size = MediaQuery.of(context).size; // fetch screen size

    //for setting default orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //instance of cubit to handle state management
    var provider = BlocProvider.of<PredictionCubit>(context);
    // method to implement the logic of camera and calling cubit & api
    void _getImage(ImageSource source) async {
      try {
        setState(() {
          cameraOn = false;
        });

        //picking image from camera  and gallery
        XFile? imageXfile = await ImagePicker().pickImage(
          source: source,
          imageQuality: 50,
        );
        if (imageXfile == null) {
          setState(() {
            cameraOn = true;
          });
        }

        //debugPrint('$imageXfile');
        // code for getting dimention of selected image
        File tempImage = File(imageXfile!.path);
        var decodedImage =
            await decodeImageFromList(tempImage.readAsBytesSync());
        if (decodedImage.height != decodedImage.width) {
          //if image is not square then cropper opens else call to api
          croppedImage = (await ImageCropper().cropImage(
              sourcePath: imageXfile.path,
              aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
              compressQuality: 100,
              maxWidth: 700,
              maxHeight: 700,
              compressFormat: ImageCompressFormat.png,
              // androidUiSettings: AndroidUiSettings(
              //   lockAspectRatio: true,
              // )
              )) as File?;
          if (croppedImage == null) {
            setState(() {
              cameraOn = true;
            });
          }

          setState(() {
            myImagePath = croppedImage!.path;
            cameraOn = true;
          });
          //method for calling fetchPrediction method of prediction cubit class

          await provider
              .fetchPredictions(croppedImage!.path, androidInfo.model,
                  widget.part, hour, androidInfo.brand, widget.mlModel, false)
              .whenComplete(() {
            var mypredictions = provider.state.predictions;
            Navigator.pushNamed(context, Result_Page, arguments: {
              'mlModel': widget.mlModel,
              'part': widget.part,
              'details': mypredictions.action,
              'R': mypredictions.R,
              'G': mypredictions.G,
              'B': mypredictions.B,
              'predictionResults': mypredictions.result,
              'imagePath': myImagePath,
            });

            //debugPrint('${mypredictions.result}');
          });
        } else {
          setState(() {
            myImagePath = imageXfile.path;
            cameraOn = true;
          });
          await provider
              .fetchPredictions(imageXfile.path, androidInfo.model, widget.part,
                  hour, androidInfo.brand, widget.mlModel, false)
              .whenComplete(() {
            var mypredictions = provider.state.predictions;
            //after calling if there is no error occurs then call automatically to resultpage
            Navigator.pushNamed(context, Result_Page, arguments: {
              'mlModel': widget.mlModel,
              'part': widget.part,
              'details': mypredictions.action,
              'R': mypredictions.R,
              'G': mypredictions.G,
              'B': mypredictions.B,
              'predictionResults': mypredictions.result,
              'imagePath': myImagePath,
            });

            //debugPrint('${mypredictions.result}');
          });
        }
      } catch (e) {
        debugPrint('error Message is ${e.toString()}');
      }
    }

    if (widget.mlModel == 'BANANA') {
      setState(() {
        isBanana = true;
      });
    }

    return WillPopScope(
        onWillPop: () async => true,
        child: SafeArea(
            child: Stack(children: [
          Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,

                centerTitle: true,

                title: isBanana
                    ? Text('Predict ${widget.mlModel} Stages',
                        style: const TextStyle(fontSize: 18))
                    : Text(
                        'Predict ${widget.mlModel} ${suffix[widget.mlModel]} (${widget.part})',
                        style: const TextStyle(fontSize: 18),
                      ),

                //actions: [Image.asset('images/assets/Le_Marche.png')],
                toolbarHeight: 60,
              ),
              backgroundColor: Colors.white,
              body: BlocBuilder<PredictionCubit, PredictionState>(
                builder: (context, state) {
                  if (state.status == PredictioStatus.loading) {
                    return LodingInd(
                        msg: "finding result", model: widget.mlModel);
                  } else if (state.status == PredictioStatus.loaded ||
                      state.status == PredictioStatus.initial) {
                    return cameraOn
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.width *
                                          0.4,
                                      left: MediaQuery.of(context).size.width *
                                          0.3,
                                      right: MediaQuery.of(context).size.width *
                                          0.3),
                                  child: SizedBox.fromSize(
                                      size: const Size(150, 150),
                                      child: ClipOval(
                                          child: Material(
                                              color:
                                                  const Color.fromRGBO(14, 80, 95, 1),
                                              child: InkWell(
                                                  splashColor:
                                                      Colors.deepOrangeAccent,
                                                  onTap: () {
                                                    _getImage(
                                                        ImageSource.gallery);
                                                  },
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Text('Gallery',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Icon(Icons.image,
                                                            size: 50,
                                                            color:
                                                                Colors.white),
                                                      ])))))),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.width *
                                          0.15,
                                      left: MediaQuery.of(context).size.width *
                                          0.3,
                                      right: MediaQuery.of(context).size.width *
                                          0.3),
                                  child: SizedBox.fromSize(
                                      size: const Size(150, 150),
                                      child: ClipOval(
                                          clipBehavior: Clip.antiAlias,
                                          child: Material(
                                              color:
                                                  const Color.fromRGBO(14, 80, 95, 1),
                                              child: InkWell(
                                                  splashColor:
                                                      Colors.deepOrangeAccent,
                                                  onTap: () {
                                                    _getImage(
                                                        ImageSource.camera);
                                                  },
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Text('Take a Snap',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Icon(Icons.camera_alt,
                                                            size: 50,
                                                            color:
                                                                Colors.white),
                                                      ])))))),
                              const MySocialFooter(),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.120,
                                    right: MediaQuery.of(context).size.width *
                                        0.120),
                                child: SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.1),
                              )
                            ],
                          )
                        : LodingInd(msg: "Loading..", model: widget.mlModel);
                  }
                  return Container();
                },
              ))
        ])));
  }
}
