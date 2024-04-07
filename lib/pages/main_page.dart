import 'package:flutter/material.dart';
import 'package:water_managment_system/pages/expenses.dart';
import 'package:water_managment_system/pages/profile.dart';

import 'counter_sales.dart';
import 'customers.dart';
import 'deliveries.dart';

class MainPage extends StatefulWidget {
  final int initialTabIndex;

  const MainPage({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<MainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MainPage> {
  late int _selectedTab;

  List<Widget> _pages = [
    Center(
      child: Customers(),
    ),
    Center(
      child: Delieveries(),
    ),
    Center(
      child: CounterSales(),
    ),
    Center(
      child: Profile(),
    ),
    Center(
      child: ExpensePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Customers"),
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: "Deliveries"),
          BottomNavigationBarItem(icon: Icon(Icons.countertops_outlined), label: "Counter"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.add_card_sharp), label: "Expense"),
        ],
      ),
    );
  }
}
