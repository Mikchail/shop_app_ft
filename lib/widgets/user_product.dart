import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/product.dart';
import 'package:shop_app_am/providers/products.dart';
import 'package:shop_app_am/screens/edit_product_screen.dart';

class UserProducts extends StatelessWidget {
  final Product product;

  UserProducts(this.product);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,
                    arguments: product.id);
              },
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: ()  {
                showDialog<void>(
                  context: context,
                  // false = user must tap button, true = tap outside dialog
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: Text("Are you sure?"),
                      content: Text("Do you want to remove the item?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text("No")),
                        TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop(true);
                              try {
                                await Provider.of<ProductsProvider>(context, listen: false)
                                    .deleteProduct(product.id);
                              } catch(error) {
                                scaffold.showSnackBar(SnackBar(
                                  content: Text("Delete product Error!", textAlign: TextAlign.center,),
                                  duration: Duration(seconds: 2),
                                ));
                              }
                            },
                            child: Text("Yes")),
                      ],

                    );
                  },
                );

              },
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
