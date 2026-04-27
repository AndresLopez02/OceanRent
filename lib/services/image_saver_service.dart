import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
//esta funcion guarda las imagenes en local y te devuelve el path para dejarlo en la base de datos y que se vea la imagen
Future<List<String>> saveImages(List<File> images) async {
  final directory = await getApplicationDocumentsDirectory();

final boatsDir = Directory('${directory.path}/boats_images');
  if (!await boatsDir.exists()) {
    await boatsDir.create(recursive: true);
  }

  List<String> imagepaths = [];

  for (final image in images) {
    final fileName = path.basename(image.path);
    final newPath = path.join(boatsDir.path, fileName);

    final newImage = await image.copy(newPath);
    imagepaths.add(newImage.path);
  }

  return imagepaths;
}