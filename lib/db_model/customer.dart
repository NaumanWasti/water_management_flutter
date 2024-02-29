class Customer {
  int id;
  String name;
  int advanceMoney;
  String address;
  String phoneNumber;
  int bottles;
  int bottlePrice;
  int amountDue;
  int totalAmountPaid;
  List<int> weekDaysList;
  String email;

  Customer({
    required this.id,
    required this.name,
    required this.advanceMoney,
    required this.phoneNumber,
    required this.address,
    required this.bottles,
    required this.bottlePrice,
    required this.amountDue,
    required this.totalAmountPaid,
    required this.weekDaysList,
    required this.email,
  });

  factory Customer.fromMap(Map<String, dynamic> data) {
    return Customer(
      id: data['id'],
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      advanceMoney: data['advanceMoney'],
      address: data['address'],
      bottles: data['bottles'],
      bottlePrice: data['bottlePrice'],
      amountDue: data['amountDue'],
      totalAmountPaid: data['totalAmountPaid'],
      weekDaysList: List<int>.from(data['weekDaysList']),
      email: data['email'],
    );
  }
}
