import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db_model/constants.dart';
import '../db_model/customer_logs_response.dart';
import '../helper/api_helper.dart';

class CustomerLogs extends StatefulWidget {
  final int customerId;
  final String customerName;
  final String phoneNumber;
  const CustomerLogs({Key? key, required this.customerId,required this.phoneNumber, this.customerName = ''}) : super(key: key);

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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(log.deliveryDay),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      String logInfo = "Customer: ${widget.customerName}\n"
                          "Water Given: ${log.waterBottlesGiven}\n"
                          "Bottles Back: ${log.bottleBack}\n"
                          "Amount Paid: ${log.amountPaid}\n"
                          "Delivery Day: ${log.deliveryDay}\n"
                          "Delivery Time: ${formatDateTime(date.toString())}";
                      showWhatsAppShareDialog(context, logInfo);
                    },
                  ),
                ],
              ),
              title: Text('Water given: ${log.waterBottlesGiven}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bottles Back: ${log.bottleBack}'),
                  Text('Amount Paid: ${log.amountPaid}'),
                  Text('Delivery Time: ${formatDateTime(date.toString())}'),
                ],
              ),
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
  void shareOnWhatsApp(String message) async {
    String phoneNumber = widget.phoneNumber.trim();
    if (!phoneNumber.startsWith('+')) {
      if (phoneNumber.startsWith('0')) {
        phoneNumber = phoneNumber.substring(1);
      }
      phoneNumber = '+92$phoneNumber';
    }
    // Construct the WhatsApp URL
    var androidUrl = "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}";

    try {
      await launchUrl(Uri.parse(androidUrl));
    } on Exception {
      showToast("WhatsApp is not installed");
    }
  }



  void showWhatsAppShareDialog(BuildContext context, String logInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Share on WhatsApp"),
          content: Text("Do you want to share this information on WhatsApp?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareOnWhatsApp(logInfo);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
