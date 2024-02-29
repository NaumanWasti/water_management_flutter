import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_managment_system/db_model/upcoming_delivery.dart';
import 'package:flutter/services.dart' show canLaunch, launch;

import '../db_model/complete_delivery_request.dart';
import '../db_model/constants.dart';
import '../db_model/customer.dart';
import 'customer_details.dart';
import 'logs.dart';

class Delieveries extends StatefulWidget {
  const Delieveries({Key? key}) : super(key: key);

  @override
  State<Delieveries> createState() => _DelieveriesState();
}

class _DelieveriesState extends State<Delieveries>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime now = DateTime.now();
  bool deliveryComplete = false;
  bool deliveryReject = false;
  Dio dio = Dio();
  late List<UpcomingDelivery> delivery = [];
  String selectedDay = 'Monday'; // Default selected day
  int selectedDayIndex = 1; // Default selected day
  List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  late StateSetter _setState;
  final TextEditingController waterBottlesController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController bottlesBackController = TextEditingController();
  final TextEditingController amountPaidController = TextEditingController();
  bool _loading = false;
  List<Customer> searchResults = [];
  int selectedCustomerId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    selectedDayIndex = now.weekday;
    GetUpcomingDelivery(selectedDayIndex);
  }

  void _handleTabSelection() {
    setState(() {
      _tabController.index == 0
          ? GetUpcomingDelivery(selectedDayIndex)
          : GetUpcomingDelivery(8);
    });
  }

  Widget _buildDeliveryList(List<UpcomingDelivery> delivery) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _loading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tabController.index == 0
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.topRight,
                          child: DropdownButton<String>(
                            value: getDayByIndex(selectedDayIndex),
                            items: weekdays
                                .map((day) => DropdownMenuItem<String>(
                                      value: day,
                                      child: Text(day),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedDayIndex = _getDayIndex(value!);
                                GetUpcomingDelivery(selectedDayIndex);
                              });
                            },
                          ),
                        )
                      : Container(),
                  delivery.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(_tabController.index == 0
                                ? 'No upcoming deliveries found'
                                : 'No urgent deliveries found'),
                          ),
                        )
                      : Container(
                          height: height * 0.8,
                          width: width,
                          child: ListView.builder(
                            itemCount: delivery.length,
                            itemBuilder: (context, index) {
                              var deliveryCustomer = delivery[index];
                              deliveryComplete = deliveryCustomer.completed;
                              deliveryReject = deliveryCustomer.rejected;
                              print(deliveryReject);
                              print("deliveryReject");
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CustomerLogs(
                                          customerId:
                                              deliveryCustomer.customerId,
                                          customerName: deliveryCustomer.name,
                                        ),
                                      ),
                                    ),
                                  },
                                  child: Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text("${deliveryCustomer.name}"),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Phone: ${deliveryCustomer.phone}"),
                                              SizedBox(width: 5),
                                              InkWell(
                                                onTap: () {
                                                  _launchPhoneApp(deliveryCustomer.phone);
                                                },
                                                child: Icon(Icons.phone),
                                              ),
                                            ],
                                          ),
                                          Text(
                                              "Number of Bottles: ${deliveryCustomer.customerBottles}"),
                                          Text(
                                              "Address: ${deliveryCustomer.address}"),
                                        ],
                                      ),
                                      trailing: IgnorePointer(
                                        ignoring: deliveryComplete || deliveryReject ||
                                            DateTime.now().weekday !=
                                                selectedDayIndex,
                                        child: IconButton(
                                          icon: Icon(
                                            deliveryComplete
                                                ? Icons.check_circle : deliveryReject ? Icons.cancel
                                                : Icons.pending,
                                            color: deliveryComplete
                                                ? Colors.green : deliveryReject ? Colors.red
                                                : Colors.grey,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return completeDialog(index);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          );
  }
  void _launchPhoneApp(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  Widget _buildDeliveryTab(bool isUpcoming) {
    //isUpcoming ? GetUpcomingDelivery(selectedDayIndex)  :  GetUpcomingDelivery(8);
    return _buildDeliveryList(delivery);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Deliveries',style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.07),
        )),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming Delivery'),
            Tab(text: 'Urgent Delivery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeliveryTab(true), // Upcoming Delivery
          _buildDeliveryTab(false), // Urgent Delivery
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('Add urgent Delivery'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return urgentDeliveryDialog();
                        },
                      );
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.add_a_photo),
                  //   title: Text('Some Other Action'),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     // Add some other action functionality here
                  //   },
                  // ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget completeDialog(int index) {
    return AlertDialog(
      title: Text('Enter Delivery Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: waterBottlesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Water Bottles Given'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the number of water bottles given';
              }
              return null;
            },
          ),
          TextFormField(
            controller: bottlesBackController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Water Bottles taken Back'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the number of water bottles taken back';
              }
              return null;
            },
          ),
          TextFormField(
            controller: amountPaidController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount Paid by customer'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the amount paid by the customer';
              }
              return null;
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            RejectDelivery(delivery[index].deliveryId);
            Navigator.pop(context);
          },
          child: Text('Reject'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_validateFields()) {
              CompleteDeliveryRequest request = CompleteDeliveryRequest(
                CustomerDeliveryId: delivery[index].deliveryId,
                CustomerId: delivery[index].customerId,
                WaterBottlesGiven: int.parse(waterBottlesController.text),
                BottleBack: int.parse(bottlesBackController.text),
                AmountPaid: int.parse(amountPaidController.text),
              );
              CompleteDelivery(request, selectedDayIndex);
              Navigator.pop(context);
            }
          },
          child: Text('Complete'),
        ),

      ],
    );
  }

  void fetchCustomerData(String search) async {
    searchResults.clear();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      var params = {"search": search};
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      Response response = await dio.get('$base_url/Customer/GetAllCustomer',
          queryParameters: params, options: Options(headers: headers));

      // Handle response
      if (response.statusCode == 200) {
        var data = response.data['customerDetail'] as List;

        _setState(() {
          searchResults = data
              .map((customerData) => Customer.fromMap(customerData))
              .toList();
        });
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
    }
  }

  void addUrgentDelivery(int customerId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      var params = {"customerId": customerId};
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      Response response = await dio.post('$base_url/Customer/AddUrgentDelivery',
          queryParameters: params, options: Options(headers: headers));

      // Handle response
      if (response.statusCode == 200) {
        showToast(" ${response.data['message']}");
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
    }
  }

  void onSearchTextChanged(String query) {
    fetchCustomerData(query);
  }

  Widget urgentDeliveryDialog() {
    return AlertDialog(
      title: Text('Urgent Delivery'),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        _setState = setState;

        return SizedBox(
          width: double.maxFinite,
          // Set the width to fill the available space
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Search user'),
                  onChanged: (query) {
                    onSearchTextChanged(query);
                    setState(() {}); // Update the dialog content
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please search user';
                    }
                    return null;
                  },
                ),
                Container(
                  height: 150,
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      var customer = searchResults[index];
                      return InkWell(
                        onTap: () {
                          searchController.text = customer.name;
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Container(
                          height: 150,
                          width: double.maxFinite,
                          child: ListView.separated(
                            itemCount: searchResults.length,
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(),
                            // Add Divider between items
                            itemBuilder: (context, index) {
                              var customer = searchResults[index];
                              return InkWell(
                                onTap: () {
                                  searchController.text = customer.name;
                                  selectedCustomerId = customer.id;
                                  // Navigator.pop(context); // Close the dialog
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        customer.phoneNumber,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel button
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                addUrgentDelivery(selectedCustomerId);
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ],
        ),
      ],
    );
  }

  bool _validateFields() {
    if (waterBottlesController.text.isEmpty ||
        bottlesBackController.text.isEmpty ||
        amountPaidController.text.isEmpty) {
      showToast('Please fill all fields');
      return false;
    }
    return true;
  }

  int _getDayIndex(String day) {
    switch (day) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        return 0;
    }
  }

  String getDayByIndex(int index) {
    switch (index) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  void GetUpcomingDelivery(int day) async {
    try {
      setState(() {
        _loading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      var params = {"weekDaysEnum": day};
      Response response = await dio.get(
          '$base_url/Customer/GetCustomersByWeekDay',
          queryParameters: params,
          options: Options(headers: headers));

      // Handle response
      if (response.statusCode == 200) {
        var data = response.data as List;
        delivery = data.map((doc) {
          return UpcomingDelivery.fromMap(doc);
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

  void CompleteDelivery(
      CompleteDeliveryRequest request, int selectedDayIndex) async {
    try {
      setState(() {
        _loading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      var body = {
        "CustomerDeliveryId": request.CustomerDeliveryId,
        "CustomerId": request.CustomerId,
        "WaterBottlesGiven": request.WaterBottlesGiven,
        "BottleBack": request.BottleBack,
        "AmountPaid": request.AmountPaid
      };
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      Response response = await dio.post('$base_url/Customer/CompleteDelivery',
          data: body, options: Options(headers: headers));
      // Handle response
      if (response.statusCode == 200) {
        _tabController.index == 0
            ? GetUpcomingDelivery(selectedDayIndex)
            : GetUpcomingDelivery(8);
        showToast(" ${response.data['message']}");
      } else {
        showToast("Error: ${response.data['detail']}");
        print("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void RejectDelivery(
      int deliveryId) async {
    try {
      setState(() {
        _loading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      var params = {
        "deliveryId": deliveryId
      };
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      Response response = await dio.put('$base_url/Customer/RejectDelivery',
          queryParameters: params, options: Options(headers: headers));
      // Handle response
      if (response.statusCode == 200) {
        _tabController.index == 0
            ? GetUpcomingDelivery(selectedDayIndex)
            : GetUpcomingDelivery(8);
        showToast(" ${response.data['message']}");
      } else {
        showToast("Error: ${response.data['detail']}");
        print("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

}

// Future<List<Customer>> _getCustomers() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String>? customersJsonList = prefs.getStringList('customers');
//   if (customersJsonList == null) {
//     return [];
//   }
//   // Convert JSON strings back to Customer objects
//   List<Customer> customers = customersJsonList.map((jsonString) {
//     Map<String, dynamic> jsonMap = json.decode(jsonString);
//     String documentId = jsonMap['documentId']; // Adjust this line based on your JSON structure
//     return Customer.fromMap(jsonMap, documentId);
//   }).toList();
//
//   // Return the list of customers
//   return customers;
// }
// Future<void> fetchCustomerData() async {
//   try {
//     _loading = true;
//     customersModified.clear();
//     String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
//
//     var deliverySnapshot = await FirebaseFirestore.instance
//         .collection('upcomingDeliveries')
//         .doc(userId)
//         .collection(selectedDay)
//         .get();
//
//     delivery = deliverySnapshot.docs.map((doc) {
//       return UpcomingDelivery.fromMap(doc.data(), doc.id);
//     }).toList();
//
//     // Fetch customer data
//     var storedCustomer = await _getCustomers();
//     if(storedCustomer.isEmpty){
//
//       var userSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('customers')
//           .get();
//
//       customers = userSnapshot.docs.map((doc) {
//         return Customer.fromMap(doc.data(), doc.id);
//       }).toList();
//     }
//     else{
//       customers = storedCustomer;
//     }
//
//     // Match deliveries with customers
//     for (int i = 0; i < customers.length; i++) {
//       for (UpcomingDelivery delivery in delivery) {
//         if (customers[i].documentId == delivery.userId) {
//           customersModified.add(customers[i]);
//         }
//       }
//     }
//
//     setState(() {
//       _loading = false; // Stop loading when data is fetched
//     });
//   } catch (e) {
//     print('Error fetching data: $e');
//     // Handle the error, show a message, or log it for debugging.
//     setState(() {
//       _loading = false; // Stop loading on error
//     });
//   }
// }
