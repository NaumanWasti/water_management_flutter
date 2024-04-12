import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


// https://watermanagement20240309233504.azurewebsites.net/api
//const base_url = 'https://aquatracker.azurewebsites.net/api';
//const base_url = 'http://naumanwasti-001-site1.ktempurl.com/api';
//  const base_url = 'https://10.0.2.2:7133/api';
//const serverUrl ='https://aquatracker.azurewebsites.net/';
//const serverUrl ='http://naumanwasti-001-site1.ktempurl.com/';
// const serverUrl ='https://10.0.2.2:7133/';

//basic authorization
//String username = '11170737'; // Replace with your actual username
// String password = '60-dayfreetrial'; // Replace with your actual password
String basicAuth = 'Basic ' + base64.encode(utf8.encode('${Globals.username}:${Globals.password}'));
void showToast(String msg){
  Fluttertoast.showToast(
    backgroundColor: Colors.white,
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.black,
      fontSize: 16.0
  );
}
class Globals {
  static String base_url = ''; // Initialize with empty string
  static String username = ''; // Initialize with empty string
  static String password = ''; // Initialize with empty string
}
