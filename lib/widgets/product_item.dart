//Provides the widget to show a grid tile in the products overview screen.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  // final String id, title, imageUrl;
  // ProductItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<Product>(context);
    //When listen: true in Provider.of, it reruns the whole build method when data changes.
    //A performance improvement would be to only rebuild the dynamic widgets. We achieve that by using the consumer widget or splitting this main widget into different widgets. This would make a majority of the tree not a listener and only the really necessary part a listener.
    //Note: Consumer<> always listens for changes.
    final product = Provider.of<Product>(context, listen: false);
    // final cartData = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (_) => ProductDetailScreen(title),
            // ));
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.black),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            // child: Image.network(
            //   imageUrl,
            //   fit: BoxFit.cover,
            // ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (_, productx, child) => IconButton(
              //The child argument here is passed to the builder method but is actually a child you can define in the consumer method(Ex: label text). This child can be any widget which you don't want it to rebuild but also want to use it with the dynamic widget.
              icon: Icon(
                // label: child,
                productx.isFavorite ? Icons.favorite : Icons.favorite_outline,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () =>
                  productx.toggleFavorite(authData.token, authData.userId),
            ),
            // child: Text('Never Rebuilds/Changes'),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: Consumer<Cart>(
            builder: (_, cartData, __) => IconButton(
                icon: cartData.items.containsKey(product.id)
                    ? Icon(Icons.shopping_cart)
                    : Icon(Icons.shopping_cart_outlined),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  cartData.addItem(product.id, product.title, product.price);
                  //Scaffold.of(context) is us reaching out to the nearest Scaffold widget - in products overview screen bcoz it controls the entire page and has some special methods.
                  Scaffold.of(context).hideCurrentSnackBar();
                  //For when you repeatedly add items, previous snack bar needs to be hidden first.
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item added to cart!'),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () => cartData.removeSingleItem(product.id),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
