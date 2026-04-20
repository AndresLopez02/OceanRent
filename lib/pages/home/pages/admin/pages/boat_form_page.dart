import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat.dart';
import 'package:ocean_rent/pages/home/pages/admin/admin_home_page.dart';
import 'package:ocean_rent/services/boat_service.dart';

class BoatFormPage extends StatefulWidget {
  final Boat? boat;

  const BoatFormPage({super.key, this.boat});

  @override
  State<BoatFormPage> createState() => _BoatFormPageState();
}

class _BoatFormPageState extends State<BoatFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSaving = false;

  bool get isEditing => widget.boat != null;

  @override
  void initState() {
    super.initState();

    final boat = widget.boat;
    if (boat != null) {
      _nameController.text = boat.name;
      _typeController.text = boat.type;
      _capacityController.text = boat.capacity.toString();
      _priceController.text = boat.pricePerDay.toString();
      _descriptionController.text = boat.description;
      _imageUrlController.text = boat.imageUrl;
    }

    _imageUrlController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final type = _typeController.text.trim();
      final capacity = int.parse(_capacityController.text.trim());
      final price = double.parse(
        _priceController.text.trim().replaceAll(',', '.'),
      );
      final description = _descriptionController.text.trim();
      final imageUrl = _imageUrlController.text.trim();

      if (isEditing) {
        await BoatService.instance.updateBoat(
          id: widget.boat!.id,
          name: name,
          type: type,
          capacity: capacity,
          pricePerDay: price,
          description: description,
          imageUrl: imageUrl,
        );
      } else {
        await BoatService.instance.createBoat(
          name: name,
          type: type,
          capacity: capacity,
          pricePerDay: price,
          description: description,
          imageUrl: imageUrl,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Barco actualizado correctamente'
                : 'Barco creado correctamente',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error guardando barco: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  String? _validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    final number = int.tryParse(value.trim());
    if (number == null) return 'Introduce un número válido';
    if (number <= 0) return 'La capacidad debe ser mayor que 0';

    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) return 'Introduce un precio válido';
    if (parsed <= 0) return 'El precio debe ser mayor que 0';

    return null;
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.deepNavy.withValues(alpha: 0.06),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 52,
          color: AppTheme.deepNavy.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final url = _imageUrlController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto del barco (URL)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: AppTheme.deepNavy,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.deepNavy.withValues(alpha: 0.15),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: url.isNotEmpty
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'URL de la imagen',
            hintText: 'https://...',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Puedes dejarlo vacío si aún no tienes la imagen.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.deepNavy.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.oceanBlue, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar barco' : 'Crear barco')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildImageSection(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Nombre'),
                validator: _validateRequired,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeController,
                decoration: _inputDecoration('Tipo de barco'),
                validator: _validateRequired,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Capacidad'),
                validator: _validateCapacity,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration('Precio por día (€)'),
                validator: _validatePrice,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Descripción'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                ),
              ),
              const SizedBox(height: 12),
              if (!isEditing)
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const AdminHomePage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.deepNavy,
                      side: BorderSide(
                        color: AppTheme.deepNavy.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Text('Volver al panel'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
