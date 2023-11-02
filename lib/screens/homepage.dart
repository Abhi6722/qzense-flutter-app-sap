import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../constants/constants.dart';
import 'package:http/http.dart' as http;

Color primaryColor = const Color.fromRGBO(12, 52, 61, 1);
String finalEmailId = '';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

String twitterUrl = 'https://twitter.com/QzenseLabs';
String facebookUrl = 'https://www.facebook.com/qzense';
String instagramUrl = 'https://www.instagram.com/qzenselabs/?hl=en';
String linkedInUrl = 'https://in.linkedin.com/company/qzense/';

var accessToken = '';

Future getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  accessToken = prefs.getString('token')!;
  debugPrint('Access Token : $accessToken');
}

void fetchData() async {
  final prefs = await SharedPreferences.getInstance();
  final localDataList = prefs.getStringList('localData');

  if (localDataList != null) {
    // Data exists in shared preferences, use it directly
    final List<List<String>> localData = localDataList
        .map((item) => item.split(', '))
        .toList();

    print('Using data from SharedPreferences: $localData');

    // You can update your dropdownData or do any other necessary actions here.

  } else {
    // Data doesn't exist in shared preferences, make a GET request
    final url = Uri.parse('http://43.204.133.133:8000/sap/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['List'];
        List<List<String>> localData = dataList
            .map((item) => List<String>.from(item.cast<String>()))
            .toList();

        // Store the data in local storage
        final prefs = await SharedPreferences.getInstance();
        prefs.setStringList('localData', localData.map((e) => e.join(', ')).toList());

        print('Data fetched and stored in SharedPreferences: $localData');
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}


Future<void> _launchSocial(String url) async {
  // ignore: deprecated_member_use
  if (!await launch(
    url,
    forceSafariVC: false,
    forceWebView: false,
    headers: <String, String>{'my_header_key': 'my_header_value'},
  )) {
    throw 'Could not launch $url';
  }
}

class _HomePageState extends State<HomePage> {
  void getemail() async {
    final emailPref = await SharedPreferences.getInstance();
    var emailId = emailPref.getString('email') ?? '';
    debugPrint('Email: $emailId');
    setState(() {
      finalEmailId = emailId;
      if (finalEmailId != '') {
        finalEmailId = finalEmailId.substring(0, finalEmailId.indexOf('@'));
      }
    });
  }

  final stt.SpeechToText _speech = stt.SpeechToText();
  String _lastRecognizedWords = '';
  FlutterTts ftts = FlutterTts();

  void initializeSpeechRecognition() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _lastRecognizedWords = result.recognizedWords;
              handleVoiceCommand(_lastRecognizedWords);
            });
          }
        },
      );
    } else {
      debugPrint('Speech recognition not available');
    }
  }

  void handleVoiceCommand(String command) {
    if (command.toLowerCase() == 'hey qzense') {
      // Respond to the wake-up command
      _speak('Which model do you want to choose? Fish, Gills, or Banana?');
    } else if (command.toLowerCase() == 'fish') {
      // Perform action for Fish
      _speak('Opening Fish model...');
      setState(() {
        getAccessToken();
      });
      debugPrint(accessToken);
      Navigator.pushNamed(context, fishPage,
          arguments: {'model': 'FISH', 'part': 'body', 'access': accessToken});
    } else if (command.toLowerCase() == 'gills') {
      // Perform action for Gills
      _speak('Opening Gills model...');
      setState(() {
        getAccessToken();
      });
      debugPrint(accessToken);
      Navigator.pushNamed(context, fishPageTest,
          arguments: {'model': 'FISH', 'part': 'GILLS', 'access': accessToken});
    } else if (command.toLowerCase() == 'banana') {
      // Perform action for Banana
      _speak('Opening Banana model...');
      setState(() {
        getAccessToken();
      });
      debugPrint(accessToken);
      Navigator.pushNamed(context, bananaPage,
          arguments: {'model': 'BANANA', 'part': 'BANANA', 'access': accessToken});
    } else if (command.toLowerCase() == 'click picture') {
      // Perform action for clicking a picture
      _speak('Opening camera...');
      // Add code to open the camera and take a picture
      // After taking the picture, send the data to the backend and display the result on the screen
    }
  }

  Future<void> _speak(String text) async {
    await ftts.setLanguage("en-US");
    await ftts.setSpeechRate(0.4); //speed of speech
    await ftts.setVolume(1.0); //volume of speech
    await ftts.setPitch(1); //pitch of sound
    var speakResult = await ftts.speak(text);
  }

  @override
  void initState() {
    getemail();
    super.initState();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UserIcon(userName: finalEmailId),
                  const SizedBox(width: 15),
                  const LogoutButton(),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, officialWebsite);
                    },
                    child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Image.asset('images/assets/logo.webp')),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    _speak('Opening Fish model...');
                                    setState(() {
                                      getAccessToken();
                                      fetchData();
                                    });
                                    debugPrint(accessToken);
                                    Navigator.pushNamed(context, fishPage,
                                        arguments: {
                                          'model': 'FISH',
                                          'part': 'body',
                                          'access': accessToken
                                        });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: primaryColor, width: 1.5),
                                    ),
                                    child: Ink(
                                      height: 130,
                                      width: 130,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'images/assets/wholefish.png',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    _speak('Opening Gills model...');
                                    setState(() {
                                      getAccessToken();
                                    });
                                    debugPrint(accessToken);
                                    Navigator.pushNamed(context, fishPageTest,
                                        arguments: {
                                          'model': 'FISH',
                                          'part': 'GILLS',
                                          'access': accessToken
                                        });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: primaryColor, width: 1.5),
                                    ),
                                    child: Ink(
                                      height: 130,
                                      width: 130,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'images/assets/gills.png',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            // InkWell(
                            //   onTap: () {
                            //     _speak('Opening Banana model...');
                            //     setState(() {
                            //       getAccessToken();
                            //     });
                            //     debugPrint(accessToken);
                            //     Navigator.pushNamed(context, bananaPage,
                            //         arguments: {
                            //           'model': 'BANANA',
                            //           'part': 'BANANA',
                            //           'access': accessToken
                            //         });
                            //   },
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(15),
                            //       border: Border.all(
                            //           color: primaryColor, width: 1.5),
                            //     ),
                            //     child: Ink(
                            //       height: 130,
                            //       width: 130,
                            //       decoration: const BoxDecoration(
                            //         image: DecorationImage(
                            //           image: AssetImage(
                            //             'images/assets/bananaimage.png',
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SocialFooter(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewArguments {
  final String title;
  final String message;
  WebViewArguments(this.title, this.message);
}

class SocialFooter extends StatelessWidget {
  const SocialFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                _launchSocial(twitterUrl);
              },
              icon: const FaIcon(
                FontAwesomeIcons.twitter,
                color: Color.fromARGB(192, 12, 52, 61),
              ),
            ),
            IconButton(
              onPressed: () {
                _launchSocial(facebookUrl);
              },
              icon: const FaIcon(
                FontAwesomeIcons.facebook,
                color: Color.fromARGB(192, 12, 52, 61),
              ),
            ),
            IconButton(
              onPressed: () {
                _launchSocial(instagramUrl);
              },
              icon: const FaIcon(
                FontAwesomeIcons.instagram,
                color: Color.fromARGB(192, 12, 52, 61),
              ),
            ),
            IconButton(
              onPressed: () {
                _launchSocial(linkedInUrl);
              },
              icon: const FaIcon(
                FontAwesomeIcons.linkedin,
                color: Color.fromARGB(192, 12, 52, 61),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NavButtons extends StatelessWidget {
  const NavButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: primaryColor,
              ),
              child: const Center(
                child: Text(
                  'Q-Log',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: GestureDetector(
            onTap: () {
              // Navigator.pushNamed(context, qzenesDashboard);
            },
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: primaryColor,
              ),
              child: const Center(
                child: Text(
                  'Q-Scan',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DropDownSelection extends StatefulWidget {
  const DropDownSelection({Key? key}) : super(key: key);

  @override
  State<DropDownSelection> createState() => _DropDownSelectionState();
}

class _DropDownSelectionState extends State<DropDownSelection> {
  List<String> subscription = ['GILLS', 'BANANA'];
  String currComm = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, cameraPage,
                  arguments: {'model': 'FISH', 'part': subscription[0]});
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryColor, width: 1.5),
              ),
              child: Ink(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'images/assets/Fish.png',
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, cameraPage,
                  arguments: {'model': 'BANANA', 'part': subscription[1]});
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryColor, width: 1.5),
              ),
              child: Ink(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'images/assets/Bananana.png',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutButton extends StatefulWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool userLogout = false;

  Future<void> _removeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    prefs
        .remove('email')
        .then((value) => {debugPrint('email removed : $value')});
    prefs
        .remove('token')
        .then((value) => {debugPrint('Token removed : $value')});
    debugPrint('Removed Email and Token credentials from Local Storage!');
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            MaterialButton(
              color: primaryColor,
              textColor: Colors.white,
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  userLogout = true;
                });
                userLogout ? _removeTokens() : null;
                Navigator.popUntil(context, (route) => false);
                Navigator.pushNamed((context), loginPage);
              },
            ),
            MaterialButton(
              color: primaryColor,
              textColor: Colors.white,
              child: const Text('No'),
              onPressed: () {
                setState(() {
                  userLogout = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _displayDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(6.5),
          child: FaIcon(
            FontAwesomeIcons.powerOff,
            color: Color.fromRGBO(12, 52, 61, 1),
          ),
        ),
      ),
    );
  }
}

class UserIcon extends StatelessWidget {
  final String userName;
  const UserIcon({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.user),
          const SizedBox(
            width: 10,
          ),
          Text(userName),
        ],
      ),
    );
  }
}
