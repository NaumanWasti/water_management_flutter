import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_managment_system/pages/calender_widget.dart';
import 'package:water_managment_system/pages/main_page.dart';
import 'package:water_managment_system/pages/profile.dart';

import '../db_model/constants.dart';
import '../db_model/counter_sale_logs.dart';
import '../helper/api_helper.dart';
import 'counter_sale_logs.dart';
import 'customer_logs_daywise.dart';
import 'expenses_logs.dart';

class Analytics extends StatefulWidget {
  final int day;
  final int month;
  final int year;
  const Analytics({super.key,required this.month,required this.day, required this.year});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  Dio dio = Dio();
  int totalCounterSales = 0;
  int totalExpenses = 0;
  int totalDeliverySales = 0;
  int counterSaleCount = 0;
  late List<CounterSaleLogsModel> counterSalesList = [];
  late DateTime selectedMonth = DateTime.now();
  ApiHelper apiHelper = ApiHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetBusinessInfo();
    selectedMonth = DateTime(widget.year, widget.month, widget.day);
   // GetCounterSales(selectedMonth);

  }
  void GetCounterSales(DateTime dateTime) async {
    try {
      if (!mounted) return;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      var params = {
        "date":dateTime,
        "dayWiseLogs":true
      };
      Response response = await dio.get('$base_url/Customer/GetCounterSales', queryParameters: params, options: Options(headers: headers));
      if (response.statusCode == 200) {
        counterSaleCount = response.data['totalCounterSales'];
        var data = response.data['counterSaleLog'] as List;
        counterSalesList = data
            .map((customerData) => CounterSaleLogsModel.fromJson(customerData))
            .toList();
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
    } finally {
      if (mounted) { // Check if widget is mounted before calling setState
      }
    }
  }

  void GetBusinessInfo() async {
    if (!mounted) return;
    try {
      var params = {
        "day":widget.day,
        "month":widget.month,
        "year":widget.year
      };
      Response response = await apiHelper.fetchData(
        method: 'GET',
        endpoint: 'Customer/GetAnalytics',
        params: params
      );

      if (response.statusCode == 200) {
        totalCounterSales = response.data['totalCounterSale'];
        totalExpenses = response.data['totalExpense'];
        totalDeliverySales = response.data['totalDeliverySale'];
        if(mounted){
          setState(() {});
        }
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage(initialTabIndex: 3,)), // Replace CalendarWidget with your actual calendar widget
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Analytics'),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${widget.month}/${widget.day}/${DateTime.now().year}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Counter Sales: $totalCounterSales',
                    style: TextStyle(fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CounterSaleLogs(dayWiseLogs: true, dateTime: DateTime(widget.year,widget.month,widget.day,DateTime.now().hour),),
                        ),
                      );
                     },
                    child: Text('View Details'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Expenses: $totalExpenses',
                    style: TextStyle(fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExpenseLogsPage(day: widget.day, month: widget.month, year: widget.year,)), // Replace CalendarWidget with your actual calendar widget
                      );
                      // Handle view expenses details
                    },
                    child: Text('View Details'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Delivery Sales: $totalDeliverySales',
                    style: TextStyle(fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerLogsDayWise(day: widget.day, month: widget.month, year: widget.year,)), // Replace CalendarWidget with your actual calendar widget
                    );
                    },
                    child: Text('View Details'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalenderWidget()), // Replace CalendarWidget with your actual calendar widget
                  );
                },
                child: Text('Change Date'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
