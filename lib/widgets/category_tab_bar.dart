import 'package:flutter/material.dart';
import '../models/category.dart';

/// RestoSync Theme Colors
class _RestoSyncTheme {
  static const Color primary = Color(0xFF0072E3); // Blue
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF757575);
}

/// A stateful, horizontally scrollable category tab bar component.
///
/// Displays a list of categories as pill-shaped buttons with smooth transitions.
/// The active category is highlighted with the primary color and white text.
/// Perfect for filtering menu items or orders by category.
class CategoryTabBar extends StatefulWidget {
  /// List of categories to display as tabs.
  final List<Category> categories;

  /// Initially selected category. Defaults to first category if not provided.
  final Category? initialCategory;

  /// Callback function that fires when a category is selected.
  /// Passes the selected [Category] to the parent.
  final Function(Category) onCategoryChange;

  /// Whether to include an "All" option at the beginning.
  /// If true, an "All" category is automatically added.
  final bool includeAllOption;

  const CategoryTabBar({
    super.key,
    required this.categories,
    required this.onCategoryChange,
    this.initialCategory,
    this.includeAllOption = true,
  });

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar> {
  late Category _selectedCategory;
  late List<Category> _displayCategories;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupCategories();
  }

  /// Setup categories with "All" option if enabled.
  void _setupCategories() {
    _displayCategories = List.from(widget.categories);

    if (widget.includeAllOption) {
      _displayCategories.insert(
        0,
        Category(id: 'all', name: 'All'),
      );
    }

    _selectedCategory = widget.initialCategory ?? _displayCategories.first;
  }

  /// Handle category selection with smooth scroll to center selected item.
  void _selectCategory(Category category) {
    setState(() {
      _selectedCategory = category;
    });

    // Callback to parent
    widget.onCategoryChange(category);

    // Scroll to center the selected tab
    _scrollToSelectedTab();
  }

  /// Scroll horizontally to keep selected tab visible and centered.
  void _scrollToSelectedTab() {
    final index = _displayCategories.indexOf(_selectedCategory);
    if (index != -1) {
      _scrollController.animateTo(
        index * 120, // Approximate width of each tab
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: _displayCategories.map((category) {
            final isSelected = _selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => _selectCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _RestoSyncTheme.primary
                        : _RestoSyncTheme.lightGrey,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _RestoSyncTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : _RestoSyncTheme.darkGrey,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
