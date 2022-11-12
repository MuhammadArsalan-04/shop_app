import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userid) async {
    // isFavorite = !isFavorite;
    // notifyListeners();
    final url =
        Uri.parse('${Constants.url}/favourites/$userid.json?auth=$token');

    final bool oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();
    final data = {
      id: isFavorite,
    };
    final response = await http.patch(url, body: json.encode(data));
    if (response.statusCode >= 400) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
