import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart; //Only import Cart and not CartItem
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 4),
                  OrderButton(cart),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, i) => CartItem(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
              ),
              itemCount: cart.itemCount,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  OrderButton(this.cart);
  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      textColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(),
                  widget.cart.totalAmount,
                );
              } catch (error) {
                print(error);
              }
              setState(() => _isLoading = false);
              widget.cart.clear();
            },
    );
  }
}
