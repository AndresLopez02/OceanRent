import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat_model.dart';
import 'package:ocean_rent/models/user_model.dart';
import 'package:ocean_rent/pages/home/pages/customer/widgets/customer_boat_card.dart';
import 'package:ocean_rent/pages/home/pages/customer/widgets/filter_drawer.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/providers/user_providers.dart';


class BoatListPage extends ConsumerStatefulWidget {
  final List<String> categoriasIniciales;

  const BoatListPage({super.key, this.categoriasIniciales = const []});

  @override
 ConsumerState<BoatListPage> createState() => _BoatListPageState();
}

class _BoatListPageState extends ConsumerState<BoatListPage> {
  List<String> selectedCategories = [];
  List<String> selectedPorts = [];
  RangeValues rangedPrice = const RangeValues(0, 1000);
  RangeValues rangedCapacity = const RangeValues(1, 100);
  bool onlyAvailable = false;
  String? selectedLicense;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.categoriasIniciales.isNotEmpty) {
      selectedCategories = List.from(widget.categoriasIniciales);
    }
     loadCurrentUser();
  }
  Future<void> loadCurrentUser() async {
    final uid = ref.read(authNotifierProvider).currentUser?.uid;
    if (uid == null) return;

    final user = await ref.read(userRepositoryProvider).getUser(uid);

    if (!mounted) return;
    setState(() => currentUser = user);
  }

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
      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains('todos') &&
          !selectedCategories.contains(boat.category)) {
        return false;
      }

      if (selectedPorts.isNotEmpty &&
          !selectedPorts.contains(boat.portName.trim())) {
        return false;
      }

      if (boat.pricePerDay < rangedPrice.start ||
          boat.pricePerDay > rangedPrice.end) {
        return false;
      }

      if (boat.capacity < rangedCapacity.start ||
          boat.capacity > rangedCapacity.end) {
        return false;
      }
      if (selectedLicense != null &&
          boat.requiredLicense.toLowerCase() != selectedLicense) {
        return false;
      }
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      selectedCategories = [];
      selectedPorts = [];
      rangedPrice = const RangeValues(0, 1000);
      rangedCapacity = const RangeValues(1, 100);
      onlyAvailable = false;
      selectedLicense = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeFiltersCount =
        selectedCategories.length +
        selectedPorts.length +
        (rangedPrice.start != 0 || rangedPrice.end != 1000 ? 1 : 0) +
        (rangedCapacity.start != 1 || rangedCapacity.end != 100 ? 1 : 0) +
        (onlyAvailable ? 1 : 0) +
        (selectedLicense != null ? 1 : 0);

    return ValueListenableBuilder(
      valueListenable: Hive.box<BoatModel>('boats').listenable(),
      builder: (context, box, _) {
        final boats = box.values.toList();
        final filteredBoats = filterBoats(boats);

        // Puertos derivados del caché de Hive: solo se recalculan cuando cambia la caja
        final ports = boats
            .map((boat) => boat.portName.trim())
            .where((port) => port.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        return Scaffold(
          drawer: FilterDrawer(
            selectedCategory: selectedCategories,
            selectedPorts: selectedPorts,
            rangedPrice: rangedPrice,
            rangedCapacity: rangedCapacity,
            categories: categories,
            ports: ports,
            onlyAvailable: onlyAvailable,
            onReset: _resetFilters,
            onCategoryChanged: (value) => setState(() {
              selectedCategories.contains(value)
                  ? selectedCategories.remove(value)
                  : selectedCategories.add(value);
            }),
            onPortChanged: (value) => setState(() {
              selectedPorts.contains(value)
                  ? selectedPorts.remove(value)
                  : selectedPorts.add(value);
            }),
            onPriceChanged: (values) => setState(() => rangedPrice = values),
            onCapacityChanged: (values) =>
                setState(() => rangedCapacity = values),
            onOnlyAvailableChanged: (value) =>
                setState(() => onlyAvailable = value),
            selectedLicense: selectedLicense,
            onLicenseChanged: (value) => setState(() => selectedLicense = value),
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
                        label: Text(
                          activeFiltersCount == 0
                              ? 'Filtros'
                              : 'Filtros ($activeFiltersCount)',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.deepNavy,
                          side: BorderSide(color: AppTheme.deepNavy),
                        ),
                      ),
                    ),
                    if (activeFiltersCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Chip(
                          label: const Text('Filtros activos'),
                          backgroundColor: AppTheme.oceanBlue.withValues(
                            alpha: 0.15,
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: _resetFilters,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: boats.isEmpty
                    ? Center(
                        child: Text(
                          'No hay barcos disponibles',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppTheme.deepNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : filteredBoats.isEmpty
                    ? Center(
                        child: Text(
                          'No hay barcos con esa disposición',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppTheme.deepNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBoats.length,
                        itemBuilder: (context, index) {
                          return CustomerBoatCard(boat: filteredBoats[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
