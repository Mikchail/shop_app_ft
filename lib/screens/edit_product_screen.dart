import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_am/providers/product.dart';
import 'package:shop_app_am/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _editProduct = Product(
      id: "null",
      title: "title",
      description: "description",
      price: 0,
      imageUrl: "");

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  var _isInit = true;
  var _mapProducts = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        _editProduct = Provider.of<ProductsProvider>(context)
            .findProductByID(productId as String);
        _mapProducts = {
          "title": _editProduct.title,
          "description": _editProduct.description,
          "price": _editProduct.price.toString(),
          "imageUrl": "",
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _form.currentState?.save();
    try {
      if (_editProduct.id == "null") {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editProduct);
      } else {
        await Provider.of<ProductsProvider>(context, listen: false)
            .editProduct(_editProduct);
      }

      Navigator.of(context).pop();
    } catch (error) {
     await showDialog<void>(
        context: context,
        // false = user must tap button, true = tap outside dialog
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Warning!"),
            content: Text("$error"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Ok")),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Product"),
          actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.add))],
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
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        initialValue: _mapProducts["title"],
                        decoration: InputDecoration(labelText: "Title"),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (val) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: val!,
                              description: _editProduct.description,
                              price: _editProduct.price,
                              imageUrl: _editProduct.imageUrl);
                        },
                      ),
                      TextFormField(
                        initialValue: _mapProducts["price"],
                        decoration: InputDecoration(labelText: "Price"),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero.';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: _editProduct.title,
                              description: _editProduct.description,
                              price: double.parse(val!),
                              imageUrl: _editProduct.imageUrl);
                        },
                      ),
                      TextFormField(
                        initialValue: _mapProducts["description"],
                        decoration: InputDecoration(labelText: "Description"),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description.';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 characters long.';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: _editProduct.title,
                              description: val!,
                              price: _editProduct.price,
                              imageUrl: _editProduct.imageUrl);
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(top: 8, right: 15),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? Text("Enter url")
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(labelText: "Url"),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an image URL.';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid URL.';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please enter a valid image URL.';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                _editProduct = Product(
                                    id: _editProduct.id,
                                    title: _editProduct.title,
                                    description: _editProduct.description,
                                    price: _editProduct.price,
                                    imageUrl: val!);
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ));
  }
}
