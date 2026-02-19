import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../models/kitchen_status.dart';
import '../../../services/state_management/global_state.dart';

class KitchenStatusScreen extends StatefulWidget {
  const KitchenStatusScreen({super.key});

  @override
  State<KitchenStatusScreen> createState() => _KitchenStatusScreenState();
}

class _KitchenStatusScreenState extends State<KitchenStatusScreen> {
  // itemId -> draft stock value (only set when editing)
  final Map<String, int> _draft = {};

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final isBusy = state.kitchenStatus == KitchenStatus.busy;
    final categories = state.categories;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFF232323),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.go(RouteConstants.kitchenQueue),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back,
                                color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('Back to Kitchen Queue',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Kitchen Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Control inventory and kitchen status',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            // Busy mode card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Kitchen Status Control',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isBusy
                              ? const Color(0xFF3B2E00)
                              : const Color(0xFF1B3A1F),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isBusy
                                ? const Color(0xFFFF9800)
                                : const Color(0xFF66BB6A),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBusy
                                        ? 'Kitchen is BUSY'
                                        : 'Kitchen is Ready',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isBusy
                                        ? 'Waiters will see a delay warning'
                                        : 'Orders are being accepted normally',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isBusy,
                              activeThumbColor: const Color(0xFFFF9800),
                              onChanged: (_) {
                                state.toggleKitchenBusy();
                                _snack(
                                  isBusy
                                      ? 'Kitchen is now accepting orders'
                                      : 'Kitchen marked as BUSY',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Inventory
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Inventory Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...categories.map(
                        (cat) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Divider(color: Color(0xFF3A3A3A), height: 1),
                            const SizedBox(height: 8),
                            ...state.menuItems
                                .where((item) => item.category == cat)
                                .map(
                                  (item) => _InventoryRow(
                                    item: item,
                                    draftStock: _draft[item.id],
                                    onEdit: () => setState(
                                        () => _draft[item.id] = item.stock),
                                    onIncrement: () => setState(() {
                                      _draft[item.id] =
                                          (_draft[item.id] ?? item.stock) + 1;
                                    }),
                                    onDecrement: () => setState(() {
                                      final cur = _draft[item.id] ?? item.stock;
                                      _draft[item.id] = cur > 0 ? cur - 1 : 0;
                                    }),
                                    onDraftChanged: (v) =>
                                        setState(() => _draft[item.id] = v),
                                    onSave: () {
                                      final val = _draft[item.id];
                                      if (val != null) {
                                        state.updateStock(item.id, val);
                                        setState(() => _draft.remove(item.id));
                                        _snack('Stock updated');
                                      }
                                    },
                                    onCancel: () =>
                                        setState(() => _draft.remove(item.id)),
                                  ),
                                ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                state.addStockToAll(5);
                                _snack('Added 5 to all items');
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add 5 to All'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                state.resetAllStock(10);
                                _snack('Reset all stock to 10');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[700],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Reset All to 10'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({
    required this.item,
    required this.draftStock,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDraftChanged,
    required this.onSave,
    required this.onCancel,
  });

  final dynamic item;
  final int? draftStock;
  final VoidCallback onEdit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final void Function(int) onDraftChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isEditing = draftStock != null;
    final displayStock = draftStock ?? item.stock;
    final Color badgeColor = item.stock == 0
        ? Colors.red[700]!
        : item.stock <= 2
            ? Colors.orange[700]!
            : Colors.green[700]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isEditing) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.stock == 0 ? 'OUT OF STOCK' : '${item.stock} left',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Edit Stock',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ] else ...[
            Row(
              children: [
                _SmallBtn(icon: Icons.remove, onTap: onDecrement),
                const SizedBox(width: 8),
                SizedBox(
                  width: 52,
                  child: TextField(
                    controller: TextEditingController(text: '$displayStock'),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (v) {
                      final parsed = int.tryParse(v);
                      if (parsed != null) onDraftChanged(parsed);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SmallBtn(icon: Icons.add, onTap: onIncrement),
                const SizedBox(width: 10),
                _ActionBtn(
                    label: 'Save', color: Colors.green[700]!, onTap: onSave),
                const SizedBox(width: 6),
                _ActionBtn(
                    label: 'Cancel',
                    color: const Color(0xFF3A3A3A),
                    onTap: onCancel),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
