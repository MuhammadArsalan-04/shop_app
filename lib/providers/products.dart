import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/HandlingException.dart';
import 'dart:convert';

import '../constants.dart';
import './product.dart';

class Products with ChangeNotifier implements Exception {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  String? authToken;
  String? userid;
  // Products({this.authToken,  this._items =  const []});

  Products({this.authToken, required List<Product> itemsList, this.userid}) {
    _items = itemsList;
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse('${Constants.url}/products.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'userid': userid!,
          },
        ),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchProducts({bool filterById = false}) async {
    String path = filterById
        ? '${Constants.url}/products.json?auth=$authToken&orderBy="userid"&equalTo="$userid"'
        : '${Constants.url}/products.json?auth=$authToken';
    final url = Uri.parse(path);

    final favUrl =
        Uri.parse('${Constants.url}/favourites/$userid.json?auth=$authToken');
    try {
      http.Response reponse = await http.get(url);
      http.Response favresponse = await http.get(favUrl);

      var favData = jsonDecode(favresponse.body);

      Map<String, dynamic> fetchedProducts =
          jsonDecode(reponse.body) as Map<String, dynamic>;


      List<Product> loadedProducts = [];
      fetchedProducts.forEach((producdId, prodVal) {
        Product product = Product(
          id: producdId,
          description: prodVal['description'],
          imageUrl: prodVal['imageUrl'],
          price: prodVal['price'],
          title: prodVal['title'],
          isFavorite: favData == null ? false : favData[producdId] ?? false,
        );
        loadedProducts.insert(0, product);
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      debugPrint("Problem");
      debugPrint(error.toString());
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    try {
      final url =
          Uri.parse('${Constants.url}/products/$id.json?auth=$authToken');

      final prodIndex = _items.indexWhere((prod) => prod.id == id);
      if (prodIndex >= 0) {
        Map<String, dynamic> body = {
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        };

        http.Response response = await http.patch(url, body: json.encode(body));
        _items[prodIndex] = newProduct;
        notifyListeners();
      } else {
        print('...');
      }
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('${Constants.url}/products/$id.json?auth=$authToken');

    int productIndex = _items.indexWhere((product) => product.id == id);
    Product productCopy = _items[productIndex];

    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
    http.Response response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(productIndex, productCopy);
      notifyListeners();
      throw HandlingException(message: 'Failed Deleting The Product');
    }
  }
}
