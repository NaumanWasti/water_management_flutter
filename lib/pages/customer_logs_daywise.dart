import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_model/constants.dart';
import '../db_model/customer_logs_response.dart';
import '../helper/api_helper.dart';

class CustomerLogsDayWise extends StatefulWidget {
  final int day;
  final int month;
  final int year;
  const CustomerLogsDayWise({Key? key, required this.day, required this.month, required this.year}) : super(key: key);

  @override
  State<CustomerLogsDayWise> createState() => _CustomerLogsDayWiseState();
}

class _CustomerLogsDayWiseState extends State<CustomerLogsDayWise> {
  List<CustomerLogsResponse> customerLogs = [];
  bool _loading = false;
  ApiHelper apiHelper = ApiHelper();

  @override
  void initState() {
    super.initState();
    fetchCustomerLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Deliveries'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: customerLogs.length,
        itemBuilder: (context, index) {
          final log = customerLogs[index];
          return Card(
            child: ListTile(
              title: Text('Water given: ${log.waterBottlesGiven}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bottles Back: ${log.bottleBack}'),
                  Text('Amount Paid: ${log.amountPaid}'),
                  Text('Delivery Time: ${formatDateTime(log.deliveryDateTime)}'),
                ],
              ),
              tileColor: log.deliveryDay == 'Urgent' ? Colors.redAccent : Colors.white,
            ),
          );
        },
      ),
    );
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }

  void fetchCustomerLogs() async {
    try {
      setState(() {
        _loading = true;
      });

      var params = {
        "day":widget.day,
        "month":widget.month,
        "year":widget.year
      };
      Response response = await apiHelper.fetchData(
        method: 'GET',
        endpoint: 'Customer/GetDayWiseLogs',
        params: params,
      );

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
