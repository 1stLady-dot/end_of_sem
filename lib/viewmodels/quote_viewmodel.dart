import 'package:flutter/material.dart';
import '../services/quote_service.dart';
import '../models/quote_model.dart';

class QuoteViewModel extends ChangeNotifier {
  final QuoteService _quoteService = QuoteService();
  
  Quote? _currentQuote;
  bool _isLoading = false;
  String? _errorMessage;
  
  Quote? get currentQuote => _currentQuote;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadRandomQuote() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _currentQuote = await _quoteService.fetchRandomQuote();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}