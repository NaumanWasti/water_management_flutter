import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_managment_system/db_model/customer.dart';
import 'package:water_managment_system/pages/main_page.dart';
import 'package:water_managment_system/pages/register_customer.dart';

import '../db_model/constants.dart';
import '../helper/api_helper.dart';

class CustomerDetails extends StatefulWidget {
  final Customer customer;
  const CustomerDetails({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  // Sample data, replace with your actual data
  double totalPayment = 500.0;
  double totalBalance = 200.0;
  bool isChecked = false;
Dio dio=Dio();
bool _loading=false;
  ApiHelper apiHelper = ApiHelper();

  // Sample data for days of the week
  List<bool> weekDays = [false, false, false, false, false, false, false,false];

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int day in widget.customer.weekDaysList) {
      weekDays[day - 1] = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
     appBar: PreferredSize(
       preferredSize: Size.fromHeight(height*0.04), // Set your custom height here
       child: AppBar(
         leading: IconButton(
           icon: Icon(Icons.arrow_back),
           onPressed: () {
             Navigator.of(context).pop();
           },
         ),
       ),
     ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display total payment and total balance
              buildPaymentCard(width),
              // Display customer details
              buildCustomerDetailsCard(width),
              buildWeekDays(width),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWeekDays(double width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildDayCheckBox("Monday", weekDays[0]),
                buildDayCheckBox("Tuesday", weekDays[1]),
                buildDayCheckBox("Wednesday", weekDays[2]),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildDayCheckBox("Thursday", weekDays[3]),
                buildDayCheckBox("Friday", weekDays[4]),
                buildDayCheckBox("Saturday", weekDays[5]),
              ],
            ),
            buildDayCheckBox("Sunday", weekDays[6]),
          ],
        ),
      ),
    );
  }

  Widget buildDayCheckBox(String day, bool isChecked) {
    int index = _getDayIndex(day);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            "$day",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          IgnorePointer(
            ignoring: true,
            child: Checkbox(
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  weekDays[index] = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  int _getDayIndex(String day) {
    switch (day) {
      case 'Monday':
        return 0;
      case 'Tuesday':
        return 1;
      case 'Wednesday':
        return 2;
      case 'Thursday':
        return 3;
      case 'Friday':
        return 4;
      case 'Saturday':
        return 5;
      case 'Sunday':
        return 6;
      default:
        return 0;
    }
  }

  Widget buildPaymentCard(double width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            buildCard('Total Amount Paid', widget.customer.totalAmountPaid.toString(), width),
            buildCard('Total Amount Due', widget.customer.amountDue.toString(), width),
          ],
        ),
      ),
    );
  }

  Widget buildCustomerDetailsCard(double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Delete'),
                              content: Text('Are you sure you want to delete this user?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    DeleteCustomerAsync(widget.customer.id);
                                  },
                                  child:_loading ? CircularProgressIndicator() : Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    Text(
                      'Customer Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: width*0.055),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterCustomer(forEdit: true, customer: widget.customer,)));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                buildRow('Name',widget.customer.name),
                widget.customer.email.isEmpty ? Container() : buildRow('Email', widget.customer.email),
                buildRow('Phone Number', widget.customer.phoneNumber.toString()),

                buildRow('Address', widget.customer.address.toString()),
                buildRow('Total Bottles Taken', widget.customer.bottles.toString()),
                buildRow('Total Advance', '${widget.customer.advanceMoney.toStringAsFixed(2)}'),
                buildRow('Bottle Price', '${widget.customer.bottlePrice.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _launchPhoneApp(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
      await launchUrl(phoneUri);
  }
  Widget buildCard(String title, String value, double width) {
    return SizedBox(
      width: width / 2 - 8,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              // if(title == "Total Amount Due")
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       value,
              //       style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
              //     ),
              //     IconButton(
              //       icon: Icon(Icons.done_all),
              //       onPressed: () {
              //         _launchPhoneApp(value);
              //       },
              //     ),
              //   ],
              // ),
              // if(title != "Total Amount Due")
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(String title, String value) {
    double width = MediaQuery.sizeOf(context).width;
    return Column(
      children: [
        Text(
          '$title',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: width*0.05),
        ),
        if (title == 'Phone Number') // Only add icon for phone number field
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: width*0.05),
              ),
              IconButton(
                icon: Icon(Icons.phone),
                onPressed: () {
                  _launchPhoneApp(value);
                },
              ),
            ],
          ),
        if (title != 'Phone Number') // Add phone number text without icon for other fields
          Text(
            value,
            style: TextStyle(fontSize: width*0.05),
          ),
        SizedBox(height: width*0.02),
      ],
    );
  }


  void DeleteCustomerAsync(int customerId) async {
    try {
      setState(() {
        _loading = true;
      });
      var params = {"customerId": customerId};
      Response response = await apiHelper.fetchData(
          method: 'POST',
          endpoint: 'Customer/DeleteCustomer',
          params: params
      );

      // Handle response
      if (response.statusCode == 200) {
        showToast(" ${response.data['message']}");
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));

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
  // Future<void> deleteUserData(String? documentId) async {
  //   try {
  //     String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('customers')
  //         .doc(documentId)
  //         .delete();
  //     print('User deleted successfully!');
  //     Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
  //
  //   } catch (e) {
  //     print('Error deleting user: $e');
  //   }
  // }



}
