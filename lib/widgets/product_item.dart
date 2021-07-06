import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/cart.dart';
import 'package:shop_app_am/providers/product.dart';
import 'package:shop_app_am/screens/product_details_screen.dart';

class ProductItem extends StatefulWidget {
  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  var _isLoadingFavoriteStatus = false;
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<CartProvider>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
            child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (context, exception, stackTrace) {
              return Center(child: Text('Your error widget...'),);
            },)),
        footer: GridTileBar(
          leading: _isLoadingFavoriteStatus ? CircularProgressIndicator(
            color: Theme.of(context).accentColor,
            strokeWidth: 2,
          ) : IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              setState(() {
                _isLoadingFavoriteStatus = true;
              });
              try {
                await product.toggleFavoriteStatus(product.id);
              } catch(error) {
                print(error);
              } finally {
                setState(() {
                  _isLoadingFavoriteStatus = false;
                });
              }
            },
            color:  Theme.of(context).accentColor,
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black.withOpacity(0.40),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Add item to cart!"),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: "UNDO",
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
