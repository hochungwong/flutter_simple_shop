import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/product.dart";
import "../providers/cart.dart";
import "../providers/auth.dart";

import "../screens/product_detail_screen.dart";

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context,
        listen: false); //only want to dispatch action, not to re-render
    final authData = Provider.of<Auth>(context, listen: false);

    final scaffold = Scaffold.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: Consumer<Product>(
          //only every single product grid is listening data change
          builder: (ctx, product, _) => GridTileBar(
            backgroundColor: Colors.black38,
            leading: IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () async {
                try {
                  await product.toggleFavoriteStatus(
                      authData.token, authData.userId);
                } catch (error) {
                  scaffold.showSnackBar(SnackBar(
                    content: Text("Add to / Remove off Favorite failed"),
                  ));
                }
              },
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                Scaffold.of(context).hideCurrentSnackBar(); //hide the snackbar
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Added item to cart",
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    )));
              },
            ),
          ),
        ),
      ),
    );
  }
}
