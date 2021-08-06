import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

//You can move OrderItem and CartItem in different files - in the models folder.
class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(this.id, this.amount, this.products, this.dateTime);
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> setAndUpdateOrders() async {
    final url =
        'https://flutter-demo-7f8f0.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final allOrderData = json.decode(response.body) as Map<String, dynamic>;
    if (allOrderData == null) return;
    List<OrderItem> loadedOrders = [];
    allOrderData.forEach((key, value) {
      List<CartItem> products = (value['products'] as List<dynamic>)
          .map(
            (ci) => CartItem(
              id: ci['id'],
              price: ci['price'],
              quantity: ci['quantity'],
              title: ci['title'],
            ),
          )
          .toList();
      loadedOrders.insert(
        0,
        OrderItem(
          key,
          value['amount'],
          products,
          DateTime.parse(value['dateTime']),
        ),
      );
    });
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // //.add() adds at the end of the list.. insert(0, ..) adds at the beginning of the list so more recent orders are at the top.
    // _orders.insert(
    //   0,
    //   OrderItem(DateTime.now().toString(), total, cartProducts, DateTime.now()),
    // );
    final url =
        'https://flutter-demo-7f8f0.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }),
      );
    } catch (error) {
      print(error);
    }
    notifyListeners();
  }
}
