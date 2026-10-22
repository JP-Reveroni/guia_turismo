//image_piker -> Pega a camera e a galeria
//Dart:Io -> Permite trabalhar com arquivos dentro do dart (arquivo foto vira caminho da foto)
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _image = ImagePicker();

  //Função de abrir a galera
  Future <File?> chamarGaleria() async {
    final XFile? imagem = await _image.pickImage(source: ImageSource.gallery);
    //Fecha a galeria
    if (imagem == null) return null;
    return File(imagem.path);
  }
  //Função de abrir a camera
  Future <File?> chamarCamera() async {
    final XFile? imagem = await _image.pickImage(source: ImageSource.camera);
    //Fecha a camera
    if (imagem == null) return null;
    return File(imagem.path);
  }
}