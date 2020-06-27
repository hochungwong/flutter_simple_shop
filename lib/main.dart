import 'package:flutter/material.dart';

import "package:provider/provider.dart";

import "screens/products_overview_screen.dart";
import "screens/product_detail_screen.dart";
import "screens/cart_screen.dart";
import "screens/orders_screen.dart";
import "screens/user_products_screen.dart";
import "screens/edit_product_screen.dart";
import "screens/auth_screen.dart";

import "providers/products.dart";
import "providers/cart.dart";
import "providers/order.dart";
import "providers/auth.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //provide one or more stores
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProvider(create: (ctx) => Products()),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProvider(create: (ctx) => Order())
        ],
        //child in Consumer builder is the set of static widgets that we don't want to rebuild even if the data
        child: Consumer<Auth>(
          builder: (ctx, authData, child) => MaterialApp(
            title: 'Simple Shop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
            ),
            home: ProductsOverviewScreen(),
            routes: {
              ProductsOverviewScreen.routeName: (ctx) =>
                  ProductsOverviewScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen()
            },
          ),
        ));
  }
}
