import 'package:flutter/material.dart';

import '../screens/homepage.dart';


class MyNavButtons extends StatelessWidget {
  bool isMyChoice = false;
  IconData? myIcon;
  // if ismychoice true then user pass an icon

  MyNavButtons({
    Key? key,
    required this.isMyChoice,
    this.myIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: <Widget>[
        Flexible(
          flex: 1,

          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: primaryColor,
              ),
              child: Center(
                  // child: FaIcon(
                  //   FontAwesomeIcons.earthEurope,
                  //   color: Colors.white,
                  //   size: 70,
                  // ),
                  child: isMyChoice
                      ? Icon(
                          myIcon,
                          color: Colors.deepOrangeAccent,
                          size: 60,
                        )
                      : Text(
                          'Q-Scan',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        )), //oration
            ),
          ), //Container
        ), //Flexible
      ], //<Widget>[]
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}
