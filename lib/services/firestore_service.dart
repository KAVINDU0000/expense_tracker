import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

/// Handles all Firestore reads/writes for a single user's expenses.
/// Data is stored under `users/{uid}/expenses/{expenseId}` so each
/// user's data is naturally isolated (paired with Firestore security
/// rules that check request.auth.uid == uid).
class FirestoreService {
  final String uid;
  FirestoreService(this.uid);

  CollectionReference<Map<String, dynamic>> get _expensesRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('expenses');

  Stream<List<Expense>> watchExpenses() {
    return _expensesRef.orderBy('date', descending: true).snapshots().map(
        (snap) => snap.docs.map((doc) => Expense.fromDoc(doc)).toList());
  }

  Future<void> addExpense(Expense expense) async {
    await _expensesRef.add(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    assert(expense.id != null, 'Cannot update an expense without an id');
    await _expensesRef.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await _expensesRef.doc(id).delete();
  }
}
