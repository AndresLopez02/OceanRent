import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat.dart';
import 'package:ocean_rent/pages/admin/boats/boat_form_page.dart';
import 'package:ocean_rent/services/boat_service.dart';
import 'package:ocean_rent/widgets/dialog_confirmacion.dart';

class BoatListPage extends StatelessWidget {
  const BoatListPage({super.key});

  Future<void> _goToCreate(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BoatFormPage()));
  }

  Future<void> _goToEdit(BuildContext context, Boat boat) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => BoatFormPage(boat: boat)));
  }

  Future<void> _deleteBoat(BuildContext context, Boat boat) async {
    await mostrarDialogoConfirmacion(
      context,
      titulo: 'Eliminar barco',
      mensaje: '¿Seguro que quieres eliminar "${boat.name}"?',
      textoCancelar: 'Cancelar',
      textoAceptar: 'Eliminar',
      onAceptar: () async {
        try {
          await BoatService.instance.deleteBoat(boat.id);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barco eliminado correctamente')),
          );
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar el barco')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Admin - Barcos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToCreate(context),
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Boat>>(
        stream: BoatService.instance.getBoatsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Ha ocurrido un error al cargar los barcos',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.deepNavy),
            );
          }

          final List<Boat> boats = snapshot.data ?? [];

          if (boats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_boat_filled_outlined,
                      size: 60,
                      color: AppTheme.deepNavy.withValues(alpha: 0.75),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Todavía no hay barcos creados',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pulsa el botón + para añadir el primero',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: boats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final Boat boat = boats[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.deepNavy.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: boat.imageUrl.isNotEmpty
                          ? Image.network(
                              boat.imageUrl,
                              height: 190,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _BoatImageFallback(boatName: boat.name),
                            )
                          : _BoatImageFallback(boatName: boat.name),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boat.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(icon: Icons.sailing, label: boat.type),
                              _InfoChip(
                                icon: Icons.groups_2_outlined,
                                label: '${boat.capacity} personas',
                              ),
                              _InfoChip(
                                icon: Icons.euro_outlined,
                                label:
                                    '${boat.pricePerDay.toStringAsFixed(boat.pricePerDay % 1 == 0 ? 0 : 2)} / día',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            boat.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _goToEdit(context, boat),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Editar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.deepNavy,
                                  side: const BorderSide(
                                    color: AppTheme.deepNavy,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _deleteBoat(context, boat),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Eliminar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.alertRed,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.pearlWhite,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.deepNavy.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.deepNavy),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoatImageFallback extends StatelessWidget {
  final String boatName;

  const _BoatImageFallback({required this.boatName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      color: AppTheme.pearlWhite,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_boat_filled_outlined,
            size: 42,
            color: AppTheme.deepNavy.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 8),
          Text(
            boatName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
