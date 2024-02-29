class CompleteDeliveryRequest {
  int CustomerDeliveryId;
  int CustomerId;
  int WaterBottlesGiven;
  int BottleBack;
  int AmountPaid;

  CompleteDeliveryRequest({
    required this.CustomerDeliveryId,
    required this.CustomerId,
    required this.WaterBottlesGiven,
    required this.BottleBack,
    required this.AmountPaid,
  });

  Map<String, dynamic> toMap() {
    return {
      'CustomerDeliveryId': CustomerDeliveryId,
      'CustomerId': CustomerId,
      'WaterBottlesGiven': WaterBottlesGiven,
      'BottleBack': BottleBack,
      'AmountPaid': AmountPaid,
    };
  }

  factory CompleteDeliveryRequest.fromMap(Map<String, dynamic> data) {
    return CompleteDeliveryRequest(
      CustomerDeliveryId: data['CustomerDeliveryId'],
      CustomerId: data['CustomerId'],
      WaterBottlesGiven: data['WaterBottlesGiven'],
      BottleBack: data['BottleBack'],
      AmountPaid: data['AmountPaid'],
    );
  }
}
