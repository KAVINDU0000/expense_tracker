import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../utils/categories.dart';

enum LoadStatus { loading, loaded, error, empty }

class ExpenseProvider extends ChangeNotifier {
  FirestoreService? _service;
  StreamSubscription<List<Expense>>? _sub;

  List<Expense> _allExpenses = [];
  LoadStatus status = LoadStatus.loading;
  String? errorMessage;

  // Filters
  String categoryFilter = kAllCategoriesFilter;
  DateTimeRange? dateRangeFilter;
  String searchQuery = '';

  void attachUser(String uid) {
    _sub?.cancel();
    _service = FirestoreService(uid);
    status = LoadStatus.loading;
    notifyListeners();

    _sub = _service!.watchExpenses().listen(
      (expenses) {
        _allExpenses = expenses;
        status = expenses.isEmpty ? LoadStatus.empty : LoadStatus.loaded;
        errorMessage = null;
        notifyListeners();
      },
      onError: (err) {
        status = LoadStatus.error;
        errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  void detachUser() {
    _sub?.cancel();
    _allExpenses = [];
    status = LoadStatus.loading;
  }

  // ---- Write operations (delegate to FirestoreService) ----

  Future<void> addExpense(Expense expense) async {
    await _service?.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _service?.updateExpense(expense);
  }

  Future<void> deleteViaService(Expense expense) async {
    if (expense.id == null) return;
    await _service?.deleteExpense(expense.id!);
  }

  // ---- Filtering ----

  List<Expense> get filteredExpenses {
    return _allExpenses.where((e) {
      final matchesCategory =
          categoryFilter == kAllCategoriesFilter || e.category == categoryFilter;
      final matchesDate = dateRangeFilter == null ||
          (!e.date.isBefore(dateRangeFilter!.start) &&
              !e.date.isAfter(
                  dateRangeFilter!.end.add(const Duration(hours: 23, minutes: 59))));
      final matchesSearch = searchQuery.isEmpty ||
          e.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          e.note.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesDate && matchesSearch;
    }).toList();
  }

  bool get hasActiveFilters =>
      categoryFilter != kAllCategoriesFilter ||
      dateRangeFilter != null ||
      searchQuery.isNotEmpty;

  void setCategoryFilter(String category) {
    categoryFilter = category;
    notifyListeners();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    dateRangeFilter = range;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    categoryFilter = kAllCategoriesFilter;
    dateRangeFilter = null;
    searchQuery = '';
    notifyListeners();
  }

  // ---- Summary helpers (always based on full data, not filtered view) ----

  double get currentMonthTotal {
    final now = DateTime.now();
    return _allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get currentMonthCategoryTotals {
    final now = DateTime.now();
    final Map<String, double> totals = {};
    for (final e in _allExpenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
