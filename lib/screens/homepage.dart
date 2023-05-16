import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


import '../constants/constants.dart';

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
    var emailId = emailPref.getString('email') ?? "";
    debugPrint('$emailId :');
    setState(() {
      finalEmailId = emailId;
      if (finalEmailId != '') {
        finalEmailId = finalEmailId.substring(0, finalEmailId.indexOf('@'));
      }
    });
  }

  @override
  void initState() {
    getemail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // String userName = '';
    // debugPrint(emailId);

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
                padding: const EdgeInsets.all(40),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //
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
                              Navigator.pushNamed(context, Official_Website);
                            },
                            child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Image.asset('images/assets/logo.webp')),
                          ),
                          const NavButtons(),
                          const SizedBox(
                            height: 60,
                          ),
                          const DropDownSelection(),
                          const SocialFooter(),
                        ]),
                  ],
                ))));
    // );
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
                // child: FaIcon(
                //   FontAwesomeIcons.earthEurope,
                //   color: Colors.white,
                //   size: 70,
                // ),
                child: Text(
                  'Q-Log',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ), //BoxDecoration
            ),
          ), //Container
        ), //Flexible
        const SizedBox(
          width: 20,
        ), //SizedBox
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Qzenes_dashboard);
            },
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: primaryColor,
              ),
              child: const Center(
                  // child: FaIcon(
                  //   FontAwesomeIcons.chartColumn,
                  //   color: Colors.white,
                  //   size: 70,
                  // ),
                  child: Text(
                'Q-Scan',
                style: TextStyle(color: Colors.white, fontSize: 30),
              )), //BoxDecoration
            ),
          ), //Container
        ) //Flexible
      ], //<Widget>[]
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
    // return DropdownButtonFormField(
    //   style: TextStyle(color: primaryColor),
    //   onChanged: (val) {
    //     if (val == subscription[1]) {
    //       Navigator.pushNamed(context, '/predict',
    //           arguments: {'model': 'BANANA', 'part': val});
    //     } else {
    //       Navigator.pushNamed(context, '/predict',
    //           arguments: {'model': 'FISH', 'part': val});
    //     }
    //   },
    //   icon: Icon(
    //     Icons.arrow_downward_sharp,
    //     color: primaryColor,
    //   ),
    //   decoration: InputDecoration(
    //       border: const OutlineInputBorder(
    //         borderRadius: BorderRadius.all(
    //           Radius.circular(10.0),
    //         ),
    //       ),
    //       filled: true,
    //       hintStyle: TextStyle(color: primaryColor),
    //       hintText: "Select",
    //       fillColor: Colors.white),
    //   items: subscription
    //       .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
    //             child: Text(
    //               e,
    //               style: const TextStyle(color: Colors.black),
    //             ),
    //             value: e,
    //           ))
    //       .toList(),
    // );
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
              onTap: () {
                Navigator.pushNamed(context, Camera_page,
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
                  ))),
                ),
              )),
          const SizedBox(
            width: 15,
          ),
          InkWell(
              onTap: () {
                Navigator.pushNamed(context, Camera_page,
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
                  ))),
                ),
              )),
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
              ElevatedButton(
                child: const Text('Yes'),
                onPressed: () {
                  setState(() {
                    userLogout = true;
                  });
                  userLogout ? _removeTokens() : null;
                  Navigator.popUntil(context, (route) => false);
                  Navigator.pushNamed((context), Login_page);
                },
              ),
              ElevatedButton(
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
        });
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
            borderRadius: BorderRadius.circular(10)),
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
