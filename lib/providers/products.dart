import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shop_app_am/models/HttpException.dart';
import 'package:shop_app_am/providers/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  late String authToken;
  String? userId;

  void update(token, authUserId, previosItems) {
    authToken = token;
    userId = authUserId;
    _items = previosItems;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findProductByID(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndGetProduct([bool filterByUser = false]) async {
    var filter = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : "";
    final url = Uri.parse(
        'https://js-simple-6efdf.firebaseio.com/products.json?auth=$authToken&$filter');
    final urlFavorites = Uri.parse(
        'https://js-simple-6efdf.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final favoritesResponse = await http.get(urlFavorites);
      final dataFavorites = json.decode(favoritesResponse.body);
      print(dataFavorites);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data["error"] != null) {
        throw HttpException(data["error"]);
      }
      List<Product> list = [];
      data.forEach((prodId, prodDate) {
        list.add(Product(
            title: prodDate["title"],
            description: prodDate["description"],
            price: double.parse(prodDate["price"].toString()),
            isFavorite:
                dataFavorites == null ? false : dataFavorites[prodId] ?? false,
            imageUrl: prodDate["imageUrl"],
            id: prodId));
      });
      _items = list;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.parse(
          'js-simple-6efdf.firebaseio.com/products.json?auth=$authToken');
      var response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
    } catch (error) {
      print(error.toString());
      print(error);
      print("error");
      throw error;
    }

    notifyListeners();
  }

  Future<void> editProduct(Product product) async {
    final prodIndex = _items.indexWhere((element) => element.id == product.id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://js-simple-6efdf.firebaseio.com/products/${product.id}.json?auth=$authToken');
      try {
        await http.patch(url,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
            }));
        _items[prodIndex] = product;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteProduct(id) async {
    final url = Uri.parse(
        'https://js-simple-6efdf.firebaseio.com/products/$id.json?auth=$authToken');
    final existProductIndex = _items.indexWhere((element) => element.id == id);
    var existProduct = _items[existProductIndex];
    _items.removeWhere((element) => element.id == id);
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existProductIndex, existProduct);
      throw HttpException("Could delete product!");
    }
    notifyListeners();
  }
}
