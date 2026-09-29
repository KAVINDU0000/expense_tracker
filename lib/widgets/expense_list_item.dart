import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../models/expense.dart';
import '../utils/categories.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = categoryFromName(expense.category);
    final amount =
        context.watch<CurrencyProvider>().formatter.format(expense.amount);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _deleteWithFeedback(context),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 420) {
              return InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: category.color.withValues(alpha: 0.15),
                        child: Icon(category.icon, color: category.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              expense.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            _details(maxLines: 2),
                            Row(
                              children: [
                                Expanded(child: _amount(amount)),
                                _deleteButton(context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListTile(
              onTap: onTap,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: category.color.withValues(alpha: 0.15),
                child: Icon(category.icon, color: category.color),
              ),
              title: Text(expense.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: _details(maxLines: 2),
              isThreeLine: expense.note.isNotEmpty,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _amount(amount),
                  const SizedBox(width: 4),
                  _deleteButton(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _details({required int maxLines}) => Text(
        '${expense.category} • ${DateFormat.yMMMd().format(expense.date)}'
        '${expense.note.isNotEmpty ? '\n${expense.note}' : ''}',
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );

  Widget _amount(String amount) => Text(
        amount,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      );

  Widget _deleteButton(BuildContext context) => IconButton(
        tooltip: 'Delete expense',
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: () async {
          if (await _confirmDelete(context) && context.mounted) {
            await _deleteWithFeedback(context);
          }
        },
      );

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete expense?'),
            content: Text('Delete "${expense.title}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteWithFeedback(BuildContext context) async {
    try {
      await onDelete();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete expense. Please try again.'),
          ),
        );
      }
    }
  }
}
