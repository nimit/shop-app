import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../models/temp_product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  bool _edit;
  var _isInit = true;
  var _isLoading = false;
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  //The imageUrl focus node is added so that we can load the image if the user taps anywhere(i.e., the textfield loses focus...)
  final _form = GlobalKey<FormState>();
  var _tempProduct = TempProduct(
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  String _isImgUrlValid(String url) {
    if (url.isEmpty) return 'Please provide an image URL.';
    if (!url.startsWith('http') && !url.startsWith('https'))
      return 'Please enter a valid URL.';
    if (!url.endsWith('.jpeg') &&
        !url.endsWith('jpg') &&
        !url.endsWith('.png') &&
        !url.endsWith('.gif'))
      return 'Please enter a valid image URL(.jpg/.jpeg/.png/.gif).';
    return null;
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_isImgUrlValid(_imageUrlController.text) ==
              'Please provide an image URL.' ||
          _isImgUrlValid(_imageUrlController.text) == null)
        setState(() {});
      else
        return;
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      _edit = productId != null;
      if (_edit) {
        final _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _tempProduct = TempProduct(
          id: _editProduct.id,
          title: _editProduct.title,
          description: _editProduct.description,
          price: _editProduct.price,
          imageUrl: _editProduct.imageUrl,
          isFavorite: _editProduct.isFavorite,
        );
        _imageUrlController.text = _tempProduct.imageUrl;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(() => _updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _saveForm() async {
    var _isValid = _form.currentState.validate();
    if (!_isValid) return;
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Products>(context, listen: false)
          .addProduct(_tempProduct, _edit);
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error Occured!'),
          content: Text('Something went wrong.'),
          actions: [
            FlatButton(
              child: Text('Okay'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    } finally {
      //Runs no matter what
      _isLoading = false;
      Navigator.of(context).pop();
      // imageUrl ex: https://www.opticolour.co.uk/wp-content/uploads/product_images/abstract-fish-ab121-printed-glass-splashback.jpg
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_edit ? 'Edit Product' : 'New Product'),
        actions: [IconButton(icon: Icon(Icons.done), onPressed: _saveForm)],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _edit ? _tempProduct.title : '',
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value.isEmpty) return 'Please provide a title.';
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        onSaved: (newValue) => _tempProduct.title = newValue,
                      ),
                      TextFormField(
                        initialValue:
                            _edit ? _tempProduct.price.toString() : '',
                        decoration: InputDecoration(labelText: 'Price'),
                        validator: (value) {
                          if (value.isEmpty) return 'Please provide a price.';
                          if (double.tryParse(value) == null)
                            return 'Please enter a valid number.';
                          if (double.parse(value) < 0)
                            return 'Please enter a price greater than zero';
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_descFocusNode),
                        onSaved: (newValue) =>
                            _tempProduct.price = double.parse(newValue),
                      ),
                      TextFormField(
                        initialValue: _edit ? _tempProduct.description : '',
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 2,
                        focusNode: _descFocusNode,
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please provide a description.';
                          if (value.length < 10)
                            return 'Description should be atleast 10 characters long';
                          return null;
                        },
                        keyboardType: TextInputType.multiline,
                        onSaved: (newValue) =>
                            _tempProduct.description = newValue,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 15, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              shape: BoxShape.circle,
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? FittedBox(
                                    child: Text('Enter a URL'),
                                    fit: BoxFit.scaleDown,
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              validator: (value) {
                                return _isImgUrlValid(value);
                              },
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              onEditingComplete: () => setState(() {}),
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) => _saveForm(),
                              onSaved: (newValue) =>
                                  _tempProduct.imageUrl = newValue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
