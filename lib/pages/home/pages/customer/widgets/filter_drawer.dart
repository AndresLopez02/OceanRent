import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';

class FilterDrawer extends StatelessWidget {
  final String? selectedCategory;
  final RangeValues rangedPrice;
  final RangeValues rangedCapacity;
  final List<String> categories;
  final VoidCallback onReset;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<RangeValues> onPriceChanged;
  final ValueChanged<RangeValues> onCapacityChanged;

  const FilterDrawer({
    super.key,
    required this.selectedCategory,
    required this.rangedPrice,
    required this.rangedCapacity,
    required this.categories,
    required this.onReset,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onCapacityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: AppTheme.deepNavy)),
                  TextButton(
                    onPressed: onReset,
                    child: const Text('Limpiar')
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text('Categoría', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.deepNavy)),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedCategory,
                hint: const Text('Selecciona categoría'),
                items: categories.map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category[0].toUpperCase() + category.substring(1),),
                        )).toList(),
                onChanged: onCategoryChanged
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Precio por día (€)', style: TextStyle(fontWeight: FontWeight.w600,color: AppTheme.deepNavy)),
                  Text('${rangedPrice.start.toInt()}€ - ${rangedPrice.end.toInt()}€',style: TextStyle(color: AppTheme.deepNavy)),
                ],
              ),
              RangeSlider(
                values: rangedPrice,
                min: 0,
                max: 1000,
                divisions: 100,
                activeColor: AppTheme.deepNavy,
                inactiveColor: AppTheme.deepNavy.withValues(alpha: 0.2),
                labels: RangeLabels('${rangedPrice.start.toInt()}€','${rangedPrice.end.toInt()}€'),
                onChanged: onPriceChanged,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Capacidad', style: TextStyle(fontWeight: FontWeight.w600,color: AppTheme.deepNavy)),
                  Text('${rangedCapacity.start.toInt()} - ${rangedCapacity.end.toInt()} personas', style: TextStyle(color: AppTheme.deepNavy),
                  )
                ]
              ),
              RangeSlider(
                values: rangedCapacity,
                min: 1,
                max: 100,
                divisions: 25,
                activeColor: AppTheme.deepNavy,
                inactiveColor: AppTheme.deepNavy.withValues(alpha: 0.2),
                labels: RangeLabels('${rangedCapacity.start.toInt()}','${rangedCapacity.end.toInt()}',),
                onChanged: onCapacityChanged,
              )
            ],
          )
        )
      )
    );
  }
}