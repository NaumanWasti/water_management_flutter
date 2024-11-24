import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_cache_manager/data_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_model/constants.dart';
import '../db_model/counter_sale_logs.dart';
import '../helper/api_helper.dart';
import 'counter_sale_logs.dart';


class CounterSales extends StatefulWidget {
  const CounterSales({Key? key}) : super(key: key);

  @override
  State<CounterSales> createState() => _CounterSalesState();
}

class _CounterSalesState extends State<CounterSales> {
  Dio dio = Dio();
  bool _loading = false;
  int counterSaleCount = 0;
  int pageSize = 1;
  int page = 1;
  late List<CounterSaleLogsModel> counterSalesList = [];
  late DateTime selectedMonth = DateTime.now();
  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  late TextEditingController bottleRateController;
  ApiHelper apiHelper = ApiHelper();
  final DataCacheManager manager = DefaultDataCacheManager.instance;


  @override
  void initState() {
    super.initState();
    bottleRateController = TextEditingController();
    GetCounterSales(selectedMonth);
  }

  @override
  void dispose() {
    // Dispose the text controller to avoid memory leaks
    bottleRateController.dispose();
    super.dispose();
  }
  void AddCounterSales(bool delete,{ int amount = 1}) async {
    try {
      setState(() {
        _loading = true;
      });
      var params = {
        "delete":delete,
        "amount":amount
      };

      Response response = await apiHelper.fetchData(
          method: 'POST',
          endpoint: 'Customer/AddCounterSales',
          params: params
      );

      if (response.statusCode == 200) {
        GetCounterSales(selectedMonth);
        showToast(" ${response.data['message']}");
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void GetCounterSales(DateTime dateTime) async {
    final List<ConnectivityResult> connectivityResult =
    await (Connectivity().checkConnectivity());
    try {
      if (!mounted) return;

      if ((connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi))) {
        setState(() {
          _loading = true;
        });

        var params = {
          "date":dateTime,
          "page":page,
          "pageSize":pageSize,
        };
        Response response = await apiHelper.fetchData(
          method: 'GET',
          endpoint: 'Customer/GetCounterSales',
          params: params,
        );
        if (response.statusCode == 200) {
          await manager.add("GetCounterSales", response.data);

          counterSaleCount = response.data['totalCounterSales'];
          var data = response.data['counterSaleLog'] as List;
          counterSalesList = data
              .map((customerData) => CounterSaleLogsModel.fromJson(customerData))
              .toList();
          var length = counterSalesList.length;
          if(length>0){
            bottleRateController.text = counterSalesList[length-1].bottleRate.toString();
          }
        } else {
          showToast("Error: ${response.data['detail']}");
        }
      }
      else{
        final cacheData = await manager.get("GetCounterSales");
        if(cacheData!=null) {
          var cachedDataMap = cacheData.value as Map<String, dynamic>;
          counterSaleCount = cachedDataMap['totalCounterSales'];
          var data = cachedDataMap['counterSaleLog'] as List;
          counterSalesList = data
              .map((customerData) => CounterSaleLogsModel.fromJson(customerData))
              .toList();
          var length = counterSalesList.length;
          if(length>0){
            bottleRateController.text = counterSalesList[length-1].bottleRate.toString();
          }
        }
      }

    } catch (e) {
    } finally {
      if (mounted) { // Check if widget is mounted before calling setState
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          margin: EdgeInsets.only(left: 100),
          child: Center(
            child: Text(
              'Counter',
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: width * 0.07,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: DateFormat('yyyy-MM').format(selectedMonth),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMonth = DateFormat('yyyy-MM').parse(newValue);
                  });
                  GetCounterSales(selectedMonth);
                }
              },
              items: months.map<DropdownMenuItem<String>>((String value) {
                int monthIndex = months.indexOf(value) + 1;
                String formattedMonth = selectedMonth.year.toString() + '-' + monthIndex.toString().padLeft(2, '0');
                return DropdownMenuItem<String>(
                  value: formattedMonth,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/logo/water_logo.png',height: 200),
            Center(
              child: _loading
                  ? CircularProgressIndicator()
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    enabled: selectedMonth.month == DateTime.now().month,
                    controller: bottleRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Amount',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (!validateNumeric(value)) {
                        // Clear the field if it contains non-numeric characters
                        bottleRateController.clear();
                      }
                      // Handle changes to the bottle rate here if needed
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Water Sold: $counterSaleCount',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed:  selectedMonth.month !=  DateTime.now().month ? null :  () {
                          if (validateNumeric(bottleRateController.text)) {
                            AddCounterSales(false,amount:  int.parse(bottleRateController.text));
                          } else {
                            showToast("Please enter a valid amount");
                          }
                          },
                      ),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: selectedMonth.month !=  DateTime.now().month ? null : () {
                          if(counterSaleCount!=0)
                          AddCounterSales(true);
                          else showToast("no sale found");
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Add some space
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to view all counter sales screen
                      // You can replace 'ViewAllCounterSalesScreen' with your appropriate screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CounterSaleLogs(dayWiseLogs: false, dateTime: selectedMonth,),
                        ),
                      );
                    },
                    child: Text('View All Counter Sales'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  bool validateNumeric(String value) {
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(value);
  }


}

