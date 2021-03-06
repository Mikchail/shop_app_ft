import 'package:flutter/material.dart';
import 'package:shop_app_am/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  late String _authtoken;
  late String _userId;
  void update(token, authUserId, previosOrders) {
    _authtoken = token;
    _userId = authUserId;
    _orders = previosOrders;
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://js-simple-6efdf.firebaseio.com/orders/$_userId.json?auth=$_authtoken');
    try {
      var response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'products': cartProducts.map((cart) => cart.toJson()).toList(),
          'dateTime': DateTime.now().toString(),
        }),
      );
      if (response.statusCode >= 400) {
        throw ErrorHint("Error");
      }
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: total,
              products: cartProducts,
              dateTime: DateTime.now()));
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  List<CartItem> getCartItem(List<dynamic> jsonList) {
    List<CartItem> list = [];
    jsonList.forEach((cartData) {
      list.add(CartItem(
          id: cartData["id"],
          title: cartData["title"],
          price: double.parse(cartData["price"].toString()),
          quantity: cartData["quantity"]));
    });
    return list;
  }

  Future<void> fetchAndGetOrders() async {
    final url = Uri.parse(
        'https://js-simple-6efdf.firebaseio.com/orders/$_userId.json?auth=$_authtoken');
    try {
      var response = await http.get(url);
      final orders = json.decode(response.body) as Map<String, dynamic>;
      List<OrderItem> list = [];
      orders.forEach((orderId, orderData) {
        list.add(OrderItem(
            id: orderId,
            amount: double.parse(orderData["amount"].toString()),
            products: getCartItem(orderData["products"]),
            dateTime: DateTime.parse(orderData["dateTime"])));
      });
      _orders = list;
    } catch (error) {
      print(error);
    }
    notifyListeners();
  }
}
