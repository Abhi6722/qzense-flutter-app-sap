import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff0c343d),
          leading: BackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Qzense Dashboard"),
          centerTitle: true,
        ),
        body: const WebView(
          initialUrl: 'https://dashboard.qzenselabs.com/',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
