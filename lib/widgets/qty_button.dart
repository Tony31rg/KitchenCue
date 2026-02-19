import 'package:flutter/material.dart';

/// Small quantity adjustment button
class QtyButton extends StatelessWidget {
  const QtyButton({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:
              onTap == null ? const Color(0xFF2A2A2A) : const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.grey[700] : Colors.white,
        ),
      ),
    );
  }
}
