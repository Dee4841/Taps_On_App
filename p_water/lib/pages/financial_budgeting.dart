import 'package:flutter/material.dart';

class FinancialBudgetingPage extends StatefulWidget {
  const FinancialBudgetingPage({super.key});

  @override
  State<FinancialBudgetingPage> createState() => _FinancialBudgetingPageState();
}

class _FinancialBudgetingPageState extends State<FinancialBudgetingPage> {
  // Controllers to read user input
  final incomeController = TextEditingController();
  final foodController = TextEditingController();
  final personalCareController = TextEditingController();
  final wellnessController = TextEditingController();
  final clothingController = TextEditingController();
  final entertainmentController = TextEditingController();
  final transportController = TextEditingController();
  final otherExpensesController = TextEditingController();

  double remainingAmount = 0.0;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Budgeting'),backgroundColor: Colors.blue,),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                   child: const Text('Clear'),
             ),
           ],
        ),

              const SizedBox(height: 20),

              Text(
                'This is how much you have left for the month: R${remainingAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Last month you saved:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
