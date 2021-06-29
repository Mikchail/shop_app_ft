import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/widgets/app_drawer.dart';

import '../providers/orders.dart' show OrdersProvider;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrdersProvider>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: ListView.builder(
        itemCount: orderData.orders.length,
        itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
      ),
    );
  }
}
