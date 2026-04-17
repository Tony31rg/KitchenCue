import 'package:flutter/material.dart';

import '../services/firebase/firestore_sync_service.dart';

class DishesFirestoreGrid extends StatefulWidget {
  const DishesFirestoreGrid({super.key});

  @override
  State<DishesFirestoreGrid> createState() => _DishesFirestoreGridState();
}

class _DishesFirestoreGridState extends State<DishesFirestoreGrid> {
  final FirestoreSyncService _syncService = FirestoreSyncService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _syncService.fetchAllDishes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load dishes: ${snapshot.error}'),
          );
        }

        final dishes = snapshot.data ?? const [];
        if (dishes.isEmpty) {
          return const Center(child: Text('No dishes found'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
          ),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            final stockColor = dish.stock < 5 ? Colors.red : Colors.green;

            return Card(
              color: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '\$${dish.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Stock: ${dish.stock}',
                      style: TextStyle(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
