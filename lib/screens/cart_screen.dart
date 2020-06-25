import "package:flutter/material.dart";

import "package:provider/provider.dart";
import "../providers/cart.dart" show Cart;

import '../widgets/cart_item.dart';
import "../providers/order.dart";

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color:
                              Theme.of(context).primaryTextTheme.title.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    child: Text("Order Now"),
                    onPressed: () {
                      Provider.of<Order>(context, listen: false).addOrder(
                          cart.cartItems.values.toList(), cart.totalAmount);
                      cart.clearCart();
                    },
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) => CartItem(
                  cart.cartItems.values.toList()[index].id,
                  cart.cartItems.keys.toList()[index],
                  cart.cartItems.values.toList()[index].price,
                  cart.cartItems.values.toList()[index].quantity,
                  cart.cartItems.values.toList()[index].title),
              itemCount: cart.cartItems.length,
            ),
          )
        ],
      ),
    );
  }
}
