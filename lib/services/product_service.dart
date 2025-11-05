import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _products = FirebaseFirestore.instance.collection(
    'products',
  );

  Stream<QuerySnapshot> getProducts() => _products.orderBy('name').snapshots();

  Future<void> addProduct(String name, double price) async =>
      _products.add({'name': name, 'price': price});

  Future<void> updateProduct(String id, String name, double price) async =>
      _products.doc(id).update({'name': name, 'price': price});

  Future<void> deleteProduct(String id) async => _products.doc(id).delete();

  Stream<QuerySnapshot> searchProducts(String query) => _products
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThanOrEqualTo: '$query\uf8ff')
      .snapshots();

  Stream<QuerySnapshot> filterByPrice(double minPrice, double maxPrice) =>
      _products
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .snapshots();
}
