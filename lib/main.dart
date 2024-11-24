import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_managment_system/pages/login.dart';
import 'package:water_managment_system/pages/main_page.dart';
import 'dart:io';

import 'db_model/constants.dart';
import 'helper/api_helper.dart';


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  // Determine the initial route based on userId
  Widget initialRoute = token != null ? const MainPage() : const LoginScreen();
  await Firebase.initializeApp();
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults(const {
    "base_url": 'http://naumanwasti-001-site1.ktempurl.com/api',
    "username": '11170737',
    "password": '60-dayfreetrial',
  });
  await remoteConfig.fetchAndActivate();

  // Globals.base_url = 'https://10.0.2.2:7133/api';
  Globals.base_url = remoteConfig.getString('base_url');
  Globals.username = remoteConfig.getString('username');
  Globals.password = remoteConfig.getString('password');

  // FirebaseFirestore.instance.settings = const Settings(
  //   persistenceEnabled: true,
  // );
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final Widget initialRoute;

  const MyApp({required this.initialRoute, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aqua Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: initialRoute,
    );
  }

}



