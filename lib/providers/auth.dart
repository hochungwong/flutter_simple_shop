import 'package:flutter/material.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  var _isAuth = false;

  Future<void> authenticate(String email, String password, String url) async {}

  Future<void> signUp(String email, String password) async {}

  Future<void> login(String email, String password) async {}

  void fakeLogin(String email, String password) {
    _isAuth = !_isAuth;
    notifyListeners();
  }

  bool get isAuth {
    return _isAuth;
  }

  String get token {}
}
