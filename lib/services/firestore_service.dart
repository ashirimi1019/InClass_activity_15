import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final CollectionReference _items = FirebaseFirestore.instance.collection(
    'items',
  );

  // Add new item
  Future<void> addItem(Item item) async {
    await _items.add(item.toMap());
  }

  // Real-time item stream
  Stream<List<Item>> getItemsStream() {
    return _items
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Item.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // Update item
  Future<void> updateItem(Item item) async {
    if (item.id != null) {
      await _items.doc(item.id).update(item.toMap());
    }
  }

  // Delete item
  Future<void> deleteItem(String id) async {
    await _items.doc(id).delete();
  }

  // Search items by name (case-insensitive)
  Stream<List<Item>> searchItems(String query) {
    if (query.isEmpty) {
      return getItemsStream();
    }

    return _items
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Item.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // Filter by category
  Stream<List<Item>> filterByCategory(String category) {
    if (category.isEmpty || category == 'All') {
      return getItemsStream();
    }

    return _items
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Item.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // Filter by price range
  Stream<List<Item>> filterByPriceRange(double minPrice, double maxPrice) {
    return _items
        .where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice)
        .orderBy('price')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Item.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    final snapshot = await _items.get();
    final items = snapshot.docs
        .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    final totalItems = items.length;
    final totalValue = items.fold<double>(
      0.0,
      (total, item) => total + (item.quantity * item.price),
    );
    final outOfStockItems = items.where((item) => item.quantity == 0).toList();

    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'outOfStockItems': outOfStockItems,
    };
  }
}
