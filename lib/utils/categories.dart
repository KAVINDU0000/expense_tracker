import 'package:flutter/material.dart';

/// Central place for all expense categories used across the app.
/// Keeping this as a single source of truth avoids typos/duplication
/// between the add/edit form and the filter UI.
class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory(this.name, this.icon, this.color);
}

const List<ExpenseCategory> kCategories = [
  ExpenseCategory('Food', Icons.restaurant, Color(0xFFEF6C00)),
  ExpenseCategory('Transport', Icons.directions_bus, Color(0xFF1E88E5)),
  ExpenseCategory('Shopping', Icons.shopping_bag, Color(0xFF8E24AA)),
  ExpenseCategory('Bills', Icons.receipt_long, Color(0xFFD81B60)),
  ExpenseCategory('Entertainment', Icons.movie, Color(0xFF43A047)),
  ExpenseCategory('Health', Icons.local_hospital, Color(0xFFE53935)),
  ExpenseCategory('Education', Icons.school, Color(0xFF3949AB)),
  ExpenseCategory('Other', Icons.category, Color(0xFF6D4C41)),
];

ExpenseCategory categoryFromName(String name) {
  return kCategories.firstWhere(
    (c) => c.name == name,
    orElse: () => kCategories.last,
  );
}

const String kAllCategoriesFilter = 'All';
