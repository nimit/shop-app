import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  //Returns the drawer list tile
  Widget drawerListTileBuilder(
    BuildContext context,
    IconData data,
    String title,
    String route,
  ) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(data),
      ),
      title: Text(title),
      onTap: () => Navigator.of(context).pushReplacementNamed(route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello There!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          drawerListTileBuilder(context, Icons.shop, 'Shop', '/'),
          // Divider(thickness: 1.2),
          Divider(thickness: 0.7),
          drawerListTileBuilder(
            context,
            Icons.payment,
            'My Orders',
            OrdersScreen.routeName,
          ),
          Divider(thickness: 0.7),
          drawerListTileBuilder(
            context,
            Icons.donut_large,
            // Icons.edit,
            'Manage Products',
            UserProductsScreen.routeName,
          ),
          Divider(thickness: 0.7),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.exit_to_app),
            ),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
