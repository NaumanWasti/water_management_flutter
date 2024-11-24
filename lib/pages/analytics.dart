import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_cache_manager/data_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  final DateTime date;
  const Analytics({super.key,required this.date});

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
 // late DateTime selectedMonth = DateTime.now();
  ApiHelper apiHelper = ApiHelper();
  final DataCacheManager manager = DefaultDataCacheManager.instance;


  bool loader = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetAnalytics();
    //selectedMonth = DateTime(widget.year, widget.month, widget.day);
   // GetCounterSales(selectedMonth);

  }
  // void GetCounterSales(DateTime dateTime) async {
  //   try {
  //     if (!mounted) return;
  //     var params = {
  //       "date":dateTime,
  //       "dayWiseLogs":true
  //     };
  //     Response response = await apiHelper.fetchData(
  //         method: 'GET',
  //         endpoint: 'Customer/GetCounterSales',
  //         params: params
  //     );
  //     if (response.statusCode == 200) {
  //       counterSaleCount = response.data['totalCounterSales'];
  //       var data = response.data['counterSaleLog'] as List;
  //       counterSalesList = data
  //           .map((customerData) => CounterSaleLogsModel.fromJson(customerData))
  //           .toList();
  //     } else {
  //       showToast("Error: ${response.data['detail']}");
  //     }
  //   } catch (e) {
  //     showToast("Error fetching data: $e");
  //   } finally {
  //     if (mounted) { // Check if widget is mounted before calling setState
  //     }
  //   }
  // }

  void GetAnalytics() async {
    final List<ConnectivityResult> connectivityResult =
    await (Connectivity().checkConnectivity());
    if (!mounted) return;
    setState(() {
      loader = true;
    });
    try {
        if ((connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi))){
        var params = {
          "date":widget.date,
          "userId":0
        };
        Response response = await apiHelper.fetchData(
            method: 'GET',
            endpoint: 'Customer/GetAnalytics',
            params: params
        );

        if (response.statusCode == 200) {
          await manager.add("GetAnalytics", response.data);

          totalCounterSales = response.data['totalCounterSale'];
          totalExpenses = response.data['totalExpense'];
          totalDeliverySales = response.data['totalDeliverySale'];

        } else {
          showToast("Error: ${response.data['detail']}");
        }
      }
      else{
        final cacheData = await manager.get("GetAnalytics");
        if(cacheData!=null) {
          var cachedDataMap = cacheData.value as Map<String, dynamic>;
          totalCounterSales = cachedDataMap['totalCounterSale'];
          totalExpenses = cachedDataMap['totalExpense'];
          totalDeliverySales = cachedDataMap['totalDeliverySale'];
        }
      }

    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    finally{
      loader = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
          context,
          MaterialPageRoute(builder: (context) => MainPage(initialTabIndex: 3,)), // Replace CalendarWidget with your actual calendar widget
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Analytics'),
        ),
        body: loader ? Center( child: CircularProgressIndicator(), ) : Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${widget.date.month}/${widget.date.day}/${widget.date.year}',
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
                              CounterSaleLogs(dayWiseLogs: true, dateTime: widget.date,),
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
                        MaterialPageRoute(builder: (context) => ExpenseLogsPage(date: widget.date,)), // Replace CalendarWidget with your actual calendar widget
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
                      MaterialPageRoute(builder: (context) => CustomerLogsDayWise(date: widget.date)), // Replace CalendarWidget with your actual calendar widget
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
