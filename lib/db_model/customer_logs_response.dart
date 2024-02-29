class CustomerLogsResponse {
  final int waterBottlesGiven;
  final int bottleBack;
  final int amountPaid;
  final int DeliveryId;
  final int DeliveryDayId;
  final String deliveryDay;
  final String deliveryDateTime;

  CustomerLogsResponse({
    required this.waterBottlesGiven,
    required this.bottleBack,
    required this.amountPaid,
    required this.DeliveryDayId,
    required this.DeliveryId,
    required this.deliveryDay,
    required this.deliveryDateTime,
  });

  factory CustomerLogsResponse.fromMap(Map<String, dynamic> data) {
    return CustomerLogsResponse(
      deliveryDateTime: data['deliveryDateTime'],
      deliveryDay: data['deliveryDay'],
      bottleBack: data['bottleBack'] ?? 0, // Default value if null
      waterBottlesGiven: data['waterBottlesGiven'] ?? 0, // Default value if null
      DeliveryId: data['deliveryId'] ?? 0, // Default value if null
      DeliveryDayId: data['DeliveryDayId'] ?? 0, // Default value if null
      amountPaid: data['amountPaid'] ?? 0, // Default value if null
    );
  }
}
