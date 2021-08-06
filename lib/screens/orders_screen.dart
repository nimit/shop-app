import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context, listen: false);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: orderData.setAndUpdateOrders(),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
            if (dataSnapshot.error != null)
              return Center(child: Text('An error occured.'));
            else
              return ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (_, i) => OrderItem(orderData.orders[i]),
              );
          }
        },
      ),
    );
  }
}
