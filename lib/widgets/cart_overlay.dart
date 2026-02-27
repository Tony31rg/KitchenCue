import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/restaurant_table.dart';
import 'cart_item.dart';
import 'table_selector.dart';

/// Full-screen overlay for creating/editing orders
class CartOverlay extends StatefulWidget {
  const CartOverlay({
    super.key,
    required this.cart,
    required this.menuItems,
    required this.total,
    required this.tables,
    required this.selectedTable,
    required this.onSelectTable,
    required this.onAddTable,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
    required this.onClose,
    required this.onPlaceOrder,
  });

  final Map<String, int> cart;
  final List<MenuItem> menuItems;
  final double total;
  final List<RestaurantTable> tables;
  final int? selectedTable;
  final void Function(int) onSelectTable;
  final void Function(int) onAddTable;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  final VoidCallback onClear;
  final VoidCallback onClose;
  final VoidCallback onPlaceOrder;

  @override
  State<CartOverlay> createState() => _CartOverlayState();
}

class _CartOverlayState extends State<CartOverlay> {
  final TextEditingController _newTableCtrl = TextEditingController();

  @override
  void dispose() {
    _newTableCtrl.dispose();
    super.dispose();
  }

  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Table',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _newTableCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Table number',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final num = int.tryParse(_newTableCtrl.text.trim());
              if (num != null && num > 0) {
                widget.onAddTable(num);
                _newTableCtrl.clear();
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Material(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 580,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const Divider(color: Color(0xFF3A3A3A), height: 1),
                _buildTableSection(),
                const Divider(color: Color(0xFF3A3A3A), height: 1),
                _buildItemsList(),
                const Divider(color: Color(0xFF3A3A3A), height: 1),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Create Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TableSelector(
        tables: widget.tables,
        selectedTable: widget.selectedTable,
        onSelectTable: widget.onSelectTable,
        onAddTable: _showAddTableDialog,
      ),
    );
  }

  Widget _buildItemsList() {
    if (widget.cart.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Text('No items in order',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      );
    }

    return Flexible(
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: widget.cart.entries.map((entry) {
          final idx = widget.menuItems.indexWhere((i) => i.id == entry.key);
          if (idx == -1) return const SizedBox.shrink();
          final item = widget.menuItems[idx];
          return CartItem(
            item: item,
            qty: entry.value,
            onAdd: () => widget.onAdd(entry.key),
            onRemove: () => widget.onRemove(entry.key),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.selectedTable != null
                    ? 'Table ${widget.selectedTable}'
                    : 'No table selected',
                style: TextStyle(
                  color: widget.selectedTable != null
                      ? Colors.white
                      : Colors.red[300],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${widget.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFF9800),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.cart.isEmpty ? null : widget.onClear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('CANCEL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.cart.isEmpty || widget.selectedTable == null
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.cart.isEmpty
                                    ? 'Add items to cart first'
                                    : 'Please select a table',
                              ),
                              backgroundColor: Colors.red[700],
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      : widget.onPlaceOrder,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('SEND TO KITCHEN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.cart.isEmpty || widget.selectedTable == null
                            ? Colors.grey[700]
                            : Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
