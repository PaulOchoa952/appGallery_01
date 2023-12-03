import 'package:flutter/material.dart';

class buscarevento extends StatefulWidget {
  const buscarevento({super.key});

  @override
  State<buscarevento> createState() => _buscareventoState();
}

class _buscareventoState extends State<buscarevento> {
  @override
  int _index=0;
  String evento="";
  String nombre="";
  String descripcion="";
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Evento'),
        centerTitle: true,
      ),
      body: dinamico(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: Text("PO"),
                ),
                SizedBox(height: 20,),
                Text("Paul Alejandro",style: TextStyle(color:Colors.pink,fontSize: 20),)
              ],
            ),
              decoration: BoxDecoration(color: Colors.blueAccent),
            ),
            _item(Icons.add,"Buscar evento",1),
            _item(Icons.list,"Visualizar eventos",2)
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icono,String texto,int indice){
    return ListTile(
      onTap: (){
        setState(() {
          _index=indice;
        });
        Navigator.pop(context);
      },
      title: Row(
        children: [Expanded(child: Icon(icono)), Expanded(child: Text(texto),flex: 2,)],
      ),
    );
  }

  Widget dinamico(){
    if(_index==1){
      return BuscarEvento();
    }
    return BuscarEvento();
  }

  Widget BuscarEvento(){
    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        Text("Numero de invitacion"),
        SizedBox(height: 10,),
        TextField(
          decoration: InputDecoration(
            labelText: "numero invitacion"
          ),
        ),
        SizedBox(height: 10,),
        FilledButton(onPressed: (){

        }, child: const Text("Buscar")),
        SizedBox(height: 20,),
        Text("Tipo Evento${evento}"),
        SizedBox(height: 10,),
        Text("Propiedad de:${nombre}"),
        SizedBox(height: 10,),
        Text("Descripcion:${descripcion}"),
        SizedBox(height: 20,),
        FilledButton(onPressed: (){

        }, child: const Text("Agregar"))

      ],
    );
  }



}
