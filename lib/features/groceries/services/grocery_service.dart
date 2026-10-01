import '../models/grocery_product_model.dart';

class GroceryService {
  // Sample grocery products
  final List<GroceryProduct> _products = [
    const GroceryProduct(
      id: '1',
      name: 'Fresh Milk',
      category: 'Dairy',
      description: 'Fresh full cream milk - 1L',
      price: 550.00,
      discountPrice: 500.00,
      imageUrl: '',
      stock: 20,
    ),
    const GroceryProduct(
      id: '2',
      name: 'Carrot',
      category: 'Vegetables',
      description: 'Fresh carrots - 1kg',
      price: 650.00,
      imageUrl: '',
      stock: 30,
    ),
    const GroceryProduct(
      id: '3',
      name: 'Chicken',
      category: 'Meat',
      description: 'Fresh chicken - 1kg',
      price: 1450.00,
      discountPrice: 1350.00,
      imageUrl: '',
      stock: 15,
    ),
    const GroceryProduct(
      id: '4',
      name: 'Bread',
      category: 'Bakery',
      description: 'Fresh sliced bread',
      price: 250.00,
      imageUrl: '',
      stock: 25,
    ),
    const GroceryProduct(
      id: '5',
      name: 'Orange Juice',
      category: 'Beverages',
      description: 'Orange juice - 1L',
      price: 850.00,
      imageUrl: '',
      stock: 12,
    ),
    const GroceryProduct(
      id: '6',
      name: 'Apple',
      category: 'Fruits',
      description: 'Fresh apples - 1kg',
      price: 1200.00,
      discountPrice: 1100.00,
      imageUrl: '',
      stock: 18,
    ),
  ];

  List<GroceryProduct> getProducts() {
    return List.unmodifiable(_products);
  }

  List<String> getCategories() {
    return [
      'All',
      'Fruits',
      'Vegetables',
      'Dairy',
      'Meat',
      'Bakery',
      'Beverages',
    ];
  }

  List<GroceryProduct> getProductsByCategory(String category) {
    if (category == 'All') {
      return getProducts();
    }

    return _products
        .where((product) => product.category == category)
        .toList();
  }

  List<GroceryProduct> searchProducts(String query) {
    final searchText = query.toLowerCase().trim();

    return _products.where((product) {
      return product.name.toLowerCase().contains(searchText) ||
          product.category.toLowerCase().contains(searchText);
    }).toList();
  }
}