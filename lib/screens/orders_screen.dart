import 'package:flutter/material.dart';
import 'package:flutter_simple_shop/widgets/app_drawer.dart';
import "package:provider/provider.dart";

import "../widgets/order_item.dart";

import "../widgets/app_drawer.dart";

import "../providers/order.dart" show Order;

class OrdersScreen extends StatefulWidget {
  static const String routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  Future<void> _refreshAndSetOrders() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Order>(context, listen: false).fetchAndSetOrders();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Your Orders"),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Order>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dateSnapshot) {
            if (dateSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dateSnapshot.error != null) {
                //error handling
                return Center(child: Text("Loaded orders error"));
              } else {
                //no error
                return RefreshIndicator(
                    onRefresh: () async => _refreshAndSetOrders(),
                    child: Consumer<Order>(
                      builder: (ctx, ordersData, child) => ListView.builder(
                        itemBuilder: (ctx, i) =>
                            OrderItem(ordersData.orders[i]),
                        itemCount: ordersData.orders.length,
                      ),
                    ));
              }
            }
          },
        ));
  }
}
