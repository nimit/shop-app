import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id, productId;
  CartItem(this.id, this.productId);
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    return Dismissible(
      onDismissed: (_) => cart.removeItem(productId),
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to remove this item from the cart?'),
          actions: [
            FlatButton(
              child: Text('No'),
              onPressed: () => Navigator.pop(ctx, false),
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: FittedBox(
                      child: Text('\$${cart.items[productId].price}'))),
            ),
            title: Text(cart.items[productId].title),
            subtitle: Text(
                'Total: \$${cart.items[productId].price * cart.items[productId].quantity}'),
            trailing: Text('${cart.items[productId].quantity} x'),
          ),
        ),
      ),
    );
  }
}
