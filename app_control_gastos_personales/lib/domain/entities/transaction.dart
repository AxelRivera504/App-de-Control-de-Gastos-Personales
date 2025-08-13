import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionEntity {
  final String id;
  final String userId;
  final String categoryId;
  final int trantypeid; // 1=Income, 2=Expense
  final double amount; 
  final DateTime date;
  final String? notes;

  TransactionEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.trantypeid,
    required this.amount,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'transactionid': id,
    'userid': userId,
    'categoryid': categoryId,
    'trantypeid': trantypeid,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'notes': notes,
  };
}
