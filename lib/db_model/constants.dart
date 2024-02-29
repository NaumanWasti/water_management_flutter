import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

const base_url = 'https://10.0.2.2:7133/api';
void showToast(String msg){
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0
  );
}