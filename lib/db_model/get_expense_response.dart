class ExpenseModel{
  int Id;
  String ExpenseTitle;
  String ExpenseDate;
  String ExpenseDescription ;
  int ExpenseAmount;
  ExpenseModel({
    this.Id = 0,
    required this.ExpenseTitle,
    this.ExpenseDescription = "",
    required this.ExpenseAmount,
    this.ExpenseDate = '',
  });
  factory ExpenseModel.fromMap(Map<String, dynamic> json) {
    return ExpenseModel(
      ExpenseAmount: json['expenseAmount'],
      ExpenseDate: json['expenseDate'],
      ExpenseDescription: json['expenseDescription'],
      ExpenseTitle: json['expenseTitle'],
      Id: json['id'],
    );
  }
}