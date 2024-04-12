import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_managment_system/db_model/customer.dart';
import 'package:water_managment_system/pages/main_page.dart';

import '../db_model/constants.dart';
import '../helper/api_helper.dart';
import 'customers.dart';

class RegisterCustomer extends StatefulWidget {
  final bool forEdit;
  final Customer? customer;
  const RegisterCustomer({Key? key, required this.forEdit, this.customer=null}) : super(key: key);

  @override
  State<RegisterCustomer> createState() => _RegisterCustomerState();
}

class _RegisterCustomerState extends State<RegisterCustomer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController userNameController;
  late TextEditingController bottlePriceController;
  late TextEditingController userAddressController;
  late TextEditingController userNumberController;
  late TextEditingController bottlesTakenController;
  late TextEditingController totalAdvanceController;
  late TextEditingController emailAddressController;
  List<bool?> weekDays = [false, false, false, false, false, false, false,false];
  List<int> selectedWeekDays = [];
  ApiHelper apiHelper = ApiHelper();

bool _loading=false;
  @override
  void initState() {
    super.initState();
    if(widget.forEdit){
      for (int day in widget.customer!.weekDaysList) {
        weekDays[day - 1] = true;
      }
    }

    userNameController = TextEditingController(text: widget.forEdit ? widget.customer!.name : "");
    userAddressController = TextEditingController(text: widget.forEdit ? widget.customer!.address : "");
    userNumberController = TextEditingController(text: widget.forEdit ? widget.customer!.phoneNumber.toString() : "");
    bottlesTakenController = TextEditingController(text: widget.forEdit ? widget.customer!.bottles.toString() : "");
    totalAdvanceController = TextEditingController(text: widget.forEdit ? widget.customer!.advanceMoney.toString() : "");
    bottlePriceController = TextEditingController(text: widget.forEdit ? widget.customer!.bottlePrice.toString() : "");
    emailAddressController = TextEditingController(text: widget.forEdit ? widget.customer!.email : "");
  }
  @override
  void dispose() {
    userNameController.dispose();
    userAddressController.dispose();
    userNumberController.dispose();
    bottlesTakenController.dispose();
    totalAdvanceController.dispose();
    emailAddressController.dispose();
    bottlePriceController.dispose();
    super.dispose();
  }
  bool validateNumeric(String value) {
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(value);
  }
  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => MainPage(initialTabIndex: 0,)), // Replace CalendarWidget with your actual calendar widget
        // );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 30,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: userNameController,
                      decoration: InputDecoration(labelText: 'User Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'User name is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: userAddressController,
                      decoration: InputDecoration(labelText: 'User Address'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'User address is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: userNumberController,
                      decoration: InputDecoration(labelText: 'User Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'User number is required';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    // TextFormField(
                    //   controller: bottlesTakenController,
                    //   decoration: InputDecoration(labelText: 'Number of Bottles Taken'),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Number of bottles taken is required';
                    //     }
                    //     return null;
                    //   },
                    //   keyboardType: TextInputType.number,
                    // ),
                    TextFormField(
                      controller: totalAdvanceController,
                      decoration: InputDecoration(labelText: 'Total Advance'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Total advance is required';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (!validateNumeric(value)) {
                          // Clear the field if it contains non-numeric characters
                          totalAdvanceController.clear();
                        }
                        // Handle changes to the bottle rate here if needed
                      },
                    ),
                    TextFormField(
                      controller: bottlePriceController,
                      decoration: InputDecoration(labelText: 'Bottle Price'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bottle Price is required';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (!validateNumeric(value)) {
                          // Clear the field if it contains non-numeric characters
                          bottlePriceController.clear();
                        }
                        // Handle changes to the bottle rate here if needed
                      },
                    ),

                    TextFormField(
                      controller: emailAddressController,
                      decoration: InputDecoration(labelText: 'Email Address (Optional)'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    buildWeekDays(width),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async{
                        if (_formKey.currentState!.validate()) {
                          selectedWeekDays.clear();
                          for (int i = 0; i < weekDays.length; i++) {
                            if (weekDays[i] ?? false) {
                              selectedWeekDays.add(i + 1);
                            }
                          }
                          Customer Newcustomer = Customer(
                            weekDaysList:selectedWeekDays,
                            amountDue: widget.forEdit ? widget.customer!.amountDue  : 0,
                            totalAmountPaid: widget.forEdit ? widget.customer!.totalAmountPaid  : 0,
                            name: userNameController.text,
                            address: userAddressController.text,
                            phoneNumber: userNumberController.text,
                            bottles: 0  ,
                            advanceMoney: int.parse(totalAdvanceController.text),
                            email: emailAddressController.text,
                            id:widget.forEdit ? widget.customer!.id : 0,
                            bottlePrice: int.parse(bottlePriceController.text),
                          );
                          CreateCustomerAsync(Newcustomer);

                        }
                      },
                      child:_loading ? CircularProgressIndicator() : Text( widget.forEdit ? 'Edit' : 'Submit'),
                    ),
                  ],
                ),
              ),
            ),
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
                buildDayCheckBox("Monday", weekDays[0] ?? false),
                buildDayCheckBox("Tuesday", weekDays[1] ?? false),
                buildDayCheckBox("Wednesday", weekDays[2] ?? false),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildDayCheckBox("Thursday", weekDays[3] ?? false),
                buildDayCheckBox("Friday", weekDays[4] ?? false),
                buildDayCheckBox("Saturday", weekDays[5] ?? false),
              ],
            ),
            buildDayCheckBox("Sunday", weekDays[6] ?? false),
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
          Checkbox(
            value: isChecked,
            onChanged: (value) {
              setState(() {
                weekDays[index] = value!;
              });
            },
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
  void CreateCustomerAsync(Customer customer) async {
    try {
      setState(() {
        _loading = true;
      });

      var body = {
        "WeekDaysList":customer.weekDaysList,
        "CustomerId":customer.id,
        //"Bottles":customer.bottles,
        "BottlePrice":customer.bottlePrice,
        "AdvanceMoney":customer.advanceMoney,
        "Name":customer.name,
        "PhoneNumber":customer.phoneNumber,
        "Address":customer.address,
        "Email":customer.email
      };
      Response response = await apiHelper.fetchData(
          method: 'POST',
          endpoint: 'Customer/CreateCustomer',
          body : body
      );

      // Handle response
      if (response.statusCode == 200) {
          showToast(" ${response.data['message']}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(),
          ),
        );
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


// String getDayByIndex(int index) {
  //   switch (index) {
  //     case 0:
  //       return 'Monday';
  //     case 1:
  //       return 'Tuesday';
  //     case 2:
  //       return 'Wednesday';
  //     case 3:
  //       return 'Thursday';
  //     case 4:
  //       return 'Friday';
  //     case 5:
  //       return 'Saturday';
  //     case 6:
  //       return 'Sunday';
  //     default:
  //       return '';
  //   }
  // }
  // Future<void> saveUserData(String userId, Customer user) async {
  //   try {
  //     var users = await FirebaseFirestore.instance.collection('users').doc(userId).collection('customers').add(user.toMap());
  //     print('User registered successfully!');
  //     // Define a collection reference for upcoming deliveries
  //     CollectionReference upcomingDeliveriesCollection =
  //     FirebaseFirestore.instance.collection('upcomingDeliveries');
  //     DocumentReference userUpcomingDeliveries = upcomingDeliveriesCollection.doc(userId);
  //     for (int i=0;i<weekDays.length;i++){
  //       if(weekDays[i]==true){
  //         var day = getDayByIndex(i);
  //         CollectionReference dayCollection = userUpcomingDeliveries.collection(day);
  //         await dayCollection.add({
  //           'userId': users.id,
  //           'declined': false,
  //           'completed': false,
  //           'price': 20,  // Set the initial price or any other relevant data
  //         });
  //       }
  //     }
  //
  //
  //   } catch (e) {
  //     print('Error registering user: $e');
  //   }
  // }
  //
  // Future<void> editUserData(String userId, String? documentId, Customer updatedUser) async {
  //   try {
  //     await FirebaseFirestore.instance.collection('users').doc(userId).collection('customers').doc(documentId).set(updatedUser.toMap());
  //     print('User edited successfully!');
  //   } catch (e) {
  //     print('Error editing user: $e');
  //   }
  // }

}
