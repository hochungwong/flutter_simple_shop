import 'package:flutter/material.dart';
import 'package:flutter_simple_shop/widgets/app_drawer.dart';
import "package:provider/provider.dart";

import "../widgets/order_item.dart";

import "../widgets/app_drawer.dart";

import "../providers/order.dart" show Order;

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";
  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
        itemCount: ordersData.orders.length,
      ),
    );
  }
}
