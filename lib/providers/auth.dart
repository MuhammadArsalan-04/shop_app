import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/providers/HandlingException.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _tokenExpiryDate;

  Future<void> authentication(
      String email, String password, String apiWay) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$apiWay?key=AIzaSyAgClz2DkhKeVvLLbvE9amZyqGGO2EtqN4');

    try {
      http.Response response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      final extractedData = jsonDecode(response.body);

      if (extractedData['error'] != null) {
        throw HandlingException(message: extractedData['error']['message']);
      }

      _token = extractedData['idToken'];
      _tokenExpiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(extractedData['expiresIn'])));
      _userId = extractedData['localId'];
    } on HandlingException catch (error) {
      throw error;
    }

    notifyListeners();

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> userData = {
      'token': _token!,
      'expiryDate': _tokenExpiryDate!.toIso8601String(),
      'userid': _userId!,
    };
    _prefs.setString(
      'userData',
      jsonEncode(userData),
    );
  }

  Future<bool> getDetails() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    String _prefsData = _prefs.getString('userData')!;

    final userData = jsonDecode(_prefsData);

    if (userData['token'] == null &&
        userData['expiryDate'] == null &&
        userData['userid'] == null) {
      return false;
    }

    final expiryDate = DateTime.parse(userData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = userData['token'];
    _tokenExpiryDate = DateTime.parse(userData['expiryDate']);
    _userId = userData['userid'];

    notifyListeners();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    await authentication(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    await authentication(email, password, 'signInWithPassword');
  }

  // what is sync* , async & async*
  bool get isAuthenticated {
    if (token == null) {
      return false;
    }
    return true;
  }

  String? get token {
    if (_tokenExpiryDate != null &&
        _tokenExpiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }
    return null;
  }

  String? get userID {
    if (_userId != null) {
      return _userId!;
    }
    return null;
  }

  void logout() {
    _token = null;
    _userId = null;

    resetUserData().then((_) {
      notifyListeners();
    });
  }

  Future<void> resetUserData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.setString(
        'userData',
        json.encode({
          'token': null,
          'expiryDate': null,
          'userid': null,
        }));
  }
}
