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
          padding: AppTheme.listPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: AppTheme.cardTitleStyle.copyWith(
                      color: AppTheme.deepNavy,
                    ),
                  ),
                  TextButton(
                    onPressed: onReset,
                    style: AppTheme.compactTextButtonStyle,
                    child: Text(
                      'Limpiar',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.oceanBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: AppTheme.dividerStrong,
                thickness: AppTheme.borderWidthThin,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Categoría',
                style: AppTheme.labelLarge.copyWith(color: AppTheme.deepNavy),
              ),
              const SizedBox(height: AppTheme.spacing8),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedCategory,
                hint: Text('Selecciona categoría', style: AppTheme.bodySmall),
                items: categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category[0].toUpperCase() + category.substring(1),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.deepNavy,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precio por día (€)',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.deepNavy,
                    ),
                  ),
                  Text(
                    '${rangedPrice.start.toInt()}€ - ${rangedPrice.end.toInt()}€',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.deepNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: rangedPrice,
                min: 0,
                max: 1000,
                divisions: 100,
                activeColor: AppTheme.deepNavy,
                inactiveColor: AppTheme.deepNavy.withValues(
                  alpha: AppTheme.alphaOverlayLight,
                ),
                labels: RangeLabels(
                  '${rangedPrice.start.toInt()}€',
                  '${rangedPrice.end.toInt()}€',
                ),
                onChanged: onPriceChanged,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Capacidad',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.deepNavy,
                    ),
                  ),
                  Text(
                    '${rangedCapacity.start.toInt()} - ${rangedCapacity.end.toInt()} personas',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.deepNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: rangedCapacity,
                min: 1,
                max: 100,
                divisions: 25,
                activeColor: AppTheme.deepNavy,
                inactiveColor: AppTheme.deepNavy.withValues(
                  alpha: AppTheme.alphaOverlayLight,
                ),
                labels: RangeLabels(
                  '${rangedCapacity.start.toInt()}',
                  '${rangedCapacity.end.toInt()}',
                ),
                onChanged: onCapacityChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
