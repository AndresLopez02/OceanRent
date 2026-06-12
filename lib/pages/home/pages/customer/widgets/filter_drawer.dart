import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';

class FilterDrawer extends StatefulWidget {
  final List<String> selectedCategory;
  final List<String> selectedPorts;
  final RangeValues rangedPrice;
  final RangeValues rangedCapacity;
  final List<String> categories;
  final List<String> ports;
  final bool onlyAvailable;
  final String? selectedLicense;
  final VoidCallback onReset;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPortChanged;
  final ValueChanged<RangeValues> onPriceChanged;
  final ValueChanged<RangeValues> onCapacityChanged;
  final ValueChanged<bool> onOnlyAvailableChanged;
  final ValueChanged<String?> onLicenseChanged;

  const FilterDrawer({
    super.key,
    required this.selectedCategory,
    required this.selectedPorts,
    required this.rangedPrice,
    required this.rangedCapacity,
    required this.categories,
    required this.ports,
    required this.onlyAvailable,
    required this.onReset,
    required this.onCategoryChanged,
    required this.onPortChanged,
    required this.onPriceChanged,
    required this.onCapacityChanged,
    required this.onOnlyAvailableChanged,
    required this.onLicenseChanged,
    this.selectedLicense,
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late List<String> _selectedCategory;
  late List<String> _selectedPorts;
  late RangeValues _rangedPrice;
  late RangeValues _rangedCapacity;
  late bool _onlyAvailable;
  late String? _selectedLicense;

  @override
  void initState() {
    super.initState();
    _selectedCategory = List.from(widget.selectedCategory);
    _selectedPorts = List.from(widget.selectedPorts);
    _rangedPrice = widget.rangedPrice;
    _rangedCapacity = widget.rangedCapacity;
    _onlyAvailable = widget.onlyAvailable;
    _selectedLicense = widget.selectedLicense;
  }

  @override
  void didUpdateWidget(FilterDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _selectedCategory = List.from(widget.selectedCategory);
    }
    if (oldWidget.selectedPorts != widget.selectedPorts) {
      _selectedPorts = List.from(widget.selectedPorts);
    }
    if (oldWidget.rangedPrice != widget.rangedPrice) {
      _rangedPrice = widget.rangedPrice;
    }
    if (oldWidget.rangedCapacity != widget.rangedCapacity) {
      _rangedCapacity = widget.rangedCapacity;
    }
    if (oldWidget.onlyAvailable != widget.onlyAvailable) {
      _onlyAvailable = widget.onlyAvailable;
    }
    if (oldWidget.selectedLicense != widget.selectedLicense) {
      _selectedLicense = widget.selectedLicense;
    }
  }

  String _normalize(String text) {
    const accents = 'áéíóúàèìòùäëïöüâêîôûñÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÑ';
    const normal  = 'aeiouaeiouaeiouaeiounAEIOUAEIOUAEIOUAEIOUN';
    return text.trim().toLowerCase().splitMapJoin(
      '',
      onNonMatch: (char) {
        final i = accents.indexOf(char);
        return i >= 0 ? normal[i] : char;
      },
    );
  }

  bool _portIsSelected(String port) {
    return _selectedPorts.any(
      (p) => _normalize(p) == _normalize(port),
    );
  }

  String _formatCategory(String category) {
    if (category.isEmpty) return category;
    if (category == 'todos') return 'Todos';
    if (category == 'jetski') return 'Jet ski';
    return category[0].toUpperCase() + category.substring(1);
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.deepNavy,
          fontWeight: FontWeight.w700,
        ) ??
        AppTheme.titleSmall;
  }

