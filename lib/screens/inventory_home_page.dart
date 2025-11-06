import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import 'add_edit_item_screen.dart';

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  double? _minPrice;
  double? _maxPrice;
  bool _isFiltering = false;

  // Dashboard data
  int _totalItems = 0;
  double _totalValue = 0.0;
  List<Item> _outOfStockItems = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await _firestoreService.getDashboardData();
      setState(() {
        _totalItems = data['totalItems'];
        _totalValue = data['totalValue'];
        _outOfStockItems = data['outOfStockItems'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  Stream<List<Item>> _getStream() {
    if (_searchQuery.isNotEmpty) {
      return _firestoreService.searchItems(_searchQuery);
    }
    if (_isFiltering && _minPrice != null && _maxPrice != null) {
      return _firestoreService.filterByPriceRange(_minPrice!, _maxPrice!);
    }
    if (_selectedCategory != 'All') {
      return _firestoreService.filterByCategory(_selectedCategory);
    }
    return _firestoreService.getItemsStream();
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
      _selectedCategory = 'All';
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await _firestoreService.deleteItem(itemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
        _loadDashboardData(); // Refresh dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  void _navigateToAddEdit([Item? item]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditItemScreen(item: item)),
    );

    if (result == true) {
      _loadDashboardData(); // Refresh dashboard after add/edit
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dashboard Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Total Items',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '$_totalItems',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Total Value',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '\$${_totalValue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Out of Stock',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${_outOfStockItems.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
            ),
            const SizedBox(height: 16),

            // Filters Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'All',
                              'Electronics',
                              'Clothing',
                              'Food',
                              'Books',
                              'Other',
                            ]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value ?? 'All'),
                  ),
                ),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _applyFilter,
                      child: const Text('Filter'),
                    ),
                    TextButton(
                      onPressed: _resetFilter,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Items List
            Expanded(
              child: StreamBuilder<List<Item>>(
                stream: _getStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items found',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantity: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Category: ${item.category}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _navigateToAddEdit(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteItem(item.id!),
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
        onPressed: () => _navigateToAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
