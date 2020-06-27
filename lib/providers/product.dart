import 'package:flutter/foundation.dart';
import "dart:convert";

import "../models/http_exception.dart";

import "package:http/http.dart" as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus() async {
    //optimistically handle fav status, similar to delete single product
    //store old data, revert it if app sends http request failed
    final oldFavStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = "https://simple-shop-d6592.firebaseio.com/products/$id.json";
    final response =
        await http.patch(url, body: json.encode({"isFavorite": isFavorite}));
    if (response.statusCode >= 400) {
      //revert
      _setFavValue(oldFavStatus);
      throw HttpException("Could not add to favorite");
    }
  }
}
