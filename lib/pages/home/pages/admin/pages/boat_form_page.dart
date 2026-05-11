import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat_model.dart';
import 'package:ocean_rent/pages/home/pages/admin/admin_home_page.dart';
import 'package:ocean_rent/services/boat/boat_service.dart';

import '../../../../../services/image/image_compress.dart';
import '../../../../../services/image/image_picker_service.dart';
import '../../../../../services/image/image_saver_service.dart';
import '../widgets/boat_form_field.dart';
import '../widgets/boat_image_picker.dart';

class BoatFormPage extends StatefulWidget {
  final BoatModel? boat;

  const BoatFormPage({super.key, this.boat});

  @override
  State<BoatFormPage> createState() => _BoatFormPageState();
}

class _BoatFormPageState extends State<BoatFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _portNameController = TextEditingController();

  final List<String> _boatTypes = const [
    'lancha',
    'semirigida',
    'velero',
    'yate',
    'catamaran',
    'jetski',
  ];

  static const List<(String, String)> _licenseTypes = [
    ('none', 'Sin licencia'),
    ('pbn', 'Patrón de Barco a Navegación (PBN)'),
    ('per', 'Patrón de Embarcaciones de Recreo (PER)'),
  ];

  String? _selectedBoatType;
  String _selectedLicense = 'none';
  bool _isSaving = false;
  bool _isPickingImage = false;
  File? _selectedImage;
  String imageUrlCloud = 'noURL';

  bool get isEditing => widget.boat != null;

  @override
  void initState() {
    super.initState();

    final boat = widget.boat;

    if (boat != null) {
      _nameController.text = boat.name;
      _selectedBoatType = _normalizeBoatType(boat.category);
      _capacityController.text = boat.capacity.toString();
      _priceController.text = boat.pricePerDay.toString();
      _depositController.text = boat.depositAmount.toString();
      _descriptionController.text = boat.description;
      _imageUrlController.text = boat.imageUrl;
      _portNameController.text = boat.portName;
      _selectedLicense = _normalizeLicense(boat.requiredLicense);
    }

    _imageUrlController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _portNameController.dispose();
    super.dispose();
  }

  String? _normalizeBoatType(String? type) {
    if (type == null) return null;

    final normalized = type
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(' ', '');

    switch (normalized) {
      case 'lancha':
        return 'lancha';
      case 'semirigida':
      case 'semirrigida':
        return 'semirigida';
      case 'velero':
        return 'velero';
      case 'yate':
        return 'yate';
      case 'catamaran':
        return 'catamaran';
      case 'jetski':
      case 'jetsky':
        return 'jetski';
      default:
        return null;
    }
  }

  String _boatTypeLabel(String type) {
    switch (type) {
      case 'lancha':
        return 'Lancha';
      case 'semirigida':
        return 'Semirrígida';
      case 'velero':
        return 'Velero';
      case 'yate':
        return 'Yate';
      case 'catamaran':
        return 'Catamarán';
      case 'jetski':
        return 'Jet Ski';
      default:
        return type;
    }
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);

    try {
      final pickerService = ImagePickerService();
      final images = await pickerService.pickMultipleImages();

      if (images.isEmpty) return;

      final compressed = await compressImage(images.first);

      if (compressed != null) {
        setState(() {
          _selectedImage = compressed;
        });
      }
    } catch (e) {
      debugPrint('Error seleccionando imagen: $e');
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? finalImageUrl = _imageUrlController.text.trim();

      if (_selectedImage != null) {
        finalImageUrl = await uploadToCloudinary(_selectedImage!);

        if (finalImageUrl == null || finalImageUrl.isEmpty) {
          throw Exception('No se pudo subir la imagen a Cloudinary');
        }

        imageUrlCloud = finalImageUrl;
      }

      final name = _nameController.text.trim();
      final category = _selectedBoatType?.trim() ?? '';
      final capacity = int.parse(_capacityController.text.trim());
      final price = double.parse(
        _priceController.text.trim().replaceAll(',', '.'),
      );
      final deposit = double.parse(
        _depositController.text.trim().replaceAll(',', '.'),
      );
      final description = _descriptionController.text.trim();
      final portName = _portNameController.text.trim();
      final imageUrl = finalImageUrl.isNotEmpty
          ? finalImageUrl
          : _imageUrlController.text.trim();

      if (isEditing) {
        await BoatService.instance.updateBoat(
          id: widget.boat!.id,
          name: name,
          category: category,
          capacity: capacity,
          pricePerDay: price,
          description: description,
          imageUrl: imageUrl,
          portName: portName,
          depositAmount: deposit,
          requiredLicense: _selectedLicense,
        );
      } else {
        await BoatService.instance.createBoat(
          name: name,
          category: category,
          capacity: capacity,
          pricePerDay: price,
          description: description,
          imageUrl: imageUrl,
          portName: portName,
          depositAmount: deposit,
          requiredLicense: _selectedLicense,
        );
      }

      if (!mounted) return;

      _showSnack(
        isEditing
            ? 'Barco actualizado correctamente'
            : 'Barco creado correctamente',
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      _showSnack('Error guardando barco: $e', error: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.white),
        ),
        backgroundColor: error ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadiusInput,
        ),
        margin: AppTheme.listPadding,
      ),
    );
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

  String? _validateDeposit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));

    if (parsed == null) return 'Introduce un importe válido';
    if (parsed < 0) return 'La fianza no puede ser negativa';

    return null;
  }

  String _normalizeLicense(String license) {
    final lower = license.toLowerCase();
    if (_licenseTypes.any((t) => t.$1 == lower)) return lower;
    return 'none';
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return AppTheme.inputDecoration(labelText: label, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(isEditing ? 'Editar barco' : 'Crear barco')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppTheme.listPadding,
            children: [
              BoatImagePicker(
                selectedImage: _selectedImage,
                imageUrl: _imageUrlController.text.trim(),
                isPickingImage: _isPickingImage,
                onPickImage: _pickImage,
                onRemoveImage: () => setState(() => _selectedImage = null),
              ),
              const SizedBox(height: AppTheme.spacing20),
              BoatFormField(
                controller: _nameController,
                label: 'Nombre',
                icon: Icons.directions_boat_outlined,
                validator: _validateRequired,
              ),
              const SizedBox(height: AppTheme.spacing12),
              DropdownButtonFormField<String>(
                initialValue: _selectedBoatType,
                decoration: _inputDecoration('Tipo de barco', icon: Icons.category_outlined),
                dropdownColor: AppTheme.surface,
                borderRadius: AppTheme.borderRadiusInput,
                style: AppTheme.fieldTextStyle,
                items: _boatTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(_boatTypeLabel(type), style: AppTheme.bodyMedium.copyWith(color: AppTheme.deepNavy),
                        )
                      ),
                    ).toList(),
                onChanged: (value) => setState(() => _selectedBoatType = value),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: AppTheme.spacing12),
              BoatFormField(
                controller: _capacityController,
                label: 'Capacidad',
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
                validator: _validateCapacity,
              ),
              const SizedBox(height: AppTheme.spacing12),
              BoatFormField(
                controller: _portNameController,
                label: 'Puerto / ubicación',
                icon: Icons.location_on_outlined,
                validator: _validateRequired,
              ),
              const SizedBox(height: AppTheme.spacing12),
              BoatFormField(
                controller: _priceController,
                label: 'Precio por día (€)',
                icon: Icons.euro_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePrice,
              ),
              const SizedBox(height: AppTheme.spacing12),
              BoatFormField(
                controller: _depositController,
                label: 'Fianza (€)',
                icon: Icons.lock_outline,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateDeposit,
              ),
              const SizedBox(height: AppTheme.spacing12),
              DropdownButtonFormField<String>(
                initialValue: _selectedLicense,
                isExpanded: true,
                decoration: _inputDecoration('Licencia requerida', icon: Icons.verified_outlined),
                dropdownColor: AppTheme.surface,
                borderRadius: AppTheme.borderRadiusInput,
                style: AppTheme.fieldTextStyle,
                items: _licenseTypes.map(((String, String) entry) => DropdownMenuItem<String>(
                        value: entry.$1,
                        child: Text(entry.$2, style: AppTheme.bodyMedium.copyWith(color: AppTheme.deepNavy)),
                      ),
                    ).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedLicense = value);
                },
              ),
              const SizedBox(height: AppTheme.spacing12),
              BoatFormField(
                controller: _descriptionController,
                label: 'Descripción',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: AppTheme.spacing24),
              SizedBox(
                height: AppTheme.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: AppTheme.fullWidthPrimaryButtonStyle,
                  child: Text(_isSaving ? 'Guardando...' : 'Guardar', style: AppTheme.buttonTextStyle.copyWith(color: AppTheme.pearlWhite)),
                ),
              ),
              if (!isEditing) ...[
                const SizedBox(height: AppTheme.spacing12),
                SizedBox(
                  height: AppTheme.compactButtonHeight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const AdminHomePage(),
                        ),
                      );
                    },
                    style: AppTheme.outlinedButtonStyle,
                    child: Text('Volver al panel', style: AppTheme.buttonTextStyle.copyWith(color: AppTheme.deepNavy),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
