import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_managment_system/pages/main_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../db_model/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Dio dio = Dio();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true; // Track whether the password is currently obscured or not
  bool _loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/logo/water_logo.png',
                    height: 250, // Adjust logo size
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      // You can add more password validation here if needed
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        loginAsync(
                            emailController.text, passwordController.text);
                      }
                    },
                    child: _loading ? CircularProgressIndicator() : Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loginAsync(String email, String password) async {
    try {
      setState(() {
        _loading = true;
      });
      var body = {"email": email, "password": password};
      Map<String, String> headers = {
        'authorization': basicAuth,
      };
      Options options = Options(
        headers: headers,
      );
      var response = await dio.post(
        '${Globals.base_url}/User/Login',
        data: body,
        options: options,
      );
      // Handle response
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = response.data['token'];
        var id = response.data['id'];

        String userName = response.data['userName'];
        String role = response.data['role'];
        prefs.setString("token", token);
        prefs.setInt("id", id);
        prefs.setString("role", role);
        showToast("Login successful");
        FocusScope.of(context).unfocus();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        showToast("Error: ${response.data['detail']}");
        print('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      showToast(e.response!.data["title"]);
      print(e.response!.data["title"]);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
}
