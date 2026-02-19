import 'package:flutter/material.dart';

class KitchenStatusCard extends StatelessWidget {
  const KitchenStatusCard({
    super.key,
    required this.isBusy,
    required this.onToggle,
  });

  final bool isBusy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                color:
                    isBusy ? const Color(0xFF3B2E00) : const Color(0xFF1B3A1F),
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
                          isBusy ? 'Kitchen is BUSY' : 'Kitchen is Ready',
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
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isBusy,
                    activeThumbColor: const Color(0xFFFF9800),
                    onChanged: (_) => onToggle(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
