import 'package:flutter/material.dart';

/// Banner displayed when kitchen is busy
class BusyBanner extends StatelessWidget {
  const BusyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3B2E00),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kitchen is busy! Expect delays on new orders.',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
