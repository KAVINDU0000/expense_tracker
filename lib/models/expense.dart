import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String note;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  factory Expense.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Expense(
      id: doc.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? 'Other',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
