import "package:flutter/material.dart";
import 'package:flutter_simple_shop/screens/cart_screen.dart';
import "package:provider/provider.dart";
import "../screens/cart_screen.dart";
import '../providers/cart.dart';
import "../widgets/products_grid.dart";

import "../providers/products.dart";

import "../widgets/badge.dart";

import "../widgets/app_drawer.dart";

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = "/products-overview";
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
//    Future.delayed(Duration.zero).then((_) {
//      Provider.of<Products>(context).fetchAndSetProducts();
//    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _fetchAndSetProducts();
    super.didChangeDependencies();
  }

  Future<void> _fetchAndSetProducts() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts();
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("An error occured"),
                  content: Text("Something went wrong."),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Okay"),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SimpleShop"),
        actions: <Widget>[
          PopupMenuButton(
              onSelected: (FilterOptions selectedValue) {
                setState(() {
                  switch (selectedValue) {
                    case FilterOptions.All:
                      _showOnlyFavorites = false;
                      break;
                    case FilterOptions.Favorites:
                      _showOnlyFavorites = true;
                      break;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text("Only Favorites"),
                      value: FilterOptions.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text("All Products"),
                      value: FilterOptions.All,
                    )
                  ]),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              child: ch,
              value: cartData.itemsCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _fetchAndSetProducts,
              child: ProductsGrid(_showOnlyFavorites)),
    );
  }
}
