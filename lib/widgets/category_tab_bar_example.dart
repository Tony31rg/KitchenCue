import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/menu_item_card.dart';

/// Example parent screen demonstrating how to use CategoryTabBar
/// with state management to filter menu items by category.
class MenuCategoryScreen extends StatefulWidget {
  const MenuCategoryScreen({super.key});

  @override
  State<MenuCategoryScreen> createState() => _MenuCategoryScreenState();
}

class _MenuCategoryScreenState extends State<MenuCategoryScreen> {
  /// Mock categories for the restaurant menu
  late List<Category> _categories;

  /// Mock menu items with category associations
  late Map<String, List<MenuItem>> _menuItemsByCategory;

  /// Currently selected category
  late Category _selectedCategory;

  /// Currently displayed items (filtered by category)
  late List<MenuItem> _displayedItems;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  /// Initialize mock categories and menu items
  void _initializeMockData() {
    // Define categories
    _categories = [
      Category(id: 'starters', name: 'Starters'),
      Category(id: 'main_course', name: 'Main Course'),
      Category(id: 'desserts', name: 'Desserts'),
      Category(id: 'beverages', name: 'Beverages'),
      Category(id: 'specials', name: 'Specials'),
    ];

    // Define menu items by category
    _menuItemsByCategory = {
      'all': _getAllMenuItems(),
      'starters': [
        MenuItem(
          id: '1',
          name: 'Garlic Bread',
          price: 5.99,
          stockCount: 12,
          imageUrl: 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=300',
        ),
        MenuItem(
          id: '2',
          name: 'Bruschetta',
          price: 6.99,
          stockCount: 8,
          imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=300',
        ),
      ],
      'main_course': [
        MenuItem(
          id: '3',
          name: 'Grilled Salmon',
          price: 18.99,
          stockCount: 5,
          imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
        ),
        MenuItem(
          id: '4',
          name: 'Italian Pasta',
          price: 14.99,
          stockCount: 10,
          imageUrl: 'https://images.unsplash.com/photo-1673438494536-808faa3c823d?w=300',
        ),
        MenuItem(
          id: '5',
          name: 'Steak Ribeye',
          price: 24.99,
          stockCount: 3,
          imageUrl: 'https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=300',
        ),
      ],
      'desserts': [
        MenuItem(
          id: '6',
          name: 'Chocolate Lava Cake',
          price: 7.99,
          stockCount: 15,
          imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=300',
        ),
        MenuItem(
          id: '7',
          name: 'Tiramisu',
          price: 6.99,
          stockCount: 0,
          imageUrl: 'https://images.unsplash.com/photo-1571115764595-644a007f0a99?w=300',
        ),
      ],
      'beverages': [
        MenuItem(
          id: '8',
          name: 'Fresh Orange Juice',
          price: 4.99,
          stockCount: 20,
          imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=300',
        ),
        MenuItem(
          id: '9',
          name: 'Iced Coffee',
          price: 5.99,
          stockCount: 25,
          imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=300',
        ),
      ],
      'specials': [
        MenuItem(
          id: '10',
          name: 'Chef\'s Special Lava Cake',
          price: 12.99,
          stockCount: 7,
          imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=300',
        ),
        MenuItem(
          id: '11',
          name: 'Seasonal Risotto',
          price: 16.99,
          stockCount: 4,
          imageUrl: 'https://images.unsplash.com/photo-1574080686778-4c1dcc53d7d7?w=300',
        ),
      ],
    };

    // Set initial category and items
    _selectedCategory = Category(id: 'all', name: 'All');
    _displayedItems = _menuItemsByCategory['all'] ?? [];
  }

  /// Get all menu items across all categories
  List<MenuItem> _getAllMenuItems() {
    List<MenuItem> allItems = [];
    _menuItemsByCategory.forEach((key, items) {
      if (key != 'all') {
        allItems.addAll(items);
      }
    });
    return allItems;
  }

  /// Handle category selection and update displayed items
  void _onCategoryChange(Category selectedCategory) {
    setState(() {
      _selectedCategory = selectedCategory;

      // Filter items based on selected category
      if (selectedCategory.id == 'all') {
        _displayedItems = _getAllMenuItems();
      } else {
        _displayedItems =
            _menuItemsByCategory[selectedCategory.id] ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KitchenCue Menu'),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Category Tab Bar
          CategoryTabBar(
            categories: _categories,
            initialCategory: _categories.first,
            onCategoryChange: _onCategoryChange,
            includeAllOption: true,
          ),
          // Menu Items Grid
          Expanded(
            child: _displayedItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_food,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items in ${_selectedCategory.name}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _displayedItems.length,
                    itemBuilder: (context, index) {
                      return MenuItemCard(
                        menuItem: _displayedItems[index],
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selected: ${_displayedItems[index].name}',
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
    );
  }
}
