import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/products.dart';
import 'package:shop_app_am/screens/edit_product_screen.dart';
import 'package:shop_app_am/widgets/app_drawer.dart';
import 'package:shop_app_am/widgets/user_product.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/users-products";

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductsProvider>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Your products"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
            itemCount: products.items.length,
            itemBuilder: (c, i) => Column(
                  children: [UserProducts(products.items[i]), Divider()],
                )),
      ),
    );
  }
}
