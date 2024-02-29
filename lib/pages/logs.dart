import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_model/constants.dart';
import '../db_model/customer_logs_response.dart';

class CustomerLogs extends StatefulWidget {
  final int customerId;
  final String customerName;
  const CustomerLogs({super.key, required this.customerId,  this.customerName=''});

  @override
  State<CustomerLogs> createState() => _CustomerLogsState();
}

class _CustomerLogsState extends State<CustomerLogs> {
  List<CustomerLogsResponse> customerLogs = [];
  bool _loading = false;
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchCustomerLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.customerName} Logs'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(label: Text('Delivery Day')),
              DataColumn(label: Text('Water Bottles Given')),
              DataColumn(label: Text('Bottles Back')),
              DataColumn(label: Text('Amount Paid')),
              DataColumn(label: Text('Delivery Date Time')),
            ],
            rows: customerLogs.map((log) {
              return DataRow(
                color:MaterialStateProperty.all<Color?>(log.deliveryDay == 'Urgent' ? Colors.redAccent : Colors.white),
                cells: [
                  DataCell(Text(log.deliveryDay.toString())),
                  DataCell(Text(log.waterBottlesGiven.toString())),
                  DataCell(Text(log.bottleBack.toString())),
                  DataCell(Text(log.amountPaid.toString())),
                  DataCell(Text(formatDateTime(log.deliveryDateTime))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  String formatDateTime(String dateTimeString) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Adjust the time to your local time zone (+5 GMT)
    dateTime = dateTime.add(Duration(hours: 5));

    // Format the adjusted DateTime into a simpler format
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }
  void fetchCustomerLogs() async {
    try {
      setState(() {
        _loading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      var params = {"customerId": widget.customerId};
      Response response = await dio.get(
        '$base_url/Customer/GetCustomerLogs',
        queryParameters: params,
        options: Options(headers: headers),
      );

      // Handle response
      if (response.statusCode == 200) {
        var data = response.data as List;
        customerLogs = data.map((doc) {
          return CustomerLogsResponse.fromMap(doc);
        }).toList();
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
}
