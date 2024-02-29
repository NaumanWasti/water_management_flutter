import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db_model/counter_sale_logs.dart';

class CounterSaleLogs extends StatefulWidget {
  final List<CounterSaleLogsModel> counterSaleLogsModel;
  const CounterSaleLogs({super.key,required this.counterSaleLogsModel});

  @override
  State<CounterSaleLogs> createState() => _CounterSaleLogsState();
}

class _CounterSaleLogsState extends State<CounterSaleLogs> {
  bool _loading = false;
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
          child: DataTable(
            columns: [
              DataColumn(label: Text('Water Rate')),
              DataColumn(label: Text('Sale Date Time')),
            ],
            rows: widget.counterSaleLogsModel.map((log) {
              return DataRow(
                cells: [
                  DataCell(Text(log.bottleRate.toString())),
                  DataCell(Text(formatDateTime(log.saleDateTime))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  String formatDateTime(String dateTimeString) {
    // Define the format string that matches the format of dateTimeString
    String format = 'M/d/yyyy h:mm:ss a';

    // Parse the string into a DateTime object using the custom format
    DateTime dateTime = DateFormat(format).parse(dateTimeString);

    // Adjust the time to your local time zone (+5 GMT)
    dateTime = dateTime.add(Duration(hours: 5));

    // Format the adjusted DateTime into a simpler format
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }}
