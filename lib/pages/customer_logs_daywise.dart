import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_cache_manager/data_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_model/constants.dart';
import '../db_model/customer_logs_response.dart';
import '../helper/api_helper.dart';

class CustomerLogsDayWise extends StatefulWidget {
  final DateTime date;
  const CustomerLogsDayWise({Key? key, required this.date}) : super(key: key);

  @override
  State<CustomerLogsDayWise> createState() => _CustomerLogsDayWiseState();
}

class _CustomerLogsDayWiseState extends State<CustomerLogsDayWise> {
  List<CustomerLogsResponse> customerLogs = [];
  bool _loading = false;
  ApiHelper apiHelper = ApiHelper();
  final DataCacheManager manager = DefaultDataCacheManager.instance;

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
          var date = DateTime.parse(log.deliveryDateTime);
          return Card(
            child: ListTile(
              title: Text('Water given: ${log.waterBottlesGiven}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bottles Back: ${log.bottleBack}'),
                  Text('Amount Paid: ${log.amountPaid}'),
                  Text('Delivery Time: ${formatDateTime(date.toString())}'),
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
      final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

      if ((connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi))) {
        setState(() {
          _loading = true;
        });
        var params = {
          "date":widget.date,
          "userId" : 0
        };
        Response response = await apiHelper.fetchData(
          method: 'GET',
          endpoint: 'Customer/GetDayWiseLogs',
          params: params,
        );

        if (response.statusCode == 200) {
          await manager.add("GetDayWiseLogs", response.data);

          var data = response.data as List;
          customerLogs = data.map((doc) {
            return CustomerLogsResponse.fromMap(doc);
          }).toList();
        } else {
          showToast("Error: ${response.data['detail']}");
        }

      }
      else{
        final cacheData = await manager.get("GetDayWiseLogs");
        if (cacheData != null) {
          var cachedDataList = cacheData.value as List<dynamic>;
          customerLogs = cachedDataList
              .map((item) => CustomerLogsResponse.fromMap(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
