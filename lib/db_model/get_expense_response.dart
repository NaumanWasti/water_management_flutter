class ExpenseModel{
  int Id;
  String ExpenseTitle;
  //String ExpenseDescription ;
  int ExpenseAmount;
  ExpenseModel({
    this.Id = 0,
    required this.ExpenseTitle,
    //required this.ExpenseDescription,
    required this.ExpenseAmount,
  });
  factory ExpenseModel.fromMap(Map<String, dynamic> json) {
    return ExpenseModel(
      ExpenseAmount: json['expenseAmount'],
      //ExpenseDescription: json['expenseDescription'],
      ExpenseTitle: json['expenseTitle'],
      Id: json['id'],
    );
  }
}