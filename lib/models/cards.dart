class CardDetails {
  final String id;
  final String title;
  final double balance;
  final int cardDigits;
  // final int incomeTotal;
  // final int expenseTotal;

  CardDetails({
    required this.id,
    required this.title,
    required this.balance,
    required this.cardDigits,
    // required this.incomeTotal,
    // required this.expenseTotal,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'balance': balance,
        'cardDigits': cardDigits,
        // 'incomeTotal': incomeTotal,
        // 'expenseTotal': expenseTotal,
      };
  static CardDetails fromJson(Map<String, dynamic> json) => CardDetails(
        id: json['id'],
        title: json['title'],
        balance: json['balance'],
        cardDigits: json['cardDigits'],
        // incomeTotal: json['incomeTotal'],
        // expenseTotal: json['expenseTotal'],
      );
}
