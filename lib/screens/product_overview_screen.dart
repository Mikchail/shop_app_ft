import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/cart.dart';
import 'package:shop_app_am/providers/products.dart';
import 'package:shop_app_am/screens/cart_screen.dart';
import 'package:shop_app_am/widgets/app_drawer.dart';
import 'package:shop_app_am/widgets/badge.dart';
import 'package:shop_app_am/widgets/product_grid.dart';

enum FilterOptions { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = false;
  var _isError = false;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context, listen: false)
          .fetchAndGetProduct()
          .then((_) => setState(() {
                _isLoading = false;
              }))
          .catchError((_) => setState(() {
                _isError = true;
              }));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text("Product"),
          actions: [
            PopupMenuButton(
                onSelected: (FilterOptions selectedValue) {
                  setState(() {
                    switch (selectedValue) {
                      case FilterOptions.Favorites:
                        _showOnlyFavorites = true;
                        break;
                      case FilterOptions.All:
                        _showOnlyFavorites = false;
                    }
                  });
                },
                icon: Icon(Icons.more_vert),
                itemBuilder: (ctx) => [
                      PopupMenuItem(
                          child: Text(
                            "Only favorite",
                          ),
                          value: FilterOptions.Favorites),
                      PopupMenuItem(
                          child: Text(
                            "Show all",
                          ),
                          value: FilterOptions.All)
                    ]),
            Consumer<CartProvider>(
              builder: (_, cart, ch) {
                return Badge(
                    child: ch ?? Text("Error"),
                    value: cart.itemCount.toString());
              },
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
            )
          ],
        ),
        body: _isError
            ? Text("Error")
            : _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ProductGrid(_showOnlyFavorites));
  }
}
