import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qzenesapp/generated_routes.dart';
import 'package:qzenesapp/repository/predictionrepo.dart';
import 'package:qzenesapp/services/qzenes_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/constants.dart';
import 'cubits/prediction/prediction_cubit_cubit.dart';

bool auth = false;
// srish

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final prefs = await SharedPreferences.getInstance();
  // auth = await checkAuthToken(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) =>
          PredictionRepository(qzenesApiService: QzenesApiServices()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PredictionCubit>(
            create: (context) => PredictionCubit(
                predictionRepository: context.read<PredictionRepository>()),
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Qzenes Official',
          color: const Color.fromARGB(255, 12, 52, 61),
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          //managing routing by generate routes
          initialRoute: auth ? '/' : loginPage,
          onGenerateRoute: MyRoutes.route,
          //home: HomePage(),
        ),
      ),
    );
  }
}
