import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  static const _apiKey = 'AIzaSyA5TNmBxzbe1kflC-n-jNRtzP0jEY_8wXw';

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String urlSegment, String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$_apiKey';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['error'] != null) throw HttpException(data['error']['message']);
      _token = data['idToken'];
      _expiryDate =
          DateTime.now().add(Duration(seconds: int.parse(data['expiresIn'])));
      _userId = data['localId'];
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      //Here, we use json.encode because we want to store multiple key value pairs and json is always used as a string format.
      prefs.setString('userData', userData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate('signUp', email, password);
  }

  Future<void> login(String email, String password) async {
    return _authenticate('signInWithPassword', email, password);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final userData = json.decode(prefs.getString('userData'));
    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return false;
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();
    final sessionTime = _expiryDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: sessionTime), logout);
  }
}
