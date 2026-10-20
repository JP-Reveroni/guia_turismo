import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
import 'package:guia_turismo/screens/cadastro_lugar.dart';
import 'package:guia_turismo/screens/lugares_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _paginaAtual = 0;
  //Geram links e titulo para os botões do bottomNavigationBar
  final List<Widget> _paginas = [
    Center(child: Text("")),
    CadastroLugar(),
    LugaresScreen(),
  ];

  final List<String> _cabecalho = [
    'Guia Turismo',
    'Tirar foto',
    'Lugares Para visitar'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Pega o titulo pelo indice
        title: Text(_cabecalho[_paginaAtual]),
        actions: [
          Consumer<ThemeController>(
            builder: (context, controllerThema, child) => IconButton(
              onPressed: () => controllerThema.alternarTema(),
              icon: Icon(controllerThema.iconeAtual),
            ),
          ),
        ],
      ),
      //Pega o conteudo da pagina pelo indice
      body: _paginas[_paginaAtual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _paginaAtual = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Locais')
        ]
        
        ),

      
        
    );
  }
}
