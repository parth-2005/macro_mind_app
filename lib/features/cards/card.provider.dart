import 'package:flutter/material.dart';
import 'package:macro_mind_app/features/cards/card.model.dart';
import 'package:macro_mind_app/core/services/api_service.dart';

class CardProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  List<CardModel> _cards = [];
  bool _isLoading = false;
  String? _error;

  List<CardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCards() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _cards = await apiService.getCards();
    } catch (e) {
      _error = e.toString();
      _cards = []; // Ensure cards is empty on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