  TextStyle _rangeValueStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.deepNavy,
          fontWeight: FontWeight.w600,
        ) ??
        AppTheme.bodySmall.copyWith(
          color: AppTheme.deepNavy,
          fontWeight: FontWeight.w600,
        );
  }

  Widget _sectionSpacing() => const SizedBox(height: AppTheme.spacing24);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: AppTheme.pearlWhite,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.compactCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppTheme.deepNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = [];
                        _selectedPorts = [];
                        _rangedPrice = const RangeValues(0, 1000);
                        _rangedCapacity = const RangeValues(1, 100);
                        _onlyAvailable = false;
                        _selectedLicense = null;
                      });
                      widget.onReset();
                    },
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              const Divider(),
              const SizedBox(height: AppTheme.spacing16),
              Text('Categoria', style: _sectionTitleStyle(context)),
              const SizedBox(height: AppTheme.spacing8),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing8,
                children: widget.categories.map((category) {
                  final isSelected = _selectedCategory.contains(category);
                  return FilterChip(
                    label: Text(_formatCategory(category)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        isSelected
                            ? _selectedCategory.remove(category)
                            : _selectedCategory.add(category);
                      });
                      widget.onCategoryChanged(category);
                    },
                    selectedColor: AppTheme.oceanBlue.withValues(
                      alpha: AppTheme.alphaOverlayLight,
                    ),
                    checkmarkColor: AppTheme.deepNavy,
                    labelStyle: AppTheme.labelMedium.copyWith(
                      color: isSelected
                          ? AppTheme.deepNavy
                          : AppTheme.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.deepNavy
                          : AppTheme.dividerStrong,
                    ),
                  );
                }).toList(),
              ),
              _sectionSpacing(),
              Text('Ubicacion', style: _sectionTitleStyle(context)),
              const SizedBox(height: AppTheme.spacing8),
              if (widget.ports.isEmpty)
                Text(
                  'No hay ubicaciones disponibles',
                  style: AppTheme.bodySmall,
                )
              else
                Wrap(
                  spacing: AppTheme.spacing8,
                  runSpacing: AppTheme.spacing8,
                  children: widget.ports.map((port) {
                    final isSelected = _portIsSelected(port);
                    return FilterChip(
                      avatar: Icon(
                        Icons.location_on_outlined,
                        size: AppTheme.iconSizeSmall,
                        color: isSelected
                            ? AppTheme.deepNavy
                            : AppTheme.textSecondary,
                      ),
                      label: Text(port),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          if (isSelected) {
                            _selectedPorts.removeWhere(
                              (p) => _normalize(p) == _normalize(port),
                            );
                          } else {
                            _selectedPorts.add(port);
                          }
                        });
                        widget.onPortChanged(port);
                      },
                      selectedColor: AppTheme.oceanBlue.withValues(
                        alpha: AppTheme.alphaOverlayLight,
                      ),
                      checkmarkColor: AppTheme.deepNavy,
                      labelStyle: AppTheme.labelMedium.copyWith(
                        color: isSelected
                            ? AppTheme.deepNavy
                            : AppTheme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.deepNavy
                            : AppTheme.dividerStrong,
                      ),
                    );
                  }).toList(),
                ),
              _sectionSpacing(),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Solo disponibles',
                  style: _sectionTitleStyle(context),
                ),
                subtitle: Text(
                  'Oculta barcos que no esten activos en el catalogo',
                  style: AppTheme.bodySmall,
                ),
                value: _onlyAvailable,
                activeThumbColor: AppTheme.oceanBlue,
                activeTrackColor: AppTheme.oceanBlue.withValues(
                  alpha: AppTheme.alphaOverlayLight,
                ),
                onChanged: (value) {
                  setState(() => _onlyAvailable = value);
                  widget.onOnlyAvailableChanged(value);
                },
              ),
              _sectionSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Precio por día', style: _sectionTitleStyle(context)),
                  Text(
                    '${_rangedPrice.start.toInt()} EUR - ${_rangedPrice.end.toInt()} EUR',
                    style: _rangeValueStyle(context),
                  ),
                ],
              ),
              RangeSlider(
                values: _rangedPrice,
                min: 0,
                max: 1000,
                divisions: 100,
                activeColor: AppTheme.deepNavy,
                inactiveColor: AppTheme.deepNavy.withValues(
                  alpha: AppTheme.alphaOverlayLight,
                ),
                labels: RangeLabels(
                  '${_rangedPrice.start.toInt()} EUR',
                  '${_rangedPrice.end.toInt()} EUR',
                ),
                onChanged: (values) {
                  setState(() => _rangedPrice = values);
                  widget.onPriceChanged(values);
                },
              ),
              _sectionSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Capacidad', style: _sectionTitleStyle(context)),
                  Text(
                    '${_rangedCapacity.start.toInt()} - ${_rangedCapacity.end.toInt()} personas',
                    style: _rangeValueStyle(context),
                  ),
                ],
              ),
              RangeSlider(
                values: _rangedCapacity,
                min: 1,
                max: 100,
                divisions: 25,
                activeColor: AppTheme.deepNavy,
                inactiveColor: AppTheme.deepNavy.withValues(
                  alpha: AppTheme.alphaOverlayLight,
                ),
                labels: RangeLabels(
                  '${_rangedCapacity.start.toInt()}',
                  '${_rangedCapacity.end.toInt()}',
                ),
                onChanged: (values) {
                  setState(() => _rangedCapacity = values);
                  widget.onCapacityChanged(values);
                },
              ),
              _sectionSpacing(),
              Text('Licencia requerida', style: _sectionTitleStyle(context)),
              const SizedBox(height: AppTheme.spacing8),
              DropdownButtonFormField<String?>(
                value: _selectedLicense,
                isExpanded: true,
                decoration: AppTheme.inputDecoration(
                  labelText: 'Tipo de licencia',
                  icon: Icons.badge_outlined,
                ),
                dropdownColor: AppTheme.white,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.deepNavy),
                selectedItemBuilder: (context) => const [
                  Text('Todas las licencias', overflow: TextOverflow.ellipsis),
                  Text('Sin licencia', overflow: TextOverflow.ellipsis),
                  Text('PNB', overflow: TextOverflow.ellipsis),
                  Text('PER', overflow: TextOverflow.ellipsis),
                ],
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Todas las licencias'),
                  ),
                  DropdownMenuItem(value: 'none', child: Text('Sin licencia')),
                  DropdownMenuItem(
                    value: 'pnb',
                    child: Text('PNB - Patron de Navegacion Basica'),
                  ),
                  DropdownMenuItem(
                    value: 'per',
                    child: Text('PER - Patron de Embarcaciones de Recreo'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedLicense = value);
                  widget.onLicenseChanged(value);
                },
              ),
              const SizedBox(height: AppTheme.spacing20),
            ],
          ),
        ),
      ),
    );
  }
}