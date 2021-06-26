import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/product.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";

  @override
  Widget build(BuildContext context) {
    var productId = ModalRoute.of(context)?.settings.arguments as String;
    var product = Provider.of<ProductProvider>(context, listen: false)
        .findProductByID(productId);
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
    );
  }
}
