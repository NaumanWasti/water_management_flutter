class UpcomingDelivery {
  int deliveryId;
  int customerId;
  String name;
  String phone;
  String address;
  int waterPerDelivery;
  int customerBottles;
  bool completed;
  bool rejected;

  UpcomingDelivery({
    required this.deliveryId,
    required this.completed,
    required this.rejected,
    required this.customerId,
    required this.name,
    required this.phone,
    required this.address,
    required this.waterPerDelivery,
    required this.customerBottles,
  });

  Map<String, dynamic> toMap() {
    return {
      'deliveryId': deliveryId,
      'completed': completed,
      'rejected': rejected,
      'customerId': customerId,
      'name': name,
      'phone': phone,
      'address': address,
      'waterPerDelivery': waterPerDelivery,
      'customerBottles': customerBottles,
    };
  }

  factory UpcomingDelivery.fromMap(Map<String, dynamic> data) {
    return UpcomingDelivery(
      rejected: data['rejected'],
      completed: data['completed'],
      deliveryId: data['deliveryId'],
      customerId: data['customerId'],
      name: data['name'],
      phone: data['phone'],
      address: data['address'],
      waterPerDelivery: data['waterPerDelivery'],
      customerBottles: data['customerBottles'],
    );
  }
}
