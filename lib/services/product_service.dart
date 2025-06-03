import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String baseUrl = 'https://eemi-39b84a24258a.herokuapp.com/products';

  Future<List<Product>> fetchProducts({String? search}) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: search != null ? {'search': search} : null);
    final response = await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['rows'] ?? [];
        return data.map((item) => Product.fromJson(item)).toList();
      } catch (e) {
        throw Exception('Erreur lors du décodage de la réponse JSON: $e');
      }
    } else {
      throw Exception('Erreur lors du chargement des produits: ${response.statusCode}');
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création du produit');
    }
  }

  Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour du produit');
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression du produit');
    }
  }
}
