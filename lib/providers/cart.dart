import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/constants.dart';
import 'package:shop_app/providers/HandlingException.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  String? authToken;
  String? userId;

  Cart({this.authToken, this.userId, required Map<String, CartItem> cartList}) {
    _items = cartList;
  }
  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> addItem(
    String productId,
    double price,
    String title,
  ) async {
    try {
      http.Response response;
      if (_items.containsKey(productId)) {
        final cartId = _items[productId]!.id;
        final url = Uri.parse(
            '${Constants.url}/cartItems/$userId.json?auth=$authToken');
        final quantity = _items[productId]!.quantity + 1;
        Map<String, dynamic> body = {
          productId: {
            'cartid': cartId,
            'price': price,
            'title': title,
            'quantity': quantity,
            'userid': userId,
          },
        };

        response = await http.patch(url, body: json.encode(body));
      } else {
        //final cartId = _items[productId]?.id;
        final url = Uri.parse(
            '${Constants.url}/cartItems/$userId.json?auth=$authToken');
        Map<String, dynamic> body = {
          productId: {
            'price': price,
            'title': title,
            'quantity': 1,
            'userid': userId,
          },
        };

        response = await http.post(url, body: json.encode(body));
      }

      if (_items.containsKey(productId)) {
        // change quantity...
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity + 1,
          ),
        );
      } else {
        _items.putIfAbsent(
          productId,
          () => CartItem(
            id: json.decode(response.body)['name'],
            title: title,
            price: price,
            quantity: 1,
          ),
        );
      }
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> get getCartItems async {
    final url =
        Uri.parse('${Constants.url}/cartItems/$userId.json?auth=$authToken');
    try {
      http.Response response = await http.get(url);

      if (response.body == 'null' || response.body.isEmpty) {
        _items = {};
        return;
      }
      Map<String, dynamic> loadedItems =
          jsonDecode(response.body) as Map<String, dynamic>;

      Map<String, CartItem> loadedCartItems = {};

      loadedItems.forEach(
        (cartKey, cartVal) {
          final cart = cartVal as Map<String, dynamic>;
          cart.forEach((key, value) {
            CartItem singleItem = CartItem(
              id: cartKey,
              title: value['title'],
              quantity: value["quantity"],
              price: value['price'],
            );
            loadedCartItems.addAll({key: singleItem});
          });
        },
      );

      _items = loadedCartItems;
      notifyListeners();
    } catch (error) {
      debugPrint(" End Up here ");
      print(error.toString());
    }
  }

  Future<void> removeItem(String productId) async {
    final cartId = _items[productId]!.id;
    final url = Uri.parse(
        '${Constants.url}/cartItems/$userId/$cartId.json?auth=$authToken');
    try {
      await http.delete(url);

      _items.remove(productId);
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  Future<void> clear() async {
    try {
      final url = Uri.parse('${Constants.url}/cartItems.json?auth=$authToken');
      await http.delete(url);

      _items = {};
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  int get cartLength {
    return _items.length;
  }
}
