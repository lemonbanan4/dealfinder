import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../features/deals/domain/deal.dart'; // Import your Deal model

class ProductProvider with ChangeNotifier {
  List<Deal> _deals = [];
  bool _isLoading = false;

  List<Deal> get deals => _deals;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.apiUrl}/api/products'),
      );

      // DEBUG: Print the first 200 chars of the response
      debugPrint('Response Body: ${response.body.substring(0, 200)}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Convert the JSON list to your Deal objects
        _deals = data.map((json) => Deal.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('CRITICAL FETCH ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
