import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final Future<void> Function(MenuItem item) onAdd;
  final String Function() generateId;

  @override
  State<AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<AddMenuItemDialog> {
  static const List<String> _suggestedImages = [
    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600',
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
    'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=600',
    'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=600',
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600',
  ];

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '10');
  final _imageCtrl = TextEditingController();
  final _newCategoryCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  late String _selectedCategory;
  bool _isNewCategory = false;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.categories.isNotEmpty ? widget.categories.first : 'Main Course';
    _imageCtrl.addListener(_onImageChanged);
  }

  @override
  void dispose() {
    _imageCtrl.removeListener(_onImageChanged);
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  void _onImageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

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

    setState(() => _isSubmitting = true);
    try {
      await widget.onAdd(newItem);
      if (!mounted) {
        return;
      }
      Navigator.pop(context, name);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showError('Failed to save to Firestore. Check sync error banner.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploadingImage) {
      return;
    }

    try {
      setState(() => _isUploadingImage = true);

      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (picked == null) {
        return;
      }

      final bytes = await picked.readAsBytes();
      final now = DateTime.now().millisecondsSinceEpoch;
      final safeName = _nameCtrl.text.trim().isEmpty
          ? 'menu-item'
          : _nameCtrl.text
              .trim()
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      final ref =
          FirebaseStorage.instance.ref().child('menu-items/$safeName-$now.jpg');

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(bytes, metadata);
      final url = await ref.getDownloadURL();
      _useImage(url);
    } catch (_) {
      _showError('Image upload failed. Check Firebase Storage setup.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _useImage(String url) {
    setState(() {
      _imageCtrl.text = url;
    });
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
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
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
              label: 'Image Link (optional)',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('Choose Photo'),
              ),
            ),
            if (_isUploadingImage) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Uploading image...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            if (_imageCtrl.text.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: Image.network(
                    _imageCtrl.text.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1A1A1A),
                      alignment: Alignment.center,
                      child: const Text(
                        'Image preview unavailable',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < _suggestedImages.length; i++)
                    OutlinedButton(
                      onPressed: () => _useImage(_suggestedImages[i]),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF555555)),
                      ),
                      child: Text(
                        'Image ${i + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildCategorySelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Add Item'),
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
      onAdd: state.addMenuItemAndSync,
    ),
  );
}
