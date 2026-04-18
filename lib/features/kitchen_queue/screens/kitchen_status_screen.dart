import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../models/kitchen_status.dart';
import '../../../services/state_management/global_state.dart';
import '../../../widgets/add_menu_item_dialog.dart';
import '../../../widgets/inventory_section.dart';
import '../../../widgets/kitchen_status_card.dart';
import '../../../widgets/quick_actions_section.dart';

class KitchenStatusScreen extends StatefulWidget {
  const KitchenStatusScreen({super.key});

  @override
  State<KitchenStatusScreen> createState() => _KitchenStatusScreenState();
}

class _KitchenStatusScreenState extends State<KitchenStatusScreen> {
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
    final canManageKitchen = state.canManageStock;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            if (state.lastSyncError != null)
              SliverToBoxAdapter(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE57373)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.lastSyncError!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: state.clearLastSyncError,
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                        tooltip: 'Dismiss',
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: KitchenStatusCard(
                isBusy: isBusy,
                onToggle: () {
                  if (!canManageKitchen) {
                    _snack('Only kitchen staff can change busy mode',
                        isError: true);
                    return;
                  }
                  state.toggleKitchenBusy();
                  _snack(
                    isBusy
                        ? 'Kitchen is now accepting orders'
                        : 'Kitchen marked as BUSY',
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: InventorySection(
                categories: state.categories.toList(),
                menuItems: state.menuItems.toList(),
                draftStocks: _draft,
                onEdit: (id) {
                  final item = state.menuItems.firstWhere((i) => i.id == id);
                  setState(() => _draft[id] = item.stock);
                },
                onIncrement: (id) => setState(() {
                  final item = state.menuItems.firstWhere((i) => i.id == id);
                  _draft[id] = (_draft[id] ?? item.stock) + 1;
                }),
                onDecrement: (id) => setState(() {
                  final item = state.menuItems.firstWhere((i) => i.id == id);
                  final cur = _draft[id] ?? item.stock;
                  _draft[id] = cur > 0 ? cur - 1 : 0;
                }),
                onDraftChanged: (id, v) => setState(() => _draft[id] = v),
                onSave: (id) {
                  if (!canManageKitchen) {
                    _snack('Only kitchen staff can update stock',
                        isError: true);
                    return;
                  }
                  final val = _draft[id];
                  if (val != null) {
                    state.updateStock(id, val);
                    setState(() => _draft.remove(id));
                    _snack('Stock updated');
                  }
                },
                onCancel: (id) => setState(() => _draft.remove(id)),
                onDelete: (id) async {
                  if (!canManageKitchen) {
                    _snack('Only kitchen staff can delete items',
                        isError: true);
                    return;
                  }

                  final menuItem =
                      state.menuItems.firstWhere((i) => i.id == id);
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF2A2A2A),
                      title: const Text(
                        'Delete Menu Item',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Remove "${menuItem.name}" from the menu?',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete != true) {
                    return;
                  }

                  try {
                    await state.deleteMenuItemAndSync(id);
                    if (!mounted) {
                      return;
                    }
                    _snack('"${menuItem.name}" removed from menu');
                  } catch (_) {
                    if (!mounted) {
                      return;
                    }
                    _snack('Failed to delete item. Please retry.',
                        isError: true);
                  }
                },
                onQuickRestock: (id) {
                  if (!canManageKitchen) {
                    _snack('Only kitchen staff can restock items',
                        isError: true);
                    return;
                  }
                  state.updateStock(id, 1);
                  _snack('Item is back in stock (1)');
                },
              ),
            ),
            SliverToBoxAdapter(
              child: QuickActionsSection(
                onAddMenuItem: () async {
                  if (!canManageKitchen) {
                    _snack('Only kitchen staff can add menu items',
                        isError: true);
                    return;
                  }
                  final name = await showAddMenuItemDialog(context, state);
                  if (name != null) {
                    _snack('"$name" added to menu');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF232323),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go(RouteConstants.kitchenQueue),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 18),
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
    );
  }
}
