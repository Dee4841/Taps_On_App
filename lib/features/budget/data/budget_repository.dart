import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetRepository {
  final SupabaseClient _client;

  BudgetRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<void> saveBudget({
    required String userId,
    required String budgetDate,
    required double amountLeft,
    Map<String, double>? categories,
  }) async {
    await _client.from('monthly_budgets').upsert({
      'user_id': userId,
      'budget_date': budgetDate,
      'amount_left': amountLeft,
    },
      onConflict: 'user_id,budget_date',
    );

    if (categories != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'budget_${userId}_$budgetDate',
        jsonEncode(categories),
      );
    }
  }

  Future<Map<String, dynamic>> getBudgetForDate({
    required String userId,
    required String budgetDate,
  }) async {
    final response = await _client
        .from('monthly_budgets')
        .select('amount_left')
        .eq('user_id', userId)
        .eq('budget_date', budgetDate)
        .maybeSingle();

    final val = response?['amount_left'];
    final double? amountLeft = (val is num) ? val.toDouble() : null;

    Map<String, double> categories = {};
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('budget_${userId}_$budgetDate');
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        categories =
            decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }

    return {
      'amount_left': amountLeft,
      'categories': categories,
    };
  }
}
