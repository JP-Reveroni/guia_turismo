import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/camera_controller.dart';
import 'package:provider/provider.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CameraController>(
        builder: (context, controleCamera, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(16),
                    image: exibirImagem(controleCamera)
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => controleCamera.abrirCamera(),
                    icon: Icon(Icons.camera_alt_rounded)
                  ) 
                ),
              ],
            )  
          ],
        ),
        ),
    );
  }
}


DecorationImage exibirImagem(CameraController controleCamera){
  if (controleCamera.imagemSelecionada == null){
    return DecorationImage(image: NetworkImage('https://placehold.co/150x150.png', scale: 1.0));
  } else {
    return DecorationImage(image: FileImage(controleCamera.imagemSelecionada!),
    fit: BoxFit.cover
    );
  }
}

void abrirModal(CameraController controleCamera, context) {
  showBottomSheet(
    context: context, 
    builder: (context) => SafeArea(
      bottom: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          ListTile(
            leading: Icon(Icons.camera),
            onTap: (){
              controleCamera.abrirCamera();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            onTap: () {
              controleCamera.abrirGaleria();
              Navigator.pop(context);
            },
          )
        ],
      ),
      )
    );
}