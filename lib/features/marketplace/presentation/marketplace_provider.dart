import 'package:flutter/foundation.dart';
import '../data/marketplace_repository.dart';
import '../domain/marketplace_item.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceRepository _marketplaceRepository;

  MarketplaceProvider({required MarketplaceRepository marketplaceRepository})
      : _marketplaceRepository = marketplaceRepository;

  List<MarketplaceItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<MarketplaceItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _marketplaceRepository.getItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createItem({
    required String sellerId,
    required String title,
    required String price,
    required String location,
    required String description,
    required Uint8List imageBytes,
    required String imageFileName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _marketplaceRepository.createItem(
        sellerId: sellerId,
        title: title,
        price: price,
        location: location,
        description: description,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );
      await loadItems();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
