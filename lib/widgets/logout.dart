import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../screens/homepage.dart';

class MyLogoutButton extends StatefulWidget {
  bool isIconButton = false;
  MyLogoutButton({Key? key, required this.isIconButton}) : super(key: key);

  @override
  State<MyLogoutButton> createState() => MyLogoutButtonState();
}

class MyLogoutButtonState extends State<MyLogoutButton> {
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
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(),
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
                style: ButtonStyle(),
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
        ));
  }
}
