import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";

  @override
  Widget build(BuildContext context) {
    var productId = ModalRoute.of(context)?.settings.arguments as String;
    var product = Provider.of<ProductsProvider>(context, listen: false)
        .findProductByID(productId);
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      // drawer: AppDrawer(),
      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            child: Image.network(product.imageUrl, fit: BoxFit.cover),
          ),
          SizedBox(
            height: 10,
          ),
          Text("\$${product.price}",
              style: TextStyle(color: Colors.grey, fontSize: 20)),
          SizedBox(
            height: 10,
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                product.description,
                textAlign: TextAlign.center,
                softWrap: true,
              )),
        ],
      ),
    );
  }
}
