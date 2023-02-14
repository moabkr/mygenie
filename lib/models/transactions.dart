import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionData {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String cardDigits;
  final bool income;

  TransactionData({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.cardDigits,
    required this.income,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date,
        'cardDigits': cardDigits,
        'income': income
      };
  static TransactionData fromJson(Map<String, dynamic> json) => TransactionData(
        id: json['id'],
        title: json['title'],
        amount: json['amount'],
        date: (json['date'] as Timestamp).toDate(),
        cardDigits: json['cardDigits'],
        income: json['income'],
      );
}
