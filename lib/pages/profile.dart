import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_managment_system/db_model/business_info.dart';
import 'package:water_managment_system/pages/analytics.dart';
import 'package:water_managment_system/pages/login.dart';

import '../db_model/constants.dart';
import '../helper/api_helper.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController numberOfBottles = TextEditingController();
  TextEditingController bottleRate = TextEditingController();
  Dio dio = Dio();
  ApiHelper apiHelper = ApiHelper();

  var date =  DateTime.now();
  BusinessInfo businessInfo = BusinessInfo(
    totalEarning: 0,
    edit: false,
    businessName: "Ahsan shop",
    totalBottle: 0,
    bottleRate: 60,
  );

  @override
  void initState() {
    super.initState();
    GetBusinessInfo();
  }

  void GetBusinessInfo() async {
    if (!mounted) return;
      try {
        Response response = await apiHelper.fetchData(
          method: 'GET',
          endpoint: 'Customer/GetBusinessInfo',
        );

        if (response.statusCode == 200) {
          businessInfo = BusinessInfo.fromMap(response.data);
          numberOfBottles.text = businessInfo.totalBottle.toString();
          bottleRate.text = businessInfo.bottleRate.toString();
          if(mounted){
            setState(() {});
          }        } else {
          showToast("Error: ${response.data['detail']}");
        }
      } catch (e) {
        showToast("Error fetching data: $e");
      }
    }


  void SaveBusinessInfo(BusinessInfo businessInfo) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      var body = {
        "Edit":true,
        "TotalBottle":businessInfo.totalBottle,
        "BottleRate":businessInfo.bottleRate,
        "TotalEarning":businessInfo.totalEarning,
        "BusinessName":businessInfo.businessName
      };
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      Response response = await dio.post('$base_url/Customer/SaveBusinessInfo',data: body,
          options: Options(headers: headers));
      if (response.statusCode == 200) {
        showToast(" ${response.data['message']}");
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
    } finally {
      setState(() {
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double widgetSpacing = width * 0.05;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Information Section
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: widgetSpacing * 2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Business Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Shop Name: ${businessInfo.businessName}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: numberOfBottles,
                      decoration: InputDecoration(
                        labelText: 'Total Bottles',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: bottleRate,
                      decoration: InputDecoration(
                        labelText: 'Bottle Rate',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: widgetSpacing),
                    ElevatedButton(
                      onPressed: () {
                        BusinessInfo business = BusinessInfo(
                          totalEarning: businessInfo.totalEarning,
                          edit: true,
                          businessName: businessInfo.businessName,
                          totalBottle: int.parse(numberOfBottles.text),
                          bottleRate: int.parse(bottleRate.text),
                        );
                        SaveBusinessInfo(business);
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
              ),
            ),

            // User Information Section
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: widgetSpacing * 1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Total Earning: ${businessInfo.totalEarning}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Total Expense: ${businessInfo.TotalExpense}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Total Customer Advance: ${businessInfo.totalAdvance}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Total Bottles Available: ${businessInfo.bottleAvailable}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Sign Out Button
            Row(
              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => {
                    clearPref(),
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    ),
                  },
                  child: Text(
                    "Sign Out",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    date = DateTime.now();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Analytics(
                          month: date.month,
                          day: date.day,
                          year: date.year,
                        ),
                      ),
                    );
                  },
                  child: Text("See Daily Analytics"), // Renamed the button
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }


  clearPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
