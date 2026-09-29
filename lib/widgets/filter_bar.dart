import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/categories.dart';

class FilterBar extends StatelessWidget {
  final VoidCallback? onClear;

  const FilterBar({super.key, this.onClear});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final dateFmt = DateFormat.MMMd();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _FilterChip(
            icon: Icons.category_outlined,
            label: provider.categoryFilter == kAllCategoriesFilter
                ? 'Category'
                : provider.categoryFilter,
            active: provider.categoryFilter != kAllCategoriesFilter,
            onTap: () => _showCategoryPicker(context, provider),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            icon: Icons.date_range_outlined,
            label: provider.dateRangeFilter == null
                ? 'Choose dates'
                : '${dateFmt.format(provider.dateRangeFilter!.start)} - '
                    '${dateFmt.format(provider.dateRangeFilter!.end)}',
            active: provider.dateRangeFilter != null,
            onTap: () => _pickDateRange(context, provider),
          ),
          if (provider.hasActiveFilters) ...[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
              onPressed: onClear ?? provider.clearFilters,
            ),
          ],
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('All categories'),
              trailing: provider.categoryFilter == kAllCategoriesFilter
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                provider.setCategoryFilter(kAllCategoriesFilter);
                Navigator.pop(ctx);
              },
            ),
            ...kCategories.map(
              (c) => ListTile(
                leading: Icon(c.icon, color: c.color),
                title: Text(c.name),
                trailing: provider.categoryFilter == c.name
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  provider.setCategoryFilter(c.name);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
      BuildContext context, ExpenseProvider provider) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: provider.dateRangeFilter,
    );
    if (range != null) {
      provider.setDateRangeFilter(range);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
    );
  }
}
