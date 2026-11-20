import 'package:flutter/foundation.dart';
import '../data/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _budgetRepository;

  BudgetProvider({required BudgetRepository budgetRepository})
      : _budgetRepository = budgetRepository;

  double? _savedAmountForDate;
  bool _isLoading = false;
  String? _error;

  double? get savedAmountForDate => _savedAmountForDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSavedAmount({
    required String userId,
    required String budgetDate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _savedAmountForDate = await _budgetRepository.getBudgetForDate(
        userId: userId,
        budgetDate: budgetDate,
      );
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
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _budgetRepository.saveBudget(
        userId: userId,
        budgetDate: budgetDate,
        amountLeft: amountLeft,
      );
      _savedAmountForDate = amountLeft;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
