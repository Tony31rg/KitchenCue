import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../services/state_management/global_state.dart';
import 'dialog_field.dart';

class AddMenuItemDialog extends StatefulWidget {
  const AddMenuItemDialog({
    super.key,
    required this.categories,
    required this.onAdd,
    required this.generateId,
  });

  final List<String> categories;
  final void Function(MenuItem item) onAdd;
  final String Function() generateId;

  @override
  State<AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<AddMenuItemDialog> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '10');
  final _imageCtrl = TextEditingController();
  final _newCategoryCtrl = TextEditingController();
  late String _selectedCategory;
  bool _isNewCategory = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.categories.isNotEmpty ? widget.categories.first : 'Main Course';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim());
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 10;
    final category =
        _isNewCategory ? _newCategoryCtrl.text.trim() : _selectedCategory;
    final imageUrl = _imageCtrl.text.trim();

    if (name.isEmpty) {
      _showError('Please enter item name');
      return;
    }
    if (price == null || price <= 0) {
      _showError('Please enter valid price');
      return;
    }
    if (category.isEmpty) {
      _showError('Please select or enter category');
      return;
    }

    final newItem = MenuItem(
      id: widget.generateId(),
      name: name,
      price: price,
      stock: stock,
      category: category,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
    );

    widget.onAdd(newItem);
    Navigator.pop(context, name);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Add New Menu Item',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogField(controller: _nameCtrl, label: 'Item Name'),
            const SizedBox(height: 12),
            DialogField(
              controller: _priceCtrl,
              label: 'Price',
              keyboardType: TextInputType.number,
              prefix: '\$',
            ),
            const SizedBox(height: 12),
            DialogField(
              controller: _stockCtrl,
              label: 'Initial Stock',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DialogField(
              controller: _imageCtrl,
              label: 'Image URL (optional)',
            ),
            const SizedBox(height: 12),
            _buildCategorySelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
          child: const Text('Add Item'),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: [
        Expanded(
          child: _isNewCategory
              ? DialogField(
                  controller: _newCategoryCtrl,
                  label: 'New Category',
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      items: widget.categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            _isNewCategory ? Icons.list : Icons.add,
            color: Colors.white,
          ),
          onPressed: () => setState(() => _isNewCategory = !_isNewCategory),
          tooltip: _isNewCategory ? 'Select existing' : 'New category',
        ),
      ],
    );
  }
}

Future<String?> showAddMenuItemDialog(
  BuildContext context,
  AppState state,
) async {
  return showDialog<String>(
    context: context,
    builder: (ctx) => AddMenuItemDialog(
      categories: state.categories.toList(),
      generateId: state.generateNewId,
      onAdd: state.addMenuItem,
    ),
  );
}
