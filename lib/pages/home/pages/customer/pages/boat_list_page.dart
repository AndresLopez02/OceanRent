import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat_model.dart';
import 'package:ocean_rent/pages/home/pages/customer/widgets/customer_boat_card.dart';

class BoatListPage extends StatelessWidget {
  const BoatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: Hive.box<BoatModel>('boats').listenable(),
      builder: (context, box, _) {
        final boats = box.values.toList();

        if (boats.isEmpty) {
          return Center(
            child: Text(
              'No hay barcos disponibles',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: boats.length,
          itemBuilder: (context, index) {
            return CustomerBoatCard(boat: boats[index]);
          },
        );
      },
    );
  }
}