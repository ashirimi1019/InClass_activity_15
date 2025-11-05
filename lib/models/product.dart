import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String name;
  double price;

  Product({required this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price};
  }

  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }
}
