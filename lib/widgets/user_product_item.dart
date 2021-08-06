import 'package:flutter/material.dart';

import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final Function deleteHandler;
  UserProductItem(this.id, this.title, this.imageUrl, this.deleteHandler);
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(
                context,
                EditProductScreen.routeName,
                arguments: id,
              ),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: () async {
                try {
                  await deleteHandler(id);
                } catch (error) {
                  print(error);
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Deleting Failed!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
