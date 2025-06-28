import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class FinancialBudgetingPage extends StatefulWidget {
  const FinancialBudgetingPage({super.key});

  @override
  State<FinancialBudgetingPage> createState() => _FinancialBudgetingPageState();
}

class _FinancialBudgetingPageState extends State<FinancialBudgetingPage> {
  final SupabaseClient _client = Supabase.instance.client;

  // Controllers for budgeting input
  final incomeController = TextEditingController();
  final foodController = TextEditingController();
  final personalCareController = TextEditingController();
  final wellnessController = TextEditingController();
  final clothingController = TextEditingController();
  final entertainmentController = TextEditingController();
  final transportController = TextEditingController();
  final otherExpensesController = TextEditingController();

  double remainingAmount = 0.0;

  // Date pickers
  DateTime selectedBudgetDate = DateTime.now();
  DateTime selectedDateToView = DateTime.now();
  double? savedAmountForDate;

  void _calculateRemaining() {
    double parse(TextEditingController c) => double.tryParse(c.text) ?? 0.0;

    final income = parse(incomeController);
    final totalExpenses = parse(foodController) +
        parse(personalCareController) +
        parse(wellnessController) +
        parse(clothingController) +
        parse(entertainmentController) +
        parse(transportController) +
        parse(otherExpensesController);

    setState(() {
      remainingAmount = income - totalExpenses;
    });
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
        loadSavedAmount(picked);
      });
    }
  }

Future<void> saveBudgetToDatabase() async {
  final user = _client.auth.currentUser;
  if (user == null) return;

  await _client.from('monthly_budgets').upsert({
    'user_id': user.id,
    'budget_date': DateFormat('yyyy-MM-dd').format(selectedBudgetDate),
    'amount_left': remainingAmount,
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Budget saved!')),
  );
}


Future<void> loadSavedAmount(DateTime date) async {
  final user = _client.auth.currentUser;
  if (user == null) return;

  final response = await _client
      .from('monthly_budgets')
      .select('amount_left')
      .eq('user_id', user.id)
      .eq('budget_date', DateFormat('yyyy-MM-dd').format(date))
      .maybeSingle();

  setState(() {
    savedAmountForDate = response?['amount_left']?.toDouble();
  });
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
              // View budget for selected date
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
                 '💰 Saved amount on ${format.format(selectedDateToView)}: R${savedAmountForDate!.toStringAsFixed(2)}',
                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
             )
            else
           Text(
           '📅 No saved amount found for ${format.format(selectedDateToView)}.',
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
           ),

              const Divider(),

              // Budgeting section
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
              buildLabeledField('Monthly Income:', Icons.attach_money, incomeController),
              const SizedBox(height: 20),
              const Text(
                'Less Monthly Expenses:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              buildLabeledField('Food and Groceries:', Icons.local_grocery_store, foodController),
              buildLabeledField('Personal Care:', Icons.spa, personalCareController),
              buildLabeledField('Wellness/Health (Gym Membership):', Icons.fitness_center, wellnessController),
              buildLabeledField('Clothing & Essentials:', Icons.shopping_bag, clothingController),
              buildLabeledField('Entertainment and Social:', Icons.movie, entertainmentController),
              buildLabeledField('Fuel, Transport and Parking:', Icons.directions_car, transportController),
              buildLabeledField('Other Expenses:', Icons.more_horiz, otherExpensesController),
              const SizedBox(height: 30),

              // Buttons
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: saveBudgetToDatabase,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'This is how much you have left for the month: R${remainingAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabeledField(String label, IconData icon, TextEditingController controller) {
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
