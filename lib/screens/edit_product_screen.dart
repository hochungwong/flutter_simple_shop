import "package:flutter/material.dart";
import "../providers/product.dart";
import "../providers/products.dart";

import "package:provider/provider.dart";

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  //control input field focus
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();
  //store form state globally
  final _form = GlobalKey<FormState>();
  //updated product object;
  var _editedProduct =
      Product(id: null, title: "", price: 0, description: "", imageUrl: "");
  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  }; // for edit product, to load all the init values

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false).findById(
            productId); //loading the product we need from the list of the products
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          "imageUrl": "",
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //avoid memory leak
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      var _imageUrlValue = _imageUrlController.text;
      if ((!_imageUrlValue.startsWith("http") &&
          !_imageUrlValue.startsWith("https"))) {
//          (!_imageUrlValue.endsWith(".jpg") &&
//              !_imageUrlValue.endsWith(".jpeg") &&
//              !_imageUrlValue.endsWith(".png"))) {
        return;
      }
      //lost focus
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate(); //trigger validators
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      //id only exists when loaded an existing product
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        //add new products
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
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
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues["title"],
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please provide a title";
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: value,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      decoration: InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a price";
                        }
                        if (double.tryParse(value) == null) {
                          //parsing failed
                          return "Please enter a valid number";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a non-negative number";
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: double.parse(value),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a description";
                        }
                        if (value.length < 10 && value.length > 0) {
                          return "Should be at least 10 characters long";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: value,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          )),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter a Url")
                              : FittedBox(
                                  alignment: Alignment.center,
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: "Image Url"),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter an image URL";
                                }
                                if (!value.startsWith("http") ||
                                    !value.startsWith("https")) {
                                  return "Please enter a valid image URL";
                                }
//                          if (!value.endsWith(("png")) ||
//                              !value.endsWith("jpg") ||
//                              !value.endsWith("jpeg")) {
//                            return "Please enter a valid image format";
//                          }
                                return null;
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                    title: _editedProduct.title,
                                    price: _editedProduct.price,
                                    description: _editedProduct.description,
                                    imageUrl: value,
                                    id: _editedProduct.id,
                                    isFavorite: _editedProduct.isFavorite);
                              },
                              onFieldSubmitted: (_) {
                                _saveForm();
                              }),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
