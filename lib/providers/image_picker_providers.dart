import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/services/image_picker_service.dart';

// Provider del servicio que abre la galería y selecciona imágenes
final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});