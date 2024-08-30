import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_model/constants.dart';
import '../db_model/customer_logs_response.dart';
import '../helper/api_helper.dart';

class CustomerLogs extends StatefulWidget {
  final int customerId;
  final String customerName;
  const CustomerLogs({Key? key, required this.customerId, this.customerName = ''}) : super(key: key);

  @override
  State<CustomerLogs> createState() => _CustomerLogsState();
}

class _CustomerLogsState extends State<CustomerLogs> {
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
        title: Text('${widget.customerName} Logs'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : customerLogs.isNotEmpty ?   ListView.builder(
        itemCount: customerLogs.length,
        itemBuilder: (context, index) {
          final log = customerLogs[index];
          var date = DateTime.parse(log.deliveryDateTime);
          return Card(
            child: ListTile(

              trailing: Text(log.deliveryDay),
              title: Text('Water given: ${log.waterBottlesGiven}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bottles Back: ${log.bottleBack}'),
                  Text('Amount Paid: ${log.amountPaid}'),
                  Text('Delivery Time: ${formatDateTime(date.toString())}'),
                ],
              ),
              //tileColor: log.deliveryDay == 'Urgent' ? Colors.redAccent : Colors.white,
            ),
          );
        },
      ) : Center(child: Text("No logs found"),),
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
        "customerId": widget.customerId,
      };

      Response response = await apiHelper.fetchData(
        method: 'GET',
        endpoint: 'Customer/GetCustomerLogs',
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
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
