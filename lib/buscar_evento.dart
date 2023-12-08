import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:video2u3/album_evento.dart';
import 'package:video2u3/login.dart';
import 'package:video2u3/serviciosremotos.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';


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
  String? idImagen = "";

  final eventid = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController descripcionController = TextEditingController();
  final fechaInicial = TextEditingController();
  final fechaFinal = TextEditingController();
  final nombreNuevo=TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  bool permitirAgregarFotos = false;
  String tipoEventoSeleccionado = "Boda"; // Puedes inicializarlo con el primer tipo de evento


  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      fechaInicial.text = date.toString();
    });
  }

  void onDateSelected2(DateTime date) {
    setState(() {
      selectedDate2 = date;
      fechaFinal.text = date.toString();
    });
  }


  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: AppBar(
        title:  Text(titulo, style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: _botonMagico(),
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
            _item(Icons.search,"Buscar evento",1),
            _item(Icons.event,"Invitaciones",2),
            _item(Icons.logout, "Salir", 3),
            _item(Icons.add_a_photo,"Configuracion",4)
          ],
        ),
      ),
    );
  }

  List<Widget> _botonMagico() {
    if (_index == 0) {
      return [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _index = 3;
            });
          },
        ),
      ];
    } else {
      return [];
    }
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
                break;
              }
            case 1 :
              {
                setState(() {
                  titulo = "Buscar Evento";
                });
                break;
              }
            case 2 :
              {
                setState(() {
                  titulo = "Invitaciones";
                });
                break;
              }
            case 3 :
              {
                setState(() {
                  titulo = "Crear Evento";
                });
                break;
              }
            case 4:{
              setState(() {
                titulo= "Configuracion";
              });
              break;
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
        children: [Expanded(child: Icon(icono)),
          Expanded(child: Text(texto),flex: 2,)
        ],

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
      case 3 : {
        return crearEvento();
      }
      case 4:{
        return agregarFoto();
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

  Widget agregarFoto(){
    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        Text("Cambiar foto",style: TextStyle(fontSize: 30,),textAlign:TextAlign.center,),
        SizedBox(height: 10,),
        ElevatedButton(onPressed: () async {
           bool success= await _updateProfilePicture();
           if(success){
             _showSuccessMessage("Foto de perfil actualizada con exito");
           }
        }, child: const Text("Cambiar foto")),
        SizedBox(height: 30,),
        Text("Cambiar nombre",style: TextStyle(fontSize: 30,),textAlign:TextAlign.center,),
        SizedBox(height: 20,),
        TextField(
          controller: nombreNuevo,
          decoration: InputDecoration(
            labelText: "Nombre",
            border: OutlineInputBorder()
          ),
        ),
        SizedBox(height: 20,),
        FilledButton(onPressed: () async {
         bool success= await _updateProfileName(nombreNuevo.text);
         if(success){
           setState(() {
             nombreNuevo.text="";
           });
           _showSuccessMessage("Nombre de perfil actualizada con exito");
         }
        }, child: const Text("Cambiar nombre"))
      ],
    );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlbumEvento(datos: listaJSON.data?[indice], usuario: widget.datos["id"],)),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlbumEvento(datos: listaJSON.data?[indice], usuario: widget.datos["id"],)),
                      );
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

  Widget crearEvento(){
    return FutureBuilder(
        future: DB.MisEventos(widget.datos['id']),
        builder: (context,listaJSON){
          if(listaJSON.hasData){
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Evento Nuevo',
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        controller: descripcionController,
                        decoration: InputDecoration(
                          labelText: "Descripción del Evento",
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        controller: fechaInicial,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: "Fecha Inicial (dd/mm/aa):",
                          prefixIcon: Icon(Icons.date_range),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text('Tipo de Evento:',style: TextStyle(fontSize: 18),),
                      SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: tipoEventoSeleccionado,
                          onChanged: (String? newValue) {
                            setState(() {
                              tipoEventoSeleccionado = newValue!;
                            });
                          },
                          items: <String>['Boda', 'Bautizo', 'Cumpleaños', 'Baby-Shower', 'Peda']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            );
                          }).toList(),
                          icon: Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          elevation: 2,
                          style: TextStyle(color: Colors.black87),
                          underline: Container(
                            height: 10,
                            color: Colors.transparent,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.0),
                      TextField(
                        controller: fechaFinal,
                        onTap: () => _selectDate2(context),
                        decoration: InputDecoration(
                          labelText: "Fecha final (dd/mm/aa):",
                          prefixIcon: Icon(Icons.date_range),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Permitir agregar fotos después\n de la fecha Final'),
                          Switch(
                            value: permitirAgregarFotos,
                            onChanged: (bool value) {
                              setState(() {
                                permitirAgregarFotos = value;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Timestamp f1 = Timestamp.fromMillisecondsSinceEpoch(selectedDate!.millisecondsSinceEpoch);
                              Timestamp f2 = Timestamp.fromMillisecondsSinceEpoch(selectedDate2!.millisecondsSinceEpoch);
                              var datos = {
                                'admin':widget.datos['id'],
                                'agreDeFecha':permitirAgregarFotos,
                                'descipcion':descripcionController.text,
                                'estado': true,
                                'fechaF':f2,
                                'fechaI':f1,
                                'imagen': idImagen,
                                'tipoEvento': tipoEventoSeleccionado,
                                'invitados':[
                                ],
                              };
                              DB.agregarEvento(datos);
                            },
                            child: Text('Crear'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              idImagen = await _abrirGaleria();
                            },
                            child: Text('Añadir Foto'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );


          }
          return Center(child: CircularProgressIndicator(),);
        }
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fechaInicial.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate2 ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate2) {
      setState(() {
        selectedDate2 = picked;
        fechaFinal.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  String convertirTimestampAFecha(Timestamp timestamp) {

    DateTime dateTime = timestamp.toDate();

    String fechaFormateada = "${dateTime.day}/${dateTime.month}/${dateTime.year}";

    return fechaFormateada;
  }

  String _formatFechaConsulta(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      String formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      return formattedDate;
    }
    return "Fecha no válida";
  }

  void copiarAlPortapapeles(String texto) {
    Clipboard.setData(ClipboardData(text: texto));
  }

  Future<String?> _abrirGaleria() async {

    final picker = ImagePicker();
    String? url = "";
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      url = await DB.subirArchivo(
          imagen.path, imagen.name);

      if (url != null) {
        print("Imagen subida exitosamente. URL: $url");
      } else {
        print("Error al subir la imagen.");
      }
    }
    print(" url2: $url");
    return  url;
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
  ///method to update profile picture
  Future <bool> _updateProfilePicture() async {
    String? newImageUrl = await _abrirGaleria();
    if (newImageUrl != null) {
    try{
      await DB.actualizarImagenUsuario(widget.datos['id'], newImageUrl);
        // Assuming you have a state variable to store the user's image URL
        setState(() {
          widget.datos['img'] = newImageUrl;
        });
      return true;
    } catch (e){
      print("Error al actualizar el nombre: $e");
    }
  }
    return false;
  }





  Future <bool> _updateProfileName(String text) async {
    if (text != null){
      try{
        await DB.actualizarNombreUsuario(widget.datos['id'],text);
        setState(() {
          widget.datos['nombre']=text;
        });
        return true;
      }catch (e){
        print("Error al actualizar el nombre: $e");
      }
    }
    return false;
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
      ),
    );
  }

}