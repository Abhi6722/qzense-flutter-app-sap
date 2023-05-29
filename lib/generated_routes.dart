import 'package:flutter/material.dart';
import 'package:qzenesapp/constants/constants.dart';
import 'package:qzenesapp/screens/cameraPage.dart';
import 'package:qzenesapp/screens/fishPage.dart';
import 'package:qzenesapp/screens/bananaPage.dart';
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

        case loginPage:
          return MaterialPageRoute(builder: (_) => const LoginPage());

        case fishPage:
          Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => FishPage(
              mlModel: args['model'],
              part: args['part'],
              access: args['access'],
            ),
          );

        case bananaPage:
        Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => BananaPage(
              mlModel: args['model'],
              part: args['part'],
              access: args['access'],
            ),
        );

        case cameraPage:
          Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
              builder: (_) => CameraApp(
                    mlModel: args['model'],
                    part: args['part'],
                  ));

        case resultPage:
        Map<String, dynamic> arguements = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ResultsPage(
                  mlModel: arguements['mlModel'],
                  details: arguements['details'],
                  part: arguements['part'],
                  myImagePath: arguements['imagePath'],
                  R: arguements['R'],
                  G: arguements['G'],
                  B: arguements['B'],
                  predictionResult: arguements['predictionResult'],
                ));

        case qzenesDashboard:
          return MaterialPageRoute(builder: (_) => const DashBoard());

        case officialWebsite:
          return MaterialPageRoute(builder: (_) => const OfficialWebsite());

        default:
          return null;
    }
  }
}
