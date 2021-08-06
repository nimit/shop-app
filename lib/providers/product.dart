import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });
  void _isFavRollback() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  void toggleFavorite(String authToken, String userId) async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://flutter-demo-7f8f0.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) _isFavRollback();
    } catch (error) {
      print(error);
      _isFavRollback();
    }
  }
}
