import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_managment_system/helper/api_helper.dart';
import 'package:water_managment_system/pages/expenses.dart';
import 'package:water_managment_system/pages/profile.dart';

import '../db_model/constants.dart';
import 'counter_sales.dart';
import 'customers.dart';
import 'deliveries.dart';

class MainPage extends StatefulWidget {
  final int initialTabIndex;

  const MainPage({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<MainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MainPage> {
  late int _selectedTab;
ApiHelper apiHelper = new ApiHelper();
Dio dio = new Dio();
  List<Widget> _pages = [
    Center(
      child: Customers(),
    ),
    Center(
      child: Delieveries(),
    ),
    Center(
      child: CounterSales(),
    ),
    Center(
      child: Profile(),
    ),
    Center(
      child: ExpensePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    updateDeliveryCompletedRejectedCheck();
    _selectedTab = widget.initialTabIndex;
  }
  void updateDeliveryCompletedRejectedCheck() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var userId = sharedPreferences.getInt("id");
      var date = DateTime.now();
      print(date);
      var params = {
        "date": date,
        "userId":userId
      };
      Map<String, String> headers = {
        'authorization': basicAuth,
      };
      Options options = Options(
        headers: headers,
      );
      var response = await dio.post(
       // '${Globals.base_url}/Customer/UpdateCompletedRejected',
        'https://10.0.2.2:7133/api/Customer/UpdateCompletedRejected',
        options: options,
        queryParameters: params
      );
      if (response.statusCode == 200) {
        print("response");
        print(response.data['message'].toString());
      } else {
      }
    } catch (e) {
    }
  }

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Customers"),
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: "Deliveries"),
          BottomNavigationBarItem(icon: Icon(Icons.countertops_outlined), label: "Counter"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.add_card_sharp), label: "Expense"),
        ],
      ),
    );
  }
}
