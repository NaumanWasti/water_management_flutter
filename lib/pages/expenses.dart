import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_cache_manager/data_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_model/constants.dart';
import '../db_model/get_expense_response.dart';
import '../helper/api_helper.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late List<ExpenseModel> getExpenseResponse=[];
  bool _loading = false;
  ApiHelper apiHelper = ApiHelper();
  final DataCacheManager manager = DefaultDataCacheManager.instance;

  final TextEditingController searchController = TextEditingController();
  SortingOption _selectedSortingOption = SortingOption.none; // Track the selected sorting option
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchExpenses("",SortingOption.none);
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          actions: [
            PopupMenuButton<SortingOption>(
              onSelected: (SortingOption result) {
                setState(() {
                  _selectedSortingOption = result;
                  fetchExpenses("",result);
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<SortingOption>>[
                const PopupMenuItem<SortingOption>(
                  value: SortingOption.asc,
                  child: Text('Sort Ascending'),
                ),
                const PopupMenuItem<SortingOption>(
                  value: SortingOption.desc,
                  child: Text('Sort Descending'),
                ),
                const PopupMenuItem<SortingOption>(
                  value: SortingOption.none,
                  child: Text('No Sort'),
                ),
              ],
            ),
          ],
          title: Center(child: Text('Shop Expenses',style: TextStyle(
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
                decoration: InputDecoration(hintText: 'Search expense',contentPadding: EdgeInsets.all(10)),
                onChanged: (query) {
                  setState(() {
                    fetchExpenses(query,SortingOption.none);
                  }); // Update the dialog content
                },
              ),
              getExpenseResponse.isNotEmpty ?
              Container(
                height: height * 0.8,
                width: width,
                child:Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: getExpenseResponse.length,
                        itemBuilder: (context, index) {
                          ExpenseModel expense = getExpenseResponse[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: ListTile(
                                onTap: () {
                                  _showFullDescription(expense);
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  _truncate(expense.ExpenseTitle),
                                  style: TextStyle(overflow: TextOverflow.ellipsis),
                                ),
                                subtitle: Text(
                                  "Amount: ${expense.ExpenseAmount}",
                                  style: TextStyle(overflow: TextOverflow.ellipsis),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return addExpenseDialog(true,expense);
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(expense.Id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: kBottomNavigationBarHeight),
                  ],
                ),
              ) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text("No resgitered expense found"),),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return addExpenseDialog(false);
            },
          );
          // showModalBottomSheet(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         ListTile(
          //           leading: Icon(Icons.person_add),
          //           title: Text('Add Expense'),
          //           onTap: () {
          //             showDialog(
          //               context: context,
          //               builder: (BuildContext context) {
          //                 return addExpenseDialog(false);
          //               },
          //             );
          //           },
          //         ),
          //         // ListTile(
          //         //   leading: Icon(Icons.add_a_photo),
          //         //   title: Text('Some Other Action'),
          //         //   onTap: () {
          //         //     Navigator.pop(context);
          //         //     // Add some other action functionality here
          //         //   },
          //         // ),
          //       ],
          //     );
          //   },
          // );
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  // Method to show delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(int expenseId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this expense?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call delete method here
                deleteExpense(expenseId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }
  void _showFullDescription(ExpenseModel expense) {
    var date = DateTime.parse(expense.ExpenseDate);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(expense.ExpenseTitle),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //Text("Description: ${expense.ExpenseDescription}"),
              Text( "Amount: ${expense.ExpenseAmount}"),
              Text("Date: ${formatDateTime(date.toString())}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


  String _truncate(String text) {
    if (text.length > 20) {
      return text.substring(0, 20) + '...';
    }
    return text;
  }

  Widget addExpenseDialog(bool update,[ExpenseModel? model]) {
    TextEditingController titleController = new TextEditingController();
    TextEditingController descController = new TextEditingController();
    TextEditingController amountController = new TextEditingController();
    if (update && model != null) {
      titleController.text = model.ExpenseTitle;
     // descController.text = model.ExpenseDescription;
      amountController.text = model.ExpenseAmount.toString();
    }
    return AlertDialog(
      title: Text('Add expense'),
      content: SizedBox(
        width: double.maxFinite,
        // Set the width to fill the available space
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                maxLength: 50,
                controller: titleController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Enter Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              // TextFormField(
              //   controller: descController,
              //   keyboardType: TextInputType.text,
              //   decoration: InputDecoration(labelText: 'Enter Description'),
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return 'Please Enter Description';
              //     }
              //     return null;
              //   },
              // ),
              TextFormField(
                maxLength: 5,
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter Amount'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Enter Amount';
                  }
                  return null;
                },
                  onChanged: (value) {
                    if (!validateNumeric(value)) {
                      // Clear the field if it contains non-numeric characters
                      amountController.clear();
                    }
                    // Handle changes to the bottle rate here if needed
                  },
              ),
            ],
          ),
        ),
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
                if(titleController.text.isNotEmpty && amountController.text.isNotEmpty){
                  ExpenseModel expense = new ExpenseModel(
                    ExpenseTitle: titleController.text,
                    //ExpenseDescription: descController.text,
                    ExpenseAmount: int.parse(amountController.text),
                    Id: update && model != null ? model.Id : 0,
                  );
                  addExpense(expense);
                }
              },
              child: Text(update ? 'Update' : 'Add'),
            ),
          ],
        ),
      ],
    );
  }
  bool validateNumeric(String value) {
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(value);
  }
  void fetchExpenses(String search,SortingOption sortingOption) async {
    try {
      final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());
      if (!mounted) return;

      var params = {
        "search": search,
        "sortAscending": sortingOption == SortingOption.asc ? true : false,
        "sortDescending": sortingOption == SortingOption.desc ? true : false,
      };

      if ((connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi))) {
        Response response = await apiHelper.fetchData(
            method: 'GET',
            endpoint: 'Customer/GetExpense',
            params: params
        );
        // Handle response
        if (response.statusCode == 200) {
          await manager.add("GetExpense", response.data);

          var data  = response.data as List;
          getExpenseResponse = data
              .map((customerData) => ExpenseModel.fromMap(customerData))
              .toList();
        } else {
          showToast("Error: ${response.data['detail']}");
        }
      }
      else{
        final cacheData = await manager.get("GetExpense");
        if(cacheData!=null) {
          var data  = cacheData.value as List;
          getExpenseResponse = data
              .map((customerData) => ExpenseModel.fromMap(customerData))
              .toList();
        }
      }

    }
    catch (e){
      print(e);
    }
    finally{
      setState(() {

      });
    }

  }
