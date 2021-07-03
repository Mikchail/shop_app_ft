import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/cart.dart' show CartProvider;
import 'package:shop_app_am/providers/orders.dart';
import 'package:shop_app_am/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static final routeName = "/cart";

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
        appBar: AppBar(title: Text("Your cart")),
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.all(9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total", style: TextStyle(fontSize: 20)),
                    Spacer(),
                    Chip(
                      label: Text("\$${cart.totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    FlatButton(
                      onPressed: () {
                        if (cart.items.isEmpty) {
                          showDialog<void>(
                            context: context,
                            // false = user must tap button, true = tap outside dialog
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text("Warning!"),
                                content: Text("Need to add least one product!"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text("Ok")),
                                ],
                              );
                            },
                          );
                          return;
                        }
                        showDialog<void>(
                          context: context,
                          // false = user must tap button, true = tap outside dialog
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text("Are you sure!"),
                              content: Text("You can to add one more product!"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      Provider.of<OrdersProvider>(context,
                                              listen: false)
                                          .addOrder(cart.items.values.toList(),
                                              cart.totalAmount);
                                      cart.clear();
                                    },
                                    child: Text("Continue")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text("Cancel")),
                              ],
                            );
                          },
                        );
                      },
                      child: Text("Order Now"),
                      textColor: Theme.of(context).primaryColor,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    return CartItem(
                      cart.items.values.toList()[i].id,
                      cart.items.keys.toList()[i],
                      cart.items.values.toList()[i].title,
                      cart.items.values.toList()[i].price,
                      cart.items.values.toList()[i].quantity,
                    );
                  }),
            )
          ],
        ));
  }
}
