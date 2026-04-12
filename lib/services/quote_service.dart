import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class QuoteService {
  static const String _apiUrl = 'https://api.quotable.io/random';
  
  Future<Quote> fetchRandomQuote() async {
    try {
      final uri = Uri.parse(_apiUrl);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quote.fromJson(data);
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      // Return a fallback quote
      return Quote(
        content: 'Stay safe and stay alert. Your safety is our priority.',
        author: 'CampusGuard',
      );
    }
  }
}