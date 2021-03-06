import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/products.dart';
import 'package:shop_app_am/widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showOnlyFavorites;
  ProductGrid(this.showOnlyFavorites);
  @override
  Widget build(BuildContext context) {
    final productsContext = Provider.of<ProductsProvider>(context);
    var products = productsContext.items;
    if (showOnlyFavorites) {
      products = productsContext.favoriteItems;
    }
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        key: Key("item$i"),
        value: products[i],
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
    );
  }
}
