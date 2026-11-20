import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetRepository {
  final SupabaseClient _client;

  BudgetRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<void> saveBudget({
    required String userId,
    required String budgetDate,
    required double amountLeft,
  }) async {
    await _client.from('monthly_budgets').upsert({
      'user_id': userId,
      'budget_date': budgetDate,
      'amount_left': amountLeft,
    });
  }

  Future<double?> getBudgetForDate({
    required String userId,
    required String budgetDate,
  }) async {
    final response = await _client
        .from('monthly_budgets')
        .select('amount_left')
        .eq('user_id', userId)
        .eq('budget_date', budgetDate)
        .maybeSingle();
    if (response == null) return null;
    final val = response['amount_left'];
    return (val is num) ? val.toDouble() : null;
  }
}
