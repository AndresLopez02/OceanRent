import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat.dart';
import 'package:ocean_rent/services/boat_service.dart';
import 'package:ocean_rent/widgets/build_label_text_fields.dart';
import 'package:ocean_rent/widgets/custom_text_field.dart';

class BoatFormPage extends StatefulWidget {
  final Boat? boat;

  const BoatFormPage({super.key, this.boat});

  bool get isEditing => boat != null;

  @override
  State<BoatFormPage> createState() => _BoatFormPageState();
}

class _BoatFormPageState extends State<BoatFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _pricePerDayController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final List<String> _boatTypes = const [
    'Lancha',
    'Velero',
    'Yate',
    'Catamarán',
    'Neumática',
    'Moto de agua',
    'Pesquero',
  ];

  String? _selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final Boat? boat = widget.boat;
    if (boat != null) {
      _nameController.text = boat.name;
      _capacityController.text = boat.capacity.toString();
      _pricePerDayController.text = boat.pricePerDay.toStringAsFixed(
        boat.pricePerDay % 1 == 0 ? 0 : 2,
      );
      _descriptionController.text = boat.description;
      _imageUrlController.text = boat.imageUrl;
      _selectedType = boat.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _pricePerDayController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveBoat() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null || _selectedType!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de barco')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final String name = _nameController.text.trim();
      final int capacity = int.parse(_capacityController.text.trim());
      final double pricePerDay = double.parse(
        _pricePerDayController.text.trim().replaceAll(',', '.'),
      );
      final String description = _descriptionController.text.trim();
      final String imageUrl = _imageUrlController.text.trim();

      if (widget.isEditing) {
        await BoatService.instance.updateBoat(
          id: widget.boat!.id,
          name: name,
          type: _selectedType!,
          capacity: capacity,
          pricePerDay: pricePerDay,
          description: description,
          imageUrl: imageUrl,
        );
      } else {
        await BoatService.instance.createBoat(
          name: name,
          type: _selectedType!,
          capacity: capacity,
          pricePerDay: pricePerDay,
          description: description,
          imageUrl: imageUrl,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Barco actualizado correctamente'
                : 'Barco creado correctamente',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Error al actualizar el barco'
                : 'Error al crear el barco',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduce $fieldName';
    }
    return null;
  }

  String? _validateCapacity(String? value) {
    final String? requiredError = _validateRequired(value, 'la capacidad');
    if (requiredError != null) return requiredError;

    final int? parsed = int.tryParse(value!.trim());
    if (parsed == null) {
      return 'La capacidad debe ser un número entero';
    }
    if (parsed <= 0) {
      return 'La capacidad debe ser mayor que 0';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final String? requiredError = _validateRequired(value, 'el precio por día');
    if (requiredError != null) return requiredError;

    final double? parsed = double.tryParse(value!.trim().replaceAll(',', '.'));
    if (parsed == null) {
      return 'El precio debe ser un número válido';
    }
    if (parsed <= 0) {
      return 'El precio debe ser mayor que 0';
    }
    return null;
  }

  String? _validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final Uri? uri = Uri.tryParse(value.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return 'Introduce una URL válida o deja el campo vacío';
    }
    return null;
  }

  Widget _buildImagePreview() {
    final String imageUrl = _imageUrlController.text.trim();

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        ),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.deepNavy.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 44, color: AppTheme.deepNavy),
          SizedBox(height: 8),
          Text('Sin imagen', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy = _isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar barco' : 'Crear barco'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildImagePreview(),
                const SizedBox(height: 20),

                buildLabelTextFields(context, 'Nombre del barco'),
                const SizedBox(height: 6),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Ej: Ocean Dream',
                  validator: (value) => _validateRequired(value, 'el nombre'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                buildLabelTextFields(context, 'Tipo de barco'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _boatTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Selecciona un tipo de barco';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.pearlWhite,
                      errorStyle: const TextStyle(
                        color: AppTheme.alertRed,
                        fontSize: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.deepNavy,
                          width: 1.9,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.oceanBlue,
                          width: 1.9,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.alertRed,
                          width: 1.9,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.alertRed,
                          width: 1.9,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                buildLabelTextFields(context, 'Capacidad'),
                const SizedBox(height: 6),
                CustomTextField(
                  controller: _capacityController,
                  hintText: 'Ej: 8',
                  keyboardType: TextInputType.number,
                  validator: _validateCapacity,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                buildLabelTextFields(context, 'Precio por día (€)'),
                const SizedBox(height: 6),
                CustomTextField(
                  controller: _pricePerDayController,
                  hintText: 'Ej: 250',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validatePrice,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                buildLabelTextFields(context, 'Descripción'),
                const SizedBox(height: 6),
                CustomTextField(
                  controller: _descriptionController,
                  hintText: 'Describe el barco...',
                  maxLines: 5,
                  validator: (value) =>
                      _validateRequired(value, 'la descripción'),
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 16),

                buildLabelTextFields(context, 'URL de imagen (opcional)'),
                const SizedBox(height: 6),
                CustomTextField(
                  controller: _imageUrlController,
                  hintText: 'https://...',
                  validator: _validateImageUrl,
                  onChanged: (_) {
                    setState(() {});
                  },
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isBusy ? null : _saveBoat,
                    child: isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isEditing
                                ? 'Guardar cambios'
                                : 'Crear barco',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
