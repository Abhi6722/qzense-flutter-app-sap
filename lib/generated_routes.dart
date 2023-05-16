import 'package:flutter/material.dart';
import 'package:qzenesapp/constants/constants.dart';
import 'package:qzenesapp/screens/cameraPage.dart';


import 'package:qzenesapp/screens/homepage.dart';
import 'package:qzenesapp/screens/loginpage.dart';
import 'package:qzenesapp/screens/resultPage.dart';
import 'package:qzenesapp/webview/official_website.dart';


import 'package:qzenesapp/webview/qzenes_dashboard.dart';

class MyRoutes {
  static Route? route(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case Login_page:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case Camera_page:
        Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => CameraApp(mlModel:    args['model'],
                  part: args['part'],) );
      case Result_Page:
        Map<String, dynamic> arguements =
            settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
            builder: (_) => ResultsPage(
                  mlModel: arguements['mlModel'],
                  details: arguements['details'],
                  part: arguements['part'],
                  myImagePath: arguements['imagePath'],
                  R: arguements['R'],
                  G: arguements['G'],
                  B: arguements['B'],
                  predictionResult: arguements['predictionResults'],
                ));
      case Qzenes_dashboard:
        return MaterialPageRoute(builder: (_) => const DashBoard());
      case Official_Website:
        return MaterialPageRoute(builder: (_) => const OfficialWebsite());
      default:
        return null;
    }
  }
}
