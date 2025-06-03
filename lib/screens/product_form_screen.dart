import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'package:go_router/go_router.dart';

class ProductFormScreen extends StatefulWidget {
  final String? id;

  const ProductFormScreen({Key? key, this.id}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _service = ProductService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  late Product _product;

  @override
  void initState() {
    super.initState();
    _imageController.addListener(() {
      setState(() {});
    });
    if (widget.id != null) {
      _isEditing = true;
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final products = await _service.fetchProducts();
      _product = products.firstWhere((p) => p.id == widget.id);
      _nameController.text = _product.name;
      _descriptionController.text = _product.description ?? '';
      _priceController.text = _product.price.toString();
      _imageController.text = _product.image;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final product = Product(
      id: widget.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      price: double.parse(_priceController.text),
      image: _imageController.text,
    );
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isEditing) {
        await _service.updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit mis à jour')),
        );
      } else {
        await _service.createProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit créé')),
        );
      }
      context.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
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
        title: Text(_isEditing ? 'Modifier un produit' : 'Ajouter un produit'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nom'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ requis'
                          : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Prix'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Champ requis';
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) return 'Prix invalide';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _imageController,
                      decoration: InputDecoration(labelText: 'URL de l’image'),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                    ),
                    SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: _imageController.text.isEmpty
                          ? Center(child: Text('Aperçu de l’image'))
                          : Image.network(
                        _imageController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Center(child: Text('URL invalide')),
                      ),
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isEditing ? 'Mettre à jour' : 'Créer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
