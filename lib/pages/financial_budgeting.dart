import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/budget/presentation/budget_provider.dart';

class FinancialBudgetingPage extends StatefulWidget {
  const FinancialBudgetingPage({super.key});

  @override
  State<FinancialBudgetingPage> createState() => _FinancialBudgetingPageState();
}

class _FinancialBudgetingPageState extends State<FinancialBudgetingPage> {
  final incomeController = TextEditingController();
  final foodController = TextEditingController();
  final personalCareController = TextEditingController();
  final wellnessController = TextEditingController();
  final clothingController = TextEditingController();
  final entertainmentController = TextEditingController();
  final transportController = TextEditingController();
  final otherExpensesController = TextEditingController();

  double remainingAmount = 0.0;

  DateTime selectedBudgetDate = DateTime.now();
  DateTime selectedDateToView = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedAmount(selectedDateToView);
    });
  }

  double _parse(TextEditingController c) =>
    double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0.0;

  double _computeRemaining() {
    final totalExpenses = _parse(foodController) +
        _parse(personalCareController) +
        _parse(wellnessController) +
        _parse(clothingController) +
        _parse(entertainmentController) +
        _parse(transportController) +
        _parse(otherExpensesController);
    return _parse(incomeController) - totalExpenses;
  }
  
  void _calculateRemaining() {
    setState(() => remainingAmount = _computeRemaining());
  }

  void _clearFields() {
    incomeController.clear();
    foodController.clear();
    personalCareController.clear();
    wellnessController.clear();
    clothingController.clear();
    entertainmentController.clear();
    transportController.clear();
    otherExpensesController.clear();

    setState(() {
      remainingAmount = 0.0;
    });
  }

  Future<void> _pickBudgetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedBudgetDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedBudgetDate = picked;
      });
    }
  }

  Future<void> _pickViewDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateToView,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateToView = picked;
      });
      _loadSavedAmount(picked);
    }
  }

  Future<void> saveBudgetToDatabase() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final remaining = _computeRemaining();   
    if (mounted) setState(() => remainingAmount = remaining);

    try {
      await context.read<BudgetProvider>().saveBudget(
            userId: userId,
            budgetDate: DateFormat('yyyy-MM-dd').format(selectedBudgetDate),
            amountLeft: remaining,
            categories: {
              'income': _parse(incomeController),
              'food': _parse(foodController),
              'personalCare': _parse(personalCareController),
              'wellness': _parse(wellnessController),
              'clothing': _parse(clothingController),
              'entertainment': _parse(entertainmentController),
              'transport': _parse(transportController),
              'other': _parse(otherExpensesController),
            },
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save budget,$e' )),
        );
      }
    }
  }

  Future<void> _loadSavedAmount(DateTime date) async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final provider = context.read<BudgetProvider>();
    await provider.loadSavedAmount(
      userId: userId,
      budgetDate: DateFormat('yyyy-MM-dd').format(date),
    );

    if (!mounted) return;
    final cats = provider.savedCategoriesForDate;
    if (cats.isNotEmpty) {
      incomeController.text = (cats['income'] ?? 0.0).toStringAsFixed(2);
      foodController.text = (cats['food'] ?? 0.0).toStringAsFixed(2);
      personalCareController.text =
          (cats['personalCare'] ?? 0.0).toStringAsFixed(2);
      wellnessController.text = (cats['wellness'] ?? 0.0).toStringAsFixed(2);
      clothingController.text = (cats['clothing'] ?? 0.0).toStringAsFixed(2);
      entertainmentController.text =
          (cats['entertainment'] ?? 0.0).toStringAsFixed(2);
      transportController.text = (cats['transport'] ?? 0.0).toStringAsFixed(2);
      otherExpensesController.text =
          (cats['other'] ?? 0.0).toStringAsFixed(2);
      _calculateRemaining();
    }
  }

  @override
  void dispose() {
    incomeController.dispose();
    foodController.dispose();
    personalCareController.dispose();
    wellnessController.dispose();
    clothingController.dispose();
    entertainmentController.dispose();
    transportController.dispose();
    otherExpensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd');
    final budgetProvider = context.watch<BudgetProvider>();
    final savedAmountForDate = budgetProvider.savedAmountForDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Budgeting'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('View Saved Budget For Date:'),
                  ElevatedButton(
                    onPressed: _pickViewDate,
                    child: Text(format.format(selectedDateToView)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (savedAmountForDate != null)
                Text(
                  '💰 Saved amount on ${format.format(selectedDateToView)}: R${savedAmountForDate.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  '📅 No saved amount found for ${format.format(selectedDateToView)}.',
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),

              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Budget Date:'),
                  ElevatedButton(
                    onPressed: _pickBudgetDate,
                    child: Text(format.format(selectedBudgetDate)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              buildLabeledField(
                  'Monthly Income:', Icons.attach_money, incomeController),
              const SizedBox(height: 20),
              const Text(
                'Less Monthly Expenses:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              buildLabeledField(
                  'Food and Groceries:', Icons.local_grocery_store, foodController),
              buildLabeledField('Personal Care:', Icons.spa, personalCareController),
              buildLabeledField('Wellness/Health (Gym Membership):',
                  Icons.fitness_center, wellnessController),
              buildLabeledField(
                  'Clothing & Essentials:', Icons.shopping_bag, clothingController),
              buildLabeledField(
                  'Entertainment and Social:', Icons.movie, entertainmentController),
              buildLabeledField('Fuel, Transport and Parking:',
                  Icons.directions_car, transportController),
              buildLabeledField(
                  'Other Expenses:', Icons.more_horiz, otherExpensesController),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _calculateRemaining,
                    child: const Text('Calculate'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _clearFields,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: saveBudgetToDatabase,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'This is how much you have left for the month: R${remainingAmount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabeledField(
      String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter amount',
            ),
          ),
        ],
      ),
    );
  }
}
