class CounterSaleLogsModel {
  final int counterSaleId;
  final int bottleRate;
  final String saleDateTime;

  CounterSaleLogsModel({
    required this.counterSaleId,
    required this.bottleRate,
    required this.saleDateTime,
  });

  factory CounterSaleLogsModel.fromJson(Map<String, dynamic> json) {
    return CounterSaleLogsModel(
      counterSaleId: json['counterSaleId'],
      bottleRate: json['bottleRate'],
      saleDateTime: json['saleDateTime'],
    );
  }
}

