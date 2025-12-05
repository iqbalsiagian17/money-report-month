import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/budget.dart';
import '../../models/transaction.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/progress_bar.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Bulanan'),
        actions: [
          IconButton(
            onPressed: () => _showAddBudgetDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer3<BudgetProvider, CategoryProvider, TransactionProvider>(
        builder: (context, budgetProvider, categoryProvider, txProvider, _) {
          final budgets = budgetProvider.getCurrentMonthBudgets();

          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada budget bulan ini',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBudgetDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Budget'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Month Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy', 'id_ID').format(now),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${budgets.length} kategori dengan budget',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Budget Cards
              ...budgets.map((budget) {
                final category = categoryProvider.getById(budget.categoryId);
                final spent = txProvider.thisMonthTransactions
                    .where((t) =>
                        t.categoryId == budget.categoryId &&
                        t.type == TransactionType.expense)
                    .fold<double>(0, (sum, t) => sum + t.amount);

                final progress = spent / budget.limitAmount;
                final percentage = (progress * 100).round();
                final remaining = budget.limitAmount - spent;

                Color progressColor;
                if (percentage >= 100) {
                  progressColor = Colors.red;
                } else if (percentage >= 80) {
                  progressColor = Colors.orange;
                } else {
                  progressColor = Colors.green;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showBudgetOptions(context, budget),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      Color(category?.colorValue ?? 0xFF888888)
                                          .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    category?.icon ?? '📦',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category?.name ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Budget: ${currencyFormat.format(budget.limitAmount)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: progressColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    color: progressColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ProgressBar(
                            progress: progress.clamp(0, 1),
                            color: progressColor,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Terpakai: ${currencyFormat.format(spent)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                remaining >= 0
                                    ? 'Sisa: ${currencyFormat.format(remaining)}'
                                    : 'Lebih: ${currencyFormat.format(-remaining)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: remaining >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (percentage >= 80 && percentage < 100) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning,
                                      color: Colors.orange, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Budget hampir habis!',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (percentage >= 100) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.error,
                                      color: Colors.red, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Budget sudah terlampaui!',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final amountController = TextEditingController();
    String? selectedCategoryId;
    final now = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('Tambah Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categoryProvider.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Text(cat.icon),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedCategoryId = value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Limit Budget',
                      prefixText: 'Rp ',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategoryId != null &&
                        amountController.text.isNotEmpty) {
                      final budget = Budget(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        categoryId: selectedCategoryId!,
                        limitAmount: double.parse(amountController.text),
                        month: now.month,
                        year: now.year,
                      );
                      context.read<BudgetProvider>().addBudget(budget);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBudgetOptions(BuildContext context, Budget budget) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opsi Budget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Budget'),
              onTap: () {
                Navigator.pop(context);
                _showEditBudgetDialog(context, budget);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Budget',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<BudgetProvider>().deleteBudget(budget.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    final amountController = TextEditingController(
      text: budget.limitAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Budget'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Limit Budget',
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              budget.limitAmount = double.parse(amountController.text);
              context.read<BudgetProvider>().updateBudget(budget);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
