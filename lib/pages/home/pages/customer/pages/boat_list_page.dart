import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat_model.dart';
import 'package:ocean_rent/pages/home/pages/customer/widgets/customer_boat_card.dart';
import 'package:ocean_rent/pages/home/pages/customer/widgets/filter_drawer.dart';

class BoatListPage extends StatefulWidget {
  const BoatListPage({super.key});

  @override
  State<BoatListPage> createState() => _BoatListPageState();
}

class _BoatListPageState extends State<BoatListPage> {
  String? selectedCategory;
  RangeValues rangedPrice = const RangeValues(0, 1000);
  RangeValues rangedCapacity = const RangeValues(1, 100);

  final List<String> categories = [
    'todos',
    'lancha',
    'semirigida',
    'velero',
    'yate',
    'catamaran',
    'jetski',
  ];

  List<BoatModel> filterBoats(List<BoatModel> boats) {
    return boats.where((boat) {
      if (selectedCategory != null && selectedCategory != 'todos' && boat.category != selectedCategory) return false;
      if (boat.pricePerDay < rangedPrice.start || boat.pricePerDay > rangedPrice.end) return false;
      if (boat.capacity < rangedCapacity.start || boat.capacity > rangedCapacity.end) return false;
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      selectedCategory = null;
      rangedPrice = const RangeValues(0, 1000);
      rangedCapacity = const RangeValues(1, 100);
    });
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: FilterDrawer(
        selectedCategory: selectedCategory,
        rangedPrice: rangedPrice,
        rangedCapacity: rangedCapacity,
        categories: categories,
        onReset: _resetFilters,
        onCategoryChanged: (value) => setState(() => selectedCategory = value),
        onPriceChanged: (values) => setState(() => rangedPrice = values),
        onCapacityChanged: (values) => setState(() => rangedCapacity = values),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Builder(
                  builder: (context) => OutlinedButton.icon(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.tune),
                    label: const Text('Filtros'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.deepNavy,
                      side: BorderSide(color: AppTheme.deepNavy),
                    ),
                  ),
                ),
                if (selectedCategory != null || rangedCapacity.start != 1 || rangedCapacity.end != 100 || rangedPrice.start != 0 || rangedPrice.end != 1000)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: const Text('Filtros activos'),
                      backgroundColor: AppTheme.oceanBlue.withValues(alpha: 0.15),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: _resetFilters,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<BoatModel>('boats').listenable(),
              builder: (context, box, _) {
                final boats = box.values.toList();
                final filteredBoats = filterBoats(boats);
                if (boats.isEmpty) {
                  return Center(
                    child: Text('No hay barcos disponibles', style: textTheme.bodyLarge?.copyWith(color: AppTheme.deepNavy,fontWeight: FontWeight.w600)),
                  );
                }
                if (filteredBoats.isEmpty) {
                  return Center(
                    child: Text('No hay barcos con esa disposición', style: textTheme.bodyLarge?.copyWith(color: AppTheme.deepNavy, fontWeight: FontWeight.w600)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBoats.length,
                  itemBuilder: (context, index) {
                    return CustomerBoatCard(boat: filteredBoats[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}