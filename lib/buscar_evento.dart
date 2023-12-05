import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:video2u3/login.dart';
import 'package:video2u3/serviciosremotos.dart';

class buscarevento extends StatefulWidget {
  final Map<String, dynamic> datos;
  const buscarevento({Key? key, required this.datos}) : super(key: key);

  @override
  State<buscarevento> createState() => _buscareventoState();
}

class _buscareventoState extends State<buscarevento> {
  @override

  int _index=0;
  String evento="";
  String nombre="";
  String descripcion="";
  String titulo= "Mis Eventos";
  final eventid = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: AppBar(
        title:  Text(titulo, style: TextStyle(color: Colors.white),),
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
                    backgroundColor: Colors.white,
                    radius: 40,
                    child: ClipOval(
                      child: Image.network(
                          widget.datos['img']
                      ),
                    )),
                SizedBox(height: 20,),
                Text("${widget.datos['nombre']}",style: TextStyle(color:Colors.white,fontSize: 20),)
              ],
            ),
              decoration: BoxDecoration(color: Color(0xFFE1BEE7)),
            ),
            _item(Icons.cake,"Mis Eventos",0),
            _item(Icons.add,"Buscar evento",1),
            _item(Icons.event,"Invitaciones",2),
            _item(Icons.logout, "Salir", 3)
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
          switch(_index) {
            case 0 :
              {
                setState(() {
                  titulo = "Mis Eventos";
                });
              }
            case 1 :
              {
                setState(() {
                  titulo = "Buscar Evento";
                });
              }
            case 2 :
              {
                setState(() {
                  titulo = "Invitaciones";
                });
              }
          }
        });
        // Handle the logout action
        if (_index == 3) {
          _handleLogout();
        } else {
          Navigator.pop(context);
        }
      },
      title: Row(
        children: [Expanded(child: Icon(icono)), Expanded(child: Text(texto),flex: 2,)],
      ),
    );
  }

  Widget dinamico(){

    switch(_index){
      case 0 : {

        return misEventos();
      }
      case 1 : {

        return BuscarEvento();
      }
      case 2 : {

        return invitaciones();
      }
    }
    return BuscarEvento();
  }

  void _handleLogout() async{
    try {
      // Perform any additional logout logic here
      // For example, sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to the login screen after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()), // Import your login screen file
      );
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  Widget BuscarEvento(){

    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        Text("Numero de invitacion"),
        SizedBox(height: 10,),
        TextField(
          controller: eventid,
          decoration: InputDecoration(
            labelText: "numero invitacion"
          ),
        ),
        SizedBox(height: 10,),
        FilledButton(onPressed: (){
          buscarEvento(eventid.text);
        }, child: const Text("Buscar")),
        SizedBox(height: 20,),
        Text("Tipo Evento: ${evento}"),
        SizedBox(height: 10,),
        Text("Propiedad de: ${nombre}"),
        SizedBox(height: 10,),
        Text("Descripcion: ${descripcion}"),
        SizedBox(height: 20,),
        FilledButton(onPressed: (){
          DB.agregarInvitado(eventid.text, widget.datos['id']);
        }, child: const Text("Agregar"))

      ],
    );
  }


  Widget misEventos(){
    return FutureBuilder(
        future: DB.MisEventos(widget.datos['id']),
        builder: (context,listaJSON){
          if(listaJSON.hasData){
            return ListView.builder(
                itemCount: listaJSON.data?.length,
                itemBuilder: (context, indice){
                  return InkWell(
                    onTap: () {
                      
                    },
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        margin: EdgeInsets.all(15),
                        elevation: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(

                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${listaJSON.data?[indice]['tipoEvento']} ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                                          PopupMenuButton<String>(
                                            itemBuilder: (BuildContext context) {
                                              return [
                                                PopupMenuItem<String>(
                                                  value: '1',
                                                  child: Text('Eliminar'),
                                                ),
                                                PopupMenuItem<String>(
                                                  value: '2',
                                                  child: Text('Actualizar'),
                                                ),
                                                PopupMenuItem<String>(
                                                  value: '3',
                                                  child: Text('Copiar Invitacion'),
                                                ),


                                              ];
                                            },
                                            onSelected: (String value) {
                                              switch(value){
                                                case '1': {

                                                }
                                                case '2': {

                                                }
                                                case '3': {

                                                  copiarAlPortapapeles("${listaJSON.data?[indice]['id']}");
                                                }
                                              }
                                              print('Opción seleccionada: $value');

                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Image.network(
                                  "${listaJSON.data?[indice]['imagen']}"
                              ),
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: ListTile(
                                      contentPadding:
                                      EdgeInsets.fromLTRB(15, 10, 25, 0),
                                      title: Text('${listaJSON.data?[indice]['descipcion']} ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ),
                                      subtitle: Text( "Fecha Finalizacion: ${convertirTimestampAFecha(listaJSON.data?[indice]['fechaF'])}"),

                                  )),
                            ],
                          ),
                        )),
                  );
                }
            );
          }
          return Center(child: CircularProgressIndicator(),);
        }
    );
  }

  Widget invitaciones(){
    return FutureBuilder(
        future: DB.invitaciones(widget.datos['id']),
        builder: (context,listaJSON){
          if(listaJSON.hasData){
            return ListView.builder(
                itemCount: listaJSON.data?.length,
                itemBuilder: (context, indice){
                  return InkWell(
                    onTap: () {

                    },
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        margin: EdgeInsets.all(15),
                        elevation: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(

                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${listaJSON.data?[indice]['tipoEvento']} ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                                          PopupMenuButton<String>(
                                            itemBuilder: (BuildContext context) {
                                              return [
                                                PopupMenuItem<String>(
                                                  value: '1',
                                                  child: Text('otra'),
                                                ),
                                                PopupMenuItem<String>(
                                                  value: '2',
                                                  child: Text('otra2'),
                                                ),

                                              ];
                                            },
                                            onSelected: (String value) {
                                              print('Opción seleccionada: $value');
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Image.network(
                                  "${listaJSON.data?[indice]['imagen']}"
                              ),
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: ListTile(
                                    contentPadding:
                                    EdgeInsets.fromLTRB(15, 10, 25, 0),
                                    title: Text('${listaJSON.data?[indice]['descipcion']} de ${listaJSON.data?[indice]['nombreAdmin']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ),
                                    subtitle: Text( "Fecha Finalizacion: ${convertirTimestampAFecha(listaJSON.data?[indice]['fechaF'])}"),

                                  )),
                            ],
                          ),
                        )),
                  );
                }
            );
          }
          return Center(child: CircularProgressIndicator(),);
        }
    );
  }
  String convertirTimestampAFecha(Timestamp timestamp) {

    DateTime dateTime = timestamp.toDate();

    String fechaFormateada = "${dateTime.day}/${dateTime.month}/${dateTime.year}";

    return fechaFormateada;
  }

  void copiarAlPortapapeles(String texto) {
    Clipboard.setData(ClipboardData(text: texto));
  }




  ///////////////future/////////////////////
  Future<void> buscarEvento(String idEventoBuscado) async {

    Map<String, dynamic>? datosEvento = await DB.buscarEventoPorId(idEventoBuscado);

    if (datosEvento != null) {
      setState(() {
        evento = datosEvento['tipoEvento'];
        nombre = datosEvento['nombreAdmin'];
        descripcion = datosEvento['descipcion'];
      });
    } else {
      // Manejar el caso en el que el evento no se encuentre
    }
  }

}
