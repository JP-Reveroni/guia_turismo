import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  //Cadastro no forms
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  int _categoriaId = 1;

void abrirForm() {
  //Sempre que abrir o forms, o campo está limpo
  _nomeController.clear();
  _descricaoController.clear();
  _latitudeController.clear();
  _longitudeController.clear();
  _categoriaId = 1;
  showDialog(context: context,
  builder: (context) {
    return AlertDialog(
      title: Text("Cadastro de Lugares"),
      //Evita erro de overflow quando o teclado abre
      content: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                label: Text("Nome")
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                label: Text("Descrição")
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              initialValue: _categoriaId,
              decoration: InputDecoration(
                label: Text("Categoria")
              ),
              items: [
                DropdownMenuItem(value: 1, child: Text("Praias")),
                DropdownMenuItem(value: 2, child: Text("Points")),
                DropdownMenuItem(value: 3, child: Text("Ilhas")),
                DropdownMenuItem(value: 4, child: Text("Gastronomia")),
                DropdownMenuItem(value: 5, child: Text("Dicas")),
              ],
              //Salva o valor do dropdown
              onChanged: (valor) => _categoriaId = valor!,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _latitudeController,
              decoration: InputDecoration(
                label: Text("Latitude")
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _longitudeController,
              decoration: InputDecoration(
                label: Text("Longitude")
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
        TextButton(onPressed: () => _salvarDados(context), child: Text("Salvar"))
      ],
    );
  });
}

Future<void> _salvarDados(BuildContext contextDialog) async {
  final novoLugar = LugaresModel(
    id: 0, //O Id é gerado pelo api
    nome: _nomeController.text,
    descricao: _descricaoController.text,
    //Converte virgula para ponto
    latitude: double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? 0,
    longitude: double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 0,
    categoriaId: _categoriaId,
  );
  final controleLugares = context.read<LugaresController>();
  final mensagem = await controleLugares.cadastrarLugar(novoLugar);
  if (!contextDialog.mounted) return;
  ScaffoldMessenger.of(contextDialog).showSnackBar(SnackBar(content: Text(mensagem)));
  if (controleLugares.erro.isEmpty) {
    //Fecha o modal qnd conclui
    Navigator.pop(contextDialog); 
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LugaresController>(builder: (context, lugaresController, child) {
        if (lugaresController.carregando){
          return Center(child: CircularProgressIndicator());
        }
        if (lugaresController.erro != ''){
          return Center(child: Text(lugaresController.erro));
        }
        if (lugaresController.lugares.isEmpty){
          return Center(child: Text("Nenhum lugar encontrado"));
        }
        //Monta a lista de lugares
        return ListView.builder(
          itemCount: lugaresController.lugares.length,
          itemBuilder: (context, index) {
            final lugar = lugaresController.lugares[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12)
              ),
              elevation: 4,
              child: ListTile(
                onTap: (){},
                title: Text(lugar.nome),
                subtitle: Text(lugar.categoria.toString()),
                //Icone que fica no inicio da linha
                leading: CircleAvatar(child: Icon(Icons.place)),
                //Icone que fica no final da linha
                trailing: IconButton(onPressed: (){}, icon: Icon(Icons.favorite)),
              ),
            );
          },
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirForm(),
        child: Icon(Icons.add_location_alt),
      ),

    );
  }
}