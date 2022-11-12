import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  String? authToken;
  String? userid;
  Orders({this.authToken, this.userid, required List<OrderItem> ordersList}) {
    _orders = ordersList;
  }

  List<OrderItem> get orders {
    return [..._orders.reversed];
  }

  Future<void> getOrders() async {
    try {
      final url =
          Uri.parse('${Constants.url}/orders/$userid.json?auth=$authToken');

      http.Response response = await http.get(url);

      Map<String, dynamic> loadedOrders =
          jsonDecode(response.body) as Map<String, dynamic>;

      List<OrderItem> allOrders = [];

      loadedOrders.forEach((orderKey, orderItem) {
        OrderItem singleOrder = OrderItem(
            id: orderKey,
            amount: orderItem['amount'],
            products:
                (orderItem['orderProducts'] as List<dynamic>).map((element) {
              return CartItem(
                  id: element['cartId'],
                  title: element['title'],
                  quantity: element['quantity'],
                  price: element['price']);
            }).toList(),
            dateTime: DateTime.parse(orderItem['orderTime']));

        allOrders.add(singleOrder);
      });

      _orders = allOrders;
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    try {
      final url =
          Uri.parse('${Constants.url}/orders/$userid.json?auth=$authToken');

      final timestamp = DateTime.now();

      Map<String, dynamic> body = {
        'amount': total,
        'orderTime': timestamp.toString(),
        'orderProducts': cartProducts
            .map((cartId) => {
                  'cartId': cartId.id,
                  'price': cartId.price,
                  'quantity': cartId.quantity,
                  'title': cartId.title,
                })
            .toList(),
      };

      http.Response response = await http.post(
        url,
        body: json.encode(body),
      );

      _orders.insert(
        0,
        OrderItem(
          id: jsonDecode(response.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
        ),
      );

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}