void addExpense(ExpenseModel request) async {
    try {
      setState(() {
        _loading=true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $token',
      };
      var body = {
        "Id": request.Id,
        "ExpenseTitle" : request.ExpenseTitle,
        //"ExpenseDescription":request.ExpenseDescription,
        "ExpenseAmount":request.ExpenseAmount
      };
      Response response = await apiHelper.fetchData(
          method: 'POST',
          endpoint: 'Customer/AddExpense',
          body: body
      );

      // Handle response
      if (response.statusCode == 200) {
        showToast(" ${response.data['message']}");
        Navigator.pop(context);
        fetchExpenses("",SortingOption.none);
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {

      print(e);
    }
    finally{
      setState(() {
        _loading=false;
      });
    }
  }

  void deleteExpense(int expenseId) async {
    try {
      setState(() {
        _loading=true;
      });
      var params = {
        "Id": expenseId,
      };
      Response response = await apiHelper.fetchData(
          method: 'POST',
          endpoint: 'Customer/DeleteExpense',
          params: params
      );

      // Handle response
      if (response.statusCode == 200) {
        showToast(" ${response.data['message']}");
        fetchExpenses("",SortingOption.none);
      } else {
        showToast("Error: ${response.data['detail']}");
      }
    } catch (e) {

      print(e);
    }
    finally{
      setState(() {
        _loading=false;
      });
    }
  }


}
enum SortingOption {
  asc,
  desc,
  none,
}