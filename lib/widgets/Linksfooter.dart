import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qzenesapp/screens/homepage.dart';

import 'package:url_launcher/url_launcher.dart';

class MySocialFooter extends StatefulWidget {
  const MySocialFooter({Key? key}) : super(key: key);

  @override
  State<MySocialFooter> createState() => _MySocialFooterState();
}

class _MySocialFooterState extends State<MySocialFooter> {
  Future<void> _launchSocial(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

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
