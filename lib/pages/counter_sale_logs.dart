import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_cache_manager/data_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_managment_system/helper/api_helper.dart';

import '../db_model/constants.dart';
import '../db_model/counter_sale_logs.dart';

class CounterSaleLogs extends StatefulWidget {
  // final List<CounterSaleLogsModel> counterSaleLogsModel;
  final bool dayWiseLogs;
  final DateTime dateTime;
  const CounterSaleLogs({super.key, required this.dayWiseLogs, required this.dateTime});

  @override
  State<CounterSaleLogs> createState() => _CounterSaleLogsState();
}

class _CounterSaleLogsState extends State<CounterSaleLogs> {
  bool _loading = false;
  int pageSize = 10;
  int counterSaleCount = 0;
  int page = 1;
  late List<CounterSaleLogsModel> counterSalesList = [];
ApiHelper apiHelper = new ApiHelper();
  final DataCacheManager manager = DefaultDataCacheManager.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetCounterSales(widget.dateTime);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter Sales'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          
          child: Column(
            
            children: [
              
              DataTable(
                
                columnSpacing: 120,
                columns: [
                  DataColumn(label: Text('Water Rate')),
                  DataColumn(label: Text('Sale Date Time')),
                ],
                rows: counterSalesList.map((log) {
                  print(log.saleDateTime);
                  var saleDateTime = DateTime.parse(log.saleDateTime);
                  return DataRow(
                    cells: [
                      DataCell(Text(log.bottleRate.toString())),
                      DataCell(Text(formatDateTime(saleDateTime.toString()))),
                    ],
                  );
                }).toList(),
              ),
              buildPaginationNumbers(counterSaleCount, pageSize),
            ],
          ),

        ),
      ),
    );
  }
  void GetCounterSales(DateTime dateTime) async {
    final List<ConnectivityResult> connectivityResult =
    await (Connectivity().checkConnectivity());
    try {
      if (!mounted) return;

      if ((connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi))){
        setState(() {
          _loading = true;
        });

        var params = {
          "dayWiseLogs":widget.dayWiseLogs,
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

  Widget buildPaginationNumbers(int totalCustomers, int pageSize) {
    int totalPages = (totalCustomers / pageSize).ceil();
    List<int> pages = List.generate(totalPages, (index) => index + 1);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pages.map((pageNumber) {
          return GestureDetector(
            onTap: () {
              page = pageNumber;
              GetCounterSales(widget.dateTime);
            },
            child: Visibility(
              visible: totalPages>1,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: page == pageNumber ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$pageNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }
}
