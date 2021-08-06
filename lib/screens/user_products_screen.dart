import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(
              context,
              EditProductScreen.routeName,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (_, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Consumer<Products>(builder: (_, productsData, __) {
                    return productsData.items.length == 0
                        ? Center(
                            child: Text('You have not added any products yet.'))
                        : ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (_, i) => Column(
                              children: [
                                UserProductItem(
                                  productsData.items[i].id,
                                  productsData.items[i].title,
                                  productsData.items[i].imageUrl,
                                  productsData.deleteProduct,
                                ),
                                Divider(thickness: 0.5),
                              ],
                            ),
                          );
                  }),
                ),
              ),
      ),
    );
  }
}
