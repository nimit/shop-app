import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import '../models/temp_product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);
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
  List<Product> get items {
    return [..._items];
    //Here, if we donot use the spread operator, dart will return a pointer to the original variable here... Insteead, we wanna return a copy of that original variable so that the original one doesn't get modified.
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String productId) {
    return _items.firstWhere((product) => product.id == productId);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://flutter-demo-7f8f0.firebaseio.com/products.json?auth=$authToken$filterString';
    try {
      final response = await http.get(url);
      final loadedData = json.decode(response.body) as Map<String, dynamic>;
      if (loadedData == null) return;
      if (loadedData.isEmpty) return _items = [];
      final favUrl =
          'https://flutter-demo-7f8f0.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      List<Product> loadedProducts = [];
      loadedData.forEach((id, data) {
        loadedProducts.add(
          Product(
            id: id,
            title: data['title'],
            description: data['description'],
            price: data['price'],
            imageUrl: data['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[id] ?? false,
          ),
        );
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> addProduct(TempProduct product, bool edit) async {
    String jsonBodyBuilder() {
      return json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'creatorId': userId,
      });
    }

    try {
      if (!edit) {
        final url =
            'https://flutter-demo-7f8f0.firebaseio.com/products.json?auth=$authToken';
        await http.post(
          url,
          body: jsonBodyBuilder(),
        );
        _items.add(product.toProduct());
      } else {
        final url =
            'https://flutter-demo-7f8f0.firebaseio.com/products/${product.id}.json?auth=$authToken';
        await http.patch(
          url,
          body: jsonBodyBuilder(),
        );
      }
      notifyListeners();
    } catch (error) {
      //This will print the error and overall solve the infinite spinner problem bcoz dart will think that the error is handled.
      print(error);
      throw error; //This will make sure that the error is not marked as handled and will throw it again so that we can catch it in the edit_product_screen to then display a UI message.
    }
  }

  void deleteProduct(String id) async {
    final url =
        'https://flutter-demo-7f8f0.firebaseio.com/products/$id.json?auth=$authToken';
    final productIndex = _items.indexWhere((product) => product.id == id);
    var product = _items[productIndex];
    _items.removeAt(productIndex);
    notifyListeners();
    //This is called optimistic updating.
    //All this is done because we do not want to wait for the execution of the http.delete() function to finish. We remove the element from the list already and then wait to catch an error (if any). If an error is found, it means that the deletion wasn't successful and we revert the _items list to the original state.
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      //If error occurs, i.e., status code is greater than 400, it will throw the exception and rollback delete operation.
      //This is needed here because the http.delete function doesn't throw an exception unlike the post/patch functions.
      _items.insert(productIndex, product);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    product = null;
  }
}
