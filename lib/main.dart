import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/auth.dart';
import 'package:shop_app_am/providers/cart.dart';
import 'package:shop_app_am/providers/orders.dart';
import 'package:shop_app_am/providers/products.dart';
import 'package:shop_app_am/screens/auth_screen.dart';
import 'package:shop_app_am/screens/cart_screen.dart';
import 'package:shop_app_am/screens/edit_product_screen.dart';
import 'package:shop_app_am/screens/orders_screen.dart';
import 'package:shop_app_am/screens/product_details_screen.dart';
import 'package:shop_app_am/screens/product_overview_screen.dart';
import 'package:shop_app_am/screens/splash_screen.dart';
import 'package:shop_app_am/screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
              create: (ctx) => OrdersProvider(),
              update: (ctx, auth, previosProducts) => OrdersProvider()
                ..update(
                    auth.token,
                    auth.userId,
                    previosProducts?.orders == null
                        ? []
                        : previosProducts?.orders)),
          ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
              create: (ctx) => ProductsProvider(),
              update: (ctx, auth, previosProducts) => ProductsProvider()
                ..update(
                    auth.token ?? "",
                    auth.userId,
                    previosProducts?.items == null
                        ? []
                        : previosProducts?.items)),
        ],
        child: Consumer<AuthProvider>(
          builder: (context, authData, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
              ),
              home: authData.isAuth
                  ? ProductOverviewScreen()
                  : FutureBuilder(
                      future: authData.tryToLogin(),
                      builder: (ctx, authDataSnapshot) =>
                          authDataSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen()),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen(),
              },
            );
          },
        ));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
