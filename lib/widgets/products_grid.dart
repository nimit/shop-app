//Provides the main grid in the products_overview_screen. It is in a separate widget cause it uses provider and not splitting it would cause the whole screen(scaffold and appbar) along with this widget to reload on changes to the Products provider.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavoritesOnly;
  ProductsGrid(this.showFavoritesOnly);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showFavoritesOnly ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ChangeNotifierProvider.value(
        // create: (_) => products[i], //Since, we do not instantiate the product class here and use the existing object stored in the list of products, the .value() constructor is preferred.
        //Also, this .value() special constructor class should always be used when working with lists/grids because of how flutter only just changes the data in a widget(recycles it) and doesn't rebuild the whole widget causing problems when the widget is scrollable.
        value: products[i],
        child: ProductItem(),
      ),
    );
  }
}
