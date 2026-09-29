import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../models/expense.dart';
import '../utils/categories.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = categoryFromName(expense.category);
    final currency = context.watch<CurrencyProvider>().formatter;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete expense?'),
                content: Text('Delete "${expense.title}"? This cannot be undone.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: category.color.withValues(alpha: 0.15),
            child: Icon(category.icon, color: category.color),
          ),
          title: Text(expense.title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${expense.category} • ${DateFormat.yMMMd().format(expense.date)}'
            '${expense.note.isNotEmpty ? '\n${expense.note}' : ''}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: expense.note.isNotEmpty,
          trailing: Text(
            currency.format(expense.amount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
