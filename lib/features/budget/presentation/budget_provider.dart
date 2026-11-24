import 'package:flutter/foundation.dart';
import '../data/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _budgetRepository;

  BudgetProvider({required BudgetRepository budgetRepository})
      : _budgetRepository = budgetRepository;

  double? _savedAmountForDate;
  Map<String, double> _savedCategoriesForDate = {};
  bool _isLoading = false;
  String? _error;

  double? get savedAmountForDate => _savedAmountForDate;
  Map<String, double> get savedCategoriesForDate => _savedCategoriesForDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSavedAmount({
    required String userId,
    required String budgetDate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _budgetRepository.getBudgetForDate(
        userId: userId,
        budgetDate: budgetDate,
      );
      _savedAmountForDate = data['amount_left'] as double?;
      _savedCategoriesForDate =
          data['categories'] as Map<String, double>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBudget({
    required String userId,
    required String budgetDate,
    required double amountLeft,
    Map<String, double>? categories,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _budgetRepository.saveBudget(
        userId: userId,
        budgetDate: budgetDate,
        amountLeft: amountLeft,
        categories: categories,
      );
      _savedAmountForDate = amountLeft;
      if (categories != null) {
        _savedCategoriesForDate = categories;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
