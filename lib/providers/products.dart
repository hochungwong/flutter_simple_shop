import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_shop/models/http_exception.dart';

import "package:http/http.dart" as http;

import 'product.dart';

import "../models/http_exception.dart";

class Products with ChangeNotifier {
  final String _authToken;
  final String _userId;
  List<Product> _items = [];

  Products(this._authToken, this._userId, this._items);

  var _showFavOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    var url =
        'https://simple-shop-d6592.firebaseio.com/products.json?auth=$_authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        _items = [];
        notifyListeners();
        return;
      }
      url =
          "https://simple-shop-d6592.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken";
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
            id: productId,
            title: productData["title"],
            description: productData["description"],
            price: productData["price"],
            isFavorite: favoriteData == null
                ? false
                : favoriteData[productId] ??
                    false, //'??' double question marks check if the productId is null
            imageUrl: productData["imageUrl"]));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://simple-shop-d6592.firebaseio.com/products.json?auth=$_authToken";
    try {
      final response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
            "creatorId": _userId
          }));
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)["name"]);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url =
          "https://simple-shop-d6592.firebaseio.com/products/$id.json?auth=$_authToken";
      final response = await http.patch(url,
          body: json.encode({
            "title": newProduct.title,
            "description": newProduct.description,
            "imageUrl": newProduct.imageUrl,
            "price": newProduct.price
          }));
      if (response.statusCode >= 400) {
        throw HttpException("Could not update product");
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("no existing product find, couldn't be updated");
    }
  }

  Future<void> deleteProduct(String id) async {
    //delete product and handle state optimistically
    final url =
        "https://simple-shop-d6592.firebaseio.com/products/$id.json?auth=$_authToken";
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex); //remove from memory
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners(); //re-add the product if failed
      throw HttpException("Could not delete product");
    }

    existingProduct = null;
  }
}
