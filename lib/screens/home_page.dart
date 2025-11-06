import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  bool _isFiltering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Stream<List<Item>> _getStream() {
    if (_searchQuery.isNotEmpty) {
      return _service.searchItems(_searchQuery);
    }
    if (_isFiltering && _minPrice != null && _maxPrice != null) {
      return _service.filterByPriceRange(_minPrice!, _maxPrice!);
    }
    return _service.getItemsStream();
  }

  void _applyFilter() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);

    if (minPrice != null && maxPrice != null && minPrice <= maxPrice) {
      setState(() {
        _minPrice = minPrice;
        _maxPrice = maxPrice;
        _isFiltering = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid price range')),
      );
    }
  }

  void _resetFilter() {
    setState(() {
      _minPrice = null;
      _maxPrice = null;
      _isFiltering = false;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  Future<void> _createOrUpdate([Item? item]) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        if (item != null) {
          _nameController.text = item.name;
          _priceController.text = item.price.toString();
        }

        return AlertDialog(
          title: Text(item == null ? 'Add Product' : 'Update Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _nameController.clear();
                _priceController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final price = double.tryParse(_priceController.text);
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                if (name.isEmpty || price == null || price <= 0) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Please enter valid data')),
                  );
                  return;
                }

                try {
                  if (item == null) {
                    await _service.addItem(
                      Item(
                        name: name,
                        quantity: 0, // Default quantity
                        price: price,
                        category: 'Other', // Default category
                      ),
                    );
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Product added successfully'),
                      ),
                    );
                  } else {
                    await _service.updateItem(
                      Item(
                        id: item.id,
                        name: name,
                        quantity: item.quantity,
                        price: price,
                        category: item.category,
                        createdAt: item.createdAt,
                      ),
                    );
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Product updated successfully'),
                      ),
                    );
                  }

                  _nameController.clear();
                  _priceController.clear();
                  navigator.pop();
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text(item == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String itemId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _service.deleteItem(itemId);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
            ),
            const SizedBox(height: 16),

            // Price Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text('Filter'),
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: _resetFilter, child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<List<Item>>(
                stream: _getStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // Schedule UI update on main thread
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Database Error: ${snapshot.error}'),
                          ),
                        );
                      }
                    });
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _createOrUpdate(snapshot.data![index]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteProduct(item.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
