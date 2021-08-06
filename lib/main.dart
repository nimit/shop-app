import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './widgets/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //We had to set up this provider here because we want to access its contents in both the products_overview_screen and the product_detail_screen. So, the parent containing both these is the MaterialApp in main.dart. Hence, this provider is set up here.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          //This is used when a provider itself is dependent on another provider.
          //Upto 6 such dependencies can be declared using different provider methods(ChangeNotifierProxyProvider2, ChangeNotifierProxyProvider3, etc)
          create: null,
          update: (_, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
          //We pass in the previous products' items bcoz we do not want to lose that data when the class is updated/instantiated again.
        ),
        ChangeNotifierProvider(
          //This makes a provider of the Products class. Any changes there will NOT result in the rebuild of the entire MaterialApp. It will only result in the rebuilding of the listeners of the provider, i.e., only the widgets that are interested in the data.
          create: (_) => Cart(),
          // value: Cart(), //This is only used when ChangeNotifierProvider is used with the .value() constructor. It is better to use the create(builder) method when instantiating a class.
          //Summary: Use the .value in lists/grids/when using an existing object(without instantiating). Use the create method otherwise.
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (_, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (_, auth, __) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            textTheme: TextTheme(),
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (_, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                  //If the autologin function is executing, it will show the splash screen. After execution, it will show the auth screen or the products overview screen. If it was successful, the app will rebuild bcoz of the notify listeners method we call in the autologin function and it will automatically be able to load the products overview screen bcoz then the isAuth variable will be true.
                ),
          routes: {
            // '/': (_) => AuthScreen(),
            ProductDetailScreen.routeName: (_) => ProductDetailScreen(),
            CartScreen.routeName: (_) => CartScreen(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            UserProductsScreen.routeName: (_) => UserProductsScreen(),
            EditProductScreen.routeName: (_) => EditProductScreen(),
            // AuthScreen.routeName: (_) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
