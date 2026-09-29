import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/expense_chart.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/filter_bar.dart';
import '../widgets/state_views.dart';
import '../widgets/summary_card.dart';
import '../widgets/currency_selector.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Attach the signed-in user's uid to start listening to their expenses.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AppAuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ExpenseProvider>().attachUser(uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: _showSearch
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search expenses…',
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onChanged: expenseProvider.setSearchQuery,
                )
              : const Text('Expense Tracker'),
          actions: [
            const CurrencySelector(),
            IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search),
              tooltip: _showSearch ? 'Clear search' : 'Search expenses',
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    expenseProvider.setSearchQuery('');
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode_outlined),
              onPressed: () =>
                  themeProvider.toggleDarkMode(!themeProvider.isDarkMode),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'signout') {
                  context.read<AppAuthProvider>().signOut();
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'signout', child: Text('Sign out')),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: _ExpensesTab(
                  expenseProvider: expenseProvider,
                  onClearFilters: () {
                    _searchController.clear();
                    expenseProvider.clearFilters();
                  },
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: _SummaryTab(expenseProvider: expenseProvider),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add expense'),
        ),
      ),
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final ExpenseProvider expenseProvider;
  final VoidCallback onClearFilters;

  const _ExpensesTab({
    required this.expenseProvider,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SummaryCard(monthTotal: expenseProvider.currentMonthTotal),
        const SizedBox(height: 8),
        FilterBar(onClear: onClearFilters),
        const SizedBox(height: 4),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (expenseProvider.status) {
      case LoadStatus.loading:
        return const LoadingView();
      case LoadStatus.error:
        return ErrorView(
          message: expenseProvider.errorMessage ?? 'Unknown error',
          onRetry: () {
            final uid = context.read<AppAuthProvider>().user?.uid;
            if (uid != null) expenseProvider.attachUser(uid);
          },
        );
      case LoadStatus.empty:
        return const EmptyView();
      case LoadStatus.loaded:
        final filtered = expenseProvider.filteredExpenses;
        if (filtered.isEmpty) {
          return const EmptyView(
            title: 'No matching expenses',
            subtitle: 'Try adjusting or clearing your filters.',
            icon: Icons.filter_alt_off_outlined,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) {
            final expense = filtered[i];
            return ExpenseListItem(
              expense: expense,
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => AddEditExpenseScreen(expense: expense),
                ),
              ),
              onDelete: () =>
                  context.read<ExpenseProvider>().deleteViaService(expense),
            );
          },
        );
    }
  }
}

class _SummaryTab extends StatelessWidget {
  final ExpenseProvider expenseProvider;
  const _SummaryTab({required this.expenseProvider});

  @override
  Widget build(BuildContext context) {
    if (expenseProvider.status == LoadStatus.loading) {
      return const LoadingView();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 96),
      child: Column(
        children: [
          SummaryCard(monthTotal: expenseProvider.currentMonthTotal),
          const SizedBox(height: 16),
          ExpenseChart(
              categoryTotals: expenseProvider.currentMonthCategoryTotals),
        ],
      ),
    );
  }
}
