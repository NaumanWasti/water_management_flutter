import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_managment_system/pages/customer_details.dart';
import 'package:water_managment_system/pages/register_customer.dart';

import '../db_model/constants.dart';
import '../db_model/customer.dart';
import '../helper/api_helper.dart';
import 'customer_logs.dart';
class Customers extends StatefulWidget {
  const Customers();

  @override
  State<Customers> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<Customers> {
  late List<Customer> customers = []; // Provide an initial empty list
  bool _loading = false; // Track whether data is being loaded
  Dio dio = Dio();
  int pageSize = 5;
  int page = 1;
  int totalCustomers = 0;
  ApiHelper apiHelper = ApiHelper();

  final TextEditingController searchController = TextEditingController();
  //final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCustomerData("");
    //_scrollController.addListener(_scrollListener);
  }
  // void _scrollListener() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     page++; // Increment page number when scrolled to the bottom
  //     fetchCustomerData(searchController.text, page, pageSize);
  //   }
  // }

  void fetchCustomerData(String search) async {
    try {
      var params = {
        "search": search,
        "page": page,
        "pageSize": pageSize,
      };
      Response response = await apiHelper.fetchData(
        method: 'GET',
        endpoint: 'Customer/GetAllCustomer',
        params: params,
      );
      // Handle response
      if (response.statusCode == 200) {
        if(mounted){
          totalCustomers = response.data['totalCustomer'];
          var data = response.data['customerDetail'] as List;
          customers = data
              .map((customerData) => Customer.fromMap(customerData))
              .toList();
          setState(() {
          });
        }

      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {
      showToast("Error fetching data: $e");
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
              fetchCustomerData(searchController.text);
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, // Disable the back button
          title: Center(child: Text('Registered Customers',style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.07),
        )
      )),
      body: _loading
          ? Center(child: CircularProgressIndicator()) // Show loader if loading
          : SingleChildScrollView(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: searchController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(hintText: 'Search customer',contentPadding: EdgeInsets.all(10)),
                    onChanged: (query) {
                      page = 1;
                      fetchCustomerData(query);
                    },

                  ),
                  customers.length!=0 ?
                  Container(
                    height: height * 0.8,
                    width: width,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            //controller: _scrollController,
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              Customer customer = customers[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: ListTile(
                                    leading: InkWell(
                                      onTap: ()=>{
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CustomerLogs(
                                              customerId:
                                            customer.id,
                                              customerName: customer.name,
                                            ),
                                          ),
                                        ),
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    title: Text("${customer.name}",
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Phone: ${customer.phoneNumber}",
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis)),
                                        Text("Address: ${customer.address}",
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        // Navigate to view customer details page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerDetails(customer: customer),
                                          ),
                                        );
                                      },
                                      child: Text('View Details'),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        buildPaginationNumbers(totalCustomers, pageSize),
                        const SizedBox(height: kBottomNavigationBarHeight-5),
                      ],
                    ),
                  ) : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("No resgitered customer found"),),
                  ),
                ],
              ),
            ),
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
                    leading: Icon(Icons.person_add),
                    title: Text('Register Customer'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterCustomer(forEdit: false,),
                        ),
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

// Future<void> fetchCustomerData() async {
//   QuerySnapshot<Map<String, dynamic>> snapshot;
//   try {
//     String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
//     var storedCustomer = await _getCustomers();
//     if(storedCustomer.isEmpty){
//       snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('customers')
//           .get();
//       customers = snapshot.docs.map((doc) {
//         return Customer.fromMap(doc.data(), doc.id);
//       }).toList();
//       await _storeCustomers(customers);
//     }
//     else{
//       customers = storedCustomer;
//     }
//     setState(() {
//       _loading = false; // Stop loading when data is fetched
//     });
//   } catch (e) {
//     print('Error fetching customer data: $e');
//     setState(() {
//       _loading = false; // Stop loading on error
//     });
//   }
// }


// Future<void> _storeCustomers(List<Customer> customers) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String> customersJsonList = customers.map((customer) => json.encode(customer.toMap())).toList();
//   await prefs.setStringList('customers', customersJsonList);
// }
//
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

}

