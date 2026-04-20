import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  // Abre la galería y permite seleccionar varias imágenes
  Future<List<XFile>> pickMultipleImages() async {
    return _imagePicker.pickMultiImage();
  }
}
