import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:shop_app_am/models/HttpException.dart';
import '../key.dart';

class AuthProvider with ChangeNotifier {
  late String _token;
  String? _userId;
  DateTime? _expiryDate;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null && _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
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
      /** int.parse(responseData["expiresIn"]) - not coming from firebase */
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(Duration(seconds: 3600));

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
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
}
