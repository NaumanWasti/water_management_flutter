class BusinessInfo {
  int totalEarning;
  int totalAdvance;
  bool edit ;
  String businessName;
  int totalBottle;
  int bottleAvailable;
  int bottleRate;
  int TotalExpense;

  BusinessInfo({
     this.totalEarning = 0,
     this.TotalExpense = 0,
     this.totalAdvance = 0,
     this.bottleAvailable = 0,
     this.edit=false,
    required this.businessName,
    required this.totalBottle,
    required this.bottleRate,
  });

  factory BusinessInfo.fromMap(Map<String, dynamic> json) {
    return BusinessInfo(
      totalEarning: json['totalEarning'],
      TotalExpense: json['totalExpense'],
      totalAdvance: json['totalAdvance'],
      bottleAvailable: json['bottleAvailable'],
      businessName: json['businessName'],
      totalBottle: json['totalBottle'],
      bottleRate: json['bottleRate'],
    );
  }
}
