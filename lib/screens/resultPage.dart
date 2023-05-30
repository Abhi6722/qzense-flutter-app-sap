import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/constants.dart';
import '../cubits/prediction/prediction_cubit_cubit.dart';
import '../widgets/LodingIndicator.dart';

var primaryColor = const Color.fromRGBO(12, 52, 61, 1);

class ResultsPage extends StatefulWidget {
  String myImagePath = '', mlModel = '', part = '', details = '';

  late int R, B, G;
  String predictionResult = '';

  ResultsPage(
      {super.key, required this.myImagePath,
      required this.B,
      required this.G,
      required this.R,
      required this.predictionResult,
      required this.mlModel,
      required this.part,
      required this.details});

  @override
  State<ResultsPage> createState() => ResultsPageState();
}

class ResultsPageState extends State<ResultsPage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String cdate = DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now());

  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iosInformation;
  bool cameraOn = true;
  File? croppedImage;
  bool getBottom = true;
  bool smallLoading = false;

  var predictionNumeric;

  @override
  void initState() {
    super.initState();
    debugPrint('initialPAth:${widget.myImagePath}');
    resultPlatformState();
    debugPrint('initialPAth:${widget.myImagePath}');

    // debugPrint(widget.mlModel);
  }

  void clearCache() async {
    var appDir = (await getTemporaryDirectory()).path;
    Directory(appDir).delete(recursive: true);
    debugPrint('Cache Cleared!');
  }

  bool isLoadig = false;

  downloadFile() async {
    setState(() {
      isLoadig = true;
      //getBottom = false;
    });
    //First method to download images and save it to Gallery
    try {
      await GallerySaver.saveImage(widget.myImagePath,
              albumName: '${widget.mlModel}/ ${widget.predictionResult} $cdate')
          .then((val) {
        if (val == true) {
          debugPrint('image Saved');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            dismissDirection: DismissDirection.down,
            content: Text('Image Saved TO Pictures'),
            backgroundColor: Colors.deepOrange,
            elevation: 6.0,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            content: Text(
              'Something went wrong ',
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ));
        }
      }).whenComplete(() => {
                setState(() {
                  isLoadig = false;
                  //getBottom = true;
                })
              });
    } catch (e) {
      debugPrint(e.toString());
    }
  }


  Future<void> resultPlatformState() async {
    if (Platform.isAndroid) {
      deviceInfoPlugin.androidInfo
          .then((value) => setState(() => {androidInfo = value}));
    }
  }

  @override
  Widget build(BuildContext context) {
    //  widget.path == null ? notNUll = true : notNUll = false;
    //double deviceSize = MediaQuery.of(context).size.width;

    var provider = BlocProvider.of<PredictionCubit>(context);

    void _getImage() async {
      // debugPrint('$autoSavedToGallery');
      // clearCache();
      XFile? imageXfile;
      try {
        setState(() {
          cameraOn = false;
        });

        imageXfile = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
        );
        if (imageXfile == null) {
          setState(() {
            cameraOn = true;
          });
        }
        debugPrint('File is :$imageXfile');

        File tempImage = File(imageXfile!.path);
        var decodedImage =
            await decodeImageFromList(tempImage.readAsBytesSync());
        if (decodedImage.height != decodedImage.width) {
          croppedImage = (await ImageCropper().cropImage(
              sourcePath: imageXfile.path,
              aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
              compressQuality: 100,
              maxWidth: 700,
              maxHeight: 700,
              compressFormat: ImageCompressFormat.png,
              // androidUiSettings: const AndroidUiSettings(
              //   lockAspectRatio: true,
              // )
          )) as File?;
          if (croppedImage == null) {
            setState(() {
              cameraOn = true;
            });
          } else {
            await provider.fetchPredictions(
                croppedImage!.path,
                androidInfo.model,
                widget.part,
                "CAM_TEST",
                androidInfo.brand,
                widget.mlModel,
                false);
            setState(() {
              widget.myImagePath = croppedImage!.path;
              cameraOn = true;
            });
            if (autoSavedToGallery) {
              downloadFile();
            }
          }
        } else {
          await provider.fetchPredictions(
              imageXfile.path,
              androidInfo.model,
              widget.part,
              'CAM_TEST',
              androidInfo.brand,
              widget.mlModel,
              false);
          debugPrint('$autoSavedToGallery');
          setState(() {
            widget.myImagePath = imageXfile!.path;
            cameraOn = true;
            widget.predictionResult = provider.state.predictions.result!;
          });
          debugPrint(widget.predictionResult);

          if (autoSavedToGallery) {
            downloadFile();
          }
        }
      } catch (e) {
        debugPrint('error Message is ${e.toString()}');
      }
    }

    return WillPopScope(
      onWillPop: () async => true,
      child: cameraOn
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      clearCache();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back)),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: Stack(
                      children: [
                        const Text('Auto Save ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(
                          height: 20,
                        ),
                        Switch(
                            activeColor: Colors.deepOrange,
                            value: autoSavedToGallery,
                            onChanged: (value) {
                              debugPrint('$autoSavedToGallery');
                              if (value) {
                                downloadFile();
                              }

                              setState(() {
                                autoSavedToGallery = value;
                              });
                              debugPrint('$autoSavedToGallery');
                            }),
                      ],
                    ),
                  ),
                ],
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff0c343d),
                centerTitle: true,
                titleTextStyle: const TextStyle(fontSize: 18),
                title: const Text('Results'),
                toolbarHeight: 60,
              ),
              extendBody: true,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterDocked,
              floatingActionButton: FloatingActionButton(
                focusColor: Colors.white,
                hoverColor: primaryColor,
                foregroundColor: Colors.white,
                splashColor: Colors.purple,
                onPressed: () {
                  _getImage();
                  debugPrint(' now PAth:${widget.myImagePath}');
                },
                backgroundColor: primaryColor,
                child: const FaIcon(Icons.camera_alt_rounded),
              ),
              bottomNavigationBar: getBottom
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width * 0.3,
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          child: BottomAppBar(
                            elevation: 2,
                            notchMargin: 6.5,
                            color: primaryColor,
                            shape: const CircularNotchedRectangle(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    const SizedBox(
                                      height: 23,
                                    ),
                                    BlocBuilder<PredictionCubit,
                                        PredictionState>(
                                      builder: (context, state) {
                                        if (state.status ==
                                            PredictioStatus.loading) {
                                          return Text(
                                              '${state.predictions.action}');
                                        }
                                        return Text(
                                            '${state.predictions.action}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17));
                                      },
                                    ),
                                    const SizedBox(
                                      height: 22,
                                    ),
                                    const Text(
                                        ' * Result are Only Indicative To Aid Consumers ',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white)),
                                  ])),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              body: BlocBuilder<PredictionCubit, PredictionState>(
                builder: (context, state) {
                  if (state.status == PredictioStatus.loading) {
                    return LodingInd(
                        msg: "fetching result", model: widget.mlModel);
                  } else if (state.status == PredictioStatus.initial ||
                      state.status == PredictioStatus.loaded) {
                    return Column(
                      children: [

                        SquareCroppedImage(path: widget.myImagePath),
                        const SizedBox(
                          height: 55,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.width * 0.4),
                              child: FittedBox(
                                child: smallLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                        ),
                                      )
                                    : Text(
                                        /* notNUll ? 'Sorry.....' :*/ "${state.predictions.result}",
                                        style: const TextStyle(fontSize: 25),
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.width * 0.4),
                              child: IndicatorIcon(
                                  R: state.predictions.R,
                                  G: state.predictions.G,
                                  B: state.predictions.B),
                            )
                          ],
                        ),
                      ],
                    );
                  }

                  return Container();
                },
              ),
            )
          : LodingInd(msg: "Loading...", model: widget.mlModel),
    );
  }
}

class SquareCroppedImage extends StatelessWidget {
  final String path;
  const SquareCroppedImage({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: FittedBox(child: Image.file(File(path))));
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
