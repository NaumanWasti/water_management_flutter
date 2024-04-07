import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:water_managment_system/pages/analytics.dart';

class CalenderWidget extends StatefulWidget {
  const CalenderWidget({Key? key}) : super(key: key);

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    var today = DateTime.now();
    _focusedDay = today;
    _selectedDay = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Analytics(month: _focusedDay.month, day: _focusedDay.day, year: _focusedDay.year,)), // Replace CalendarWidget with your actual calendar widget
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Analytics'),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                currentDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: _onDaySelected,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Analytics(month: _focusedDay.month, day: _focusedDay.day, year: _focusedDay.year,)), // Replace CalendarWidget with your actual calendar widget
                  );
                  },
                child: Text('Check Analytics'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
