import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_cache_manager/data_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_managment_system/db_model/upcoming_delivery.dart';

import '../db_model/complete_delivery_request.dart';
import '../db_model/constants.dart';
import '../db_model/customer.dart';
import '../helper/api_helper.dart';
import '../socket_service.dart';
import 'customer_details.dart';
import 'customer_logs.dart';

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
  int pageSize = 5;
  int page = 1;
  int pageSizeSearch = 5;
  int pageSearch = 1;
  int totalDelivery = 0;
  ApiHelper apiHelper = ApiHelper();
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
  final DataCacheManager manager = DefaultDataCacheManager.instance;

  @override
  void initState() {
    super.initState();
    //_initSocket();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    selectedDayIndex = now.weekday;
    GetUpcomingDelivery(selectedDayIndex);
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {
        _tabController.index == 0
            ? GetUpcomingDelivery(selectedDayIndex)
            : GetUpcomingDelivery(8);
      });
    }
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
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: delivery.length,
                                  itemBuilder: (context, index) {
                                    var deliveryCustomer = delivery[index];
                                    deliveryComplete =
                                        deliveryCustomer.completed;
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
                                              builder: (context) =>
                                                  CustomerLogs(
                                                customerId:
                                                    deliveryCustomer.customerId,
                                                customerName:
                                                    deliveryCustomer.name,
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
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            title: Text(
                                                "${deliveryCustomer.name}"),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        "Phone: ${deliveryCustomer.phone}"),
                                                    SizedBox(width: 5),
                                                    InkWell(
                                                      onTap: () {
                                                        _launchPhoneApp(
                                                            deliveryCustomer
                                                                .phone);
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
                                              ignoring: deliveryComplete ||
                                                  deliveryReject ||
                                                  DateTime.now().weekday !=
                                                      selectedDayIndex,
                                              child: IconButton(
                                                icon: Icon(
                                                  deliveryComplete
                                                      ? Icons.check_circle
                                                      : deliveryReject
                                                          ? Icons.cancel
                                                          : Icons.pending,
                                                  color: deliveryComplete
                                                      ? Colors.green
                                                      : deliveryReject
                                                          ? Colors.red
                                                          : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return completeDialog(
                                                          index);
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
                              totalDelivery > pageSize ?
                              buildPaginationNumbers(totalDelivery, pageSize) : Container(),
                              SizedBox(height: kBottomNavigationBarHeight + 50),
                            ],
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
    await launchUrl(phoneUri);
  }

  Widget _buildDeliveryTab() {
    return _buildDeliveryList(delivery);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
            child: Text(
          'Deliveries',
          style: TextStyle(
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
          _buildDeliveryTab(), // Upcoming Delivery
          _buildDeliveryTab(), // Urgent Delivery
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
      var params = {
        "search": search,
        "page": pageSearch,
        "pageSize": pageSizeSearch,
      };

      Response response = await apiHelper.fetchData(
        method: 'GET',
        endpoint: 'Customer/GetAllCustomer',
        params: params,
      );

      // Handle response
      if (response.statusCode == 200) {
        print(response);
        var data = response.data['customerDetail'] as List;
        if (mounted) {
          _setState(() {
            searchResults = data
                .map((customerData) => Customer.fromMap(customerData))
                .toList();
          });
        }
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {}
  }

  void addUrgentDelivery(int customerId) async {
    try {
      var params = {"customerId": customerId};
      Response response = await apiHelper.fetchData(
        method: 'POST',
        endpoint: 'Customer/AddUrgentDelivery',
        params: params,
      );
      // Handle response
      if (response.statusCode == 200) {
        showToast(" ${response.data['message']}");
      } else {
        print(response.data['detail'].toString());
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      print(e);
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
          _setState =
              setState; // Renamed _setState to _setStateCallback for clarity

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Search user'),
                  onChanged: (query) {
                    try {
                      onSearchTextChanged(query);
                    } catch (e) {
                      // Handle error
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please search user';
                    }
                    return null;
                  },
                ),
                if (searchResults != null) // Add null check for searchResults
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
                            selectedCustomerId = customer.id;
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  customer.name,
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  customer.address,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
                if (selectedCustomerId != 0) {
                  addUrgentDelivery(selectedCustomerId);
                } else {
                  showToast("please try again");
                }
                Navigator.pop(context); // Close the dialog
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
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    var params = {
      "weekDaysEnum": day,
      "page": page,
      "pageSize": pageSize,
    };

    if ((connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi))) {
      if (mounted) {
        try {
          setState(() {
            _loading = true;
          });

          Response response = await apiHelper.fetchData(
            method: 'GET',
            endpoint: 'Customer/GetCustomersByWeekDay',
            params: params,
          );
          // Handle response
          if (response.statusCode == 200) {
            await manager.add("GetCustomersByWeekDay${day}", response.data);
            totalDelivery = response.data['totalDelivery'];
            var data = response.data['customerByDeliveryDay'] as List;
            delivery = data.map((doc) {
              return UpcomingDelivery.fromMap(doc);
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
    } else {
      final cacheData = await manager.get("GetCustomersByWeekDay${day}");
      if(cacheData!=null) {
        var cachedDataMap = cacheData.value as Map<String, dynamic>;
        totalDelivery = cachedDataMap['totalDelivery'];
        var data = cachedDataMap['customerByDeliveryDay'] as List;
        delivery = data.map((doc) {
          return UpcomingDelivery.fromMap(doc);
        }).toList();
      }
      else{
        delivery.clear();
      }
    }
    setState(() {

    });
  }

  Widget buildPaginationNumbers(int totalCustomers, int pageSize) {
    print(totalCustomers);
    print(pageSize);
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
              GetUpcomingDelivery(selectedDayIndex);
            },
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
          );
        }).toList(),
      ),
    );
  }

  void CompleteDelivery(
      CompleteDeliveryRequest request, int selectedDayIndex) async {
    try {
      setState(() {
        _loading = true;
      });
      var body = {
        "CustomerDeliveryId": request.CustomerDeliveryId,
        "CustomerId": request.CustomerId,
        "WaterBottlesGiven": request.WaterBottlesGiven,
        "BottleBack": request.BottleBack,
        "AmountPaid": request.AmountPaid
      };

      Response response = await apiHelper.fetchData(
        method: 'POST',
        endpoint: 'Customer/CompleteDelivery',
        body: body,
      );

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
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void RejectDelivery(int deliveryId) async {
    try {
      setState(() {
        _loading = true;
      });
      var params = {"deliveryId": deliveryId};

      Response response = await apiHelper.fetchData(
          method: 'POST', endpoint: 'Customer/RejectDelivery', params: params);

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
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // void _initSocket() async {
  //   SocketService serviceWaitingListTournament = SocketService(
  //       hubName: 'customerList-hub',
  //       groupMethodController: "AddToGroup",
  //       groupBy: 2);
  //   var connectionWaitingListTournament =
  //       await serviceWaitingListTournament.initSocket();
  //   connectionGetDeviceInfo(
  //       connectionWaitingListTournament!);
  // }
  // void connectionGetDeviceInfo(HubConnection connection) {
  //   connection.on('GetCustomerListing', (message) {
  //     var response = message?[0];
  //     response = response['customerByDeliveryDay'];
  //     if (response is List<dynamic>) {
  //       // Ensure response is a List
  //       var list = response.map((doc) {
  //         return UpcomingDelivery.fromMap(Map<String, dynamic>.from(doc));
  //         // Convert each dynamic object to an UpcomingDelivery object
  //       }).toList();
  //       delivery.addAll(list);
  //     } else {
  //       // Handle unexpected data format
  //       print('Unexpected response format: $response');
  //     }
  //     setState(() {});
  //   });
  // }
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
