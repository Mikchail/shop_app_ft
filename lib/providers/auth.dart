import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_am/models/HttpException.dart';
import '../key.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<bool> tryToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.containsKey("userData"))) {
      return false;
    }
    final userData =
        json.decode(prefs.getString("userData")!) as Map<String, dynamic>;
    _token = userData["token"] as String;
    _userId = userData["userId"] as String;
    _expiryDate = DateTime.parse(userData["expiryDate"] as String);
    autoLogout();
    return true;
  }

  Future<void> _authentication(email, password, urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$firebaseKey");
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      /** int.parse(responseData["expiresIn"]) - not coming from firebase */
      _expiryDate = DateTime.now().add(Duration(seconds: 3600));
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate!.toIso8601String(),
      });
      prefs.setString("userData", userData);
      autoLogout();
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  Future<void> singUp(email, password) async {
    return _authentication(email, password, "signUp");
  }

  Future<void> singIn(email, password) async {
    return _authentication(email, password, "signInWithPassword");
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final expiryDate = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryDate), logout);
  }
}
