import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_model/constants.dart';
import '../db_model/counter_sale_logs.dart';
import 'counter_sale_logs.dart';


class CounterSales extends StatefulWidget {
  const CounterSales({Key? key}) : super(key: key);

  @override
  State<CounterSales> createState() => _CounterSalesState();
}

class _CounterSalesState extends State<CounterSales> {
  Dio dio = Dio();
  bool _loading = false;
  late List<CounterSaleLogsModel> counterSalesList = [];
  int counterSaleCount = 0;
  @override
  void initState() {
    super.initState();
    GetCounterSales();
  }
  void AddCounterSales(bool delete) async {
    try {
      setState(() {
        _loading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      var params = {
        "delete":delete,
      };
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      Response response = await dio.post('$base_url/Customer/AddCounterSales',queryParameters: params,
          options: Options(headers: headers));
      if (response.statusCode == 200) {
        GetCounterSales();
        showToast(" ${response.data['message']}");
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
 void GetCounterSales() async {
    try {
      setState(() {
        _loading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      Response response = await dio.get('$base_url/Customer/GetCounterSales',
          options: Options(headers: headers));
      if (response.statusCode == 200) {
        counterSaleCount = response.data['totalCounterSales'];
        var data  = response.data['counterSaleLog'] as List;
        counterSalesList = data
            .map((customerData) => CounterSaleLogsModel.fromJson(customerData))
            .toList();
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(
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
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Water Bottles Sold: $counterSaleCount',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    AddCounterSales(false);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    AddCounterSales(true);
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
                    builder: (context) => CounterSaleLogs(counterSaleLogsModel: counterSalesList,),
                  ),
                );
              },
              child: Text('View All Counter Sales'),
            ),
          ],
        ),
      ),
    );
  }

}
