import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;
  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  void _setFavoriteStatus(bool newStatus) {
    isFavourite = newStatus;
    notifyListeners();
  }

  Future<void> toggleFavoriteIcon(String token, String userId) async {
    final oldFavoriteStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://flutter-http-request-d1ee4-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavourite,
          ));
      if (response.statusCode >= 400) {
        _setFavoriteStatus(oldFavoriteStatus);
      }
    } catch (error) {
      _setFavoriteStatus(oldFavoriteStatus);
      throw error;
    }
  }
}
