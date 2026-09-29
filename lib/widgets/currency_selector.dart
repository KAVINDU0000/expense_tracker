import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    return TextButton(
      onPressed: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (dialogContext) => SimpleDialog(
            title: const Text('Choose currency'),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                    'Applies to all expenses on this device. Amounts are not converted.'),
              ),
              for (final entry in CurrencyProvider.currencies.entries)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, entry.key),
                  child: Row(
                    children: [
                      Icon(
                          currency.code == entry.key
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${entry.key} — ${entry.value}')),
                    ],
                  ),
                ),
            ],
          ),
        );
        if (selected == null) return;
        try {
          await currency.select(selected);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Could not save currency. Please try again.')),
            );
          }
        }
      },
      child: Tooltip(message: 'Change currency', child: Text(currency.code)),
    );
  }
}
