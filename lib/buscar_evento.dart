import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:video2u3/album_evento.dart';
import 'package:video2u3/login.dart';
import 'package:video2u3/serviciosremotos.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
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
  bool subirPrimeraFoto = false;
  String tipoEventoSeleccionado = "Boda";
  bool camposCompletos = false;
  bool anadiendoInvitado = false;
  bool encontrado = false;
  bool agregado = false;

  FocusNode _focusNode = FocusNode();

  List<String?> imagenesDefecto = [
    'https://firebasestorage.googleapis.com/v0/b/dam-u4-appgallery.appspot.com/o/caratula%2Fboda.jpg?alt=media&token=f3100e91-80cc-41d6-83d9-6d2d2090a18a',
    'https://firebasestorage.googleapis.com/v0/b/dam-u4-appgallery.appspot.com/o/caratula%2Fbautizo.jpg?alt=media&token=59f8ff87-4bbc-43c8-b5ac-3c6abe9d2235',
    'https://firebasestorage.googleapis.com/v0/b/dam-u4-appgallery.appspot.com/o/caratula%2Fcumplean%CC%83os.jpg?alt=media&token=01d05b6a-d413-401c-83d6-2a4350d054c4',
    'https://firebasestorage.googleapis.com/v0/b/dam-u4-appgallery.appspot.com/o/caratula%2Fbaby.jpg?alt=media&token=b890dd18-cb53-426e-9bf8-9137feb1c1e3',
    'https://firebasestorage.googleapis.com/v0/b/dam-u4-appgallery.appspot.com/o/caratula%2Fpeda.jpg?alt=media&token=59b36a69-c93c-402e-8dfe-318695108acf'
  ];

  Future<void> _selectDateAndTime(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        DateTime selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          selectedDate = selectedDateTime;
          fechaInicial.text = selectedDate.toString();
        });
      }
    }
  }

  Future<void> _selectDateAndTime2(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        DateTime selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          selectedDate2 = selectedDateTime;
          fechaFinal.text = selectedDate2.toString();
        });
      }
    }
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
                    child: Container(
                      width: 2 * 40,
                      height: 2 * 40,
                      child: Image.network(
                        widget.datos['img'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
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

  Widget BuscarEvento() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListView(

        children: [
          Text(
            "Buscar Evento",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Número de Invitación",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: eventid,
            decoration: InputDecoration(
              labelText: "Número de Invitación",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.token_sharp),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: anadiendoInvitado
                ? null
                : () async {
              encontrado = await buscarEvento(eventid.text);
              if (!encontrado) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Evento no encontrado'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              setState(() {
                encontrado = encontrado;
              });
            },
            child: const Text("Buscar"),
          ),
          SizedBox(height: 20,),
          Text("Tipo Evento: ${evento}",
            style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            )
          ),
          SizedBox(height: 10,),
          Text("Propiedad de: ${nombre}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              )
          ),
          SizedBox(height: 10,),
          Text("Descripcion: ${descripcion}",
            style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          )
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: !encontrado || anadiendoInvitado
                ? null
                : () async {
              setState(() {
                anadiendoInvitado = true;
              });
              agregado = await DB.agregarInvitado(
                eventid.text,
                widget.datos['id'],
              );
              _showResultSnackBar(agregado);
              setState(() {
                anadiendoInvitado = false;
                agregado = false;
                eventid.clear();
              });
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _showResultSnackBar(bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Agregado correctamente' : 'Ya estás registrado en el evento',
        ),
        duration: Duration(seconds: 2),
      ),
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
                                                  value: '3',
                                                  child: Text('Copiar Invitacion'),
                                                ),


                                              ];
                                            },
                                            onSelected: (String value) {
                                              switch(value){
                                                case '1': {
                                                    eliminarEvento(listaJSON.data?[indice]['id']);
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
                                                  child: Text('Eliminar Invitacion'),
                                                ),

                                              ];
                                            },
                                            onSelected: (String value) {
                                              eliminarInvitacion(listaJSON.data?[indice]['id']);
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

  void eliminarInvitacion(String idEvento){

    showDialog(
        context: context,
        builder: (builder){
          return AlertDialog(
            title: Text("Confirmar Eliminacion"),
            content: Text("Seguro desea eliminar su invitacion a este evento?"),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")
              ),
              TextButton(
                  onPressed: ()async{
                    await DB.eliminarInvitacion(idEvento, widget.datos['id']).then((value) {
                      if(value==0){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invitacion Eliminada Correctamente")));
                        Navigator.pop(context);
                        setState(() {

                        });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al eliminar")));
                      }
                    });
                  },
                  child: Text("Eliminar")
              )
            ],
          );
        }
    );
  }

  void eliminarEvento(String idEvento){

    showDialog(
        context: context,
        builder: (builder){
          return AlertDialog(
            title: Text("Confirmar Eliminacion"),
            content: Text("Seguro desea eliminar este evento?"),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")
              ),
              TextButton(
                  onPressed: ()async{
                    await DB.eliminarEvento(idEvento).then((value) {
                      if(value==0){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Evento Eliminado Correctamente")));
                        Navigator.pop(context);
                        setState(() {

                        });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al eliminar")));
                      }
                    });
                  },
                  child: Text("Eliminar")
              )
            ],
          );
        }
    );
  }

  Widget crearEvento() {
    return FutureBuilder(
      future: DB.MisEventos(widget.datos['id']),
      builder: (context, listaJSON) {
        if (listaJSON.hasData) {
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
                      onTap: () {
                        _focusNode.unfocus();
                        _selectDateAndTime(context);
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Fecha y Hora Inicial:",
                        prefixIcon: Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      focusNode: _focusNode,
                    ),
                    SizedBox(height: 20.0),
                    Text('Tipo de Evento:', style: TextStyle(fontSize: 18)),
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
                        items: <String>[
                          'Boda',
                          'Bautizo',
                          'Cumpleaños',
                          'Baby-Shower',
                          'Peda'
                        ].map<DropdownMenuItem<String>>((String value) {
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
                      onTap: () {
                        _focusNode.unfocus();
                        _selectDateAndTime2(context);
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Fecha y Hora Final:",
                        prefixIcon: Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      focusNode: _focusNode,
                    ),

                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.expand_circle_down_outlined), // Puedes ajustar el icono según tus preferencias
                            SizedBox(width: 8.0),
                            Text('Permitir Fotos despues \nde la fecha final'),
                          ],
                        ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Cambia el color de fondo según tus preferencias
                    borderRadius: BorderRadius.circular(12.0), // Ajusta el radio de los bordes
                  ),
                  child: FlutterSwitch(
                    width: 55.0,
                    height: 28.0,
                    valueFontSize: 12.0,
                    toggleSize: 20.0,
                    value: permitirAgregarFotos,
                    borderRadius: 30.0,
                    padding: 4.0,
                    activeColor: Colors.blue, // Cambia el color cuando está activado
                    inactiveColor: Colors.grey, // Cambia el color cuando está desactivado
                    onToggle: (value) {
                      setState(() {
                        permitirAgregarFotos = value;
                      });
                    },
                  ),
                )

                ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.camera_alt), // Puedes ajustar el icono según tus preferencias
                            SizedBox(width: 8.0),
                            Text('Subir primera foto'),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Cambia el color de fondo según tus preferencias
                            borderRadius: BorderRadius.circular(12.0), // Ajusta el radio de los bordes
                          ),
                          child: FlutterSwitch(
                            width: 55.0,
                            height: 28.0,
                            valueFontSize: 12.0,
                            toggleSize: 20.0,
                            value: subirPrimeraFoto,
                            borderRadius: 30.0,
                            padding: 4.0,
                            activeColor: Colors.blue, // Cambia el color cuando está activado
                            inactiveColor: Colors.grey, // Cambia el color cuando está desactivado
                            onToggle: (value) {
                              setState(() {
                                subirPrimeraFoto = value;
                              });
                            },
                          ),
                        )

                      ],
                    ),

                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_validarCampos()) {

                              if (subirPrimeraFoto && idImagen == null) {
                                _mostrarSnackBar("Favor de seleccionar una foto de su galería o deshabilitar la opción");
                                return;
                              }

                              if(!subirPrimeraFoto && tipoEventoSeleccionado == "Boda"){
                                idImagen = imagenesDefecto[0];
                              }

                              if(!subirPrimeraFoto && tipoEventoSeleccionado == "Bautizo"){
                                idImagen = imagenesDefecto[1];
                              }

                              if(!subirPrimeraFoto && tipoEventoSeleccionado == "Cumplaeños"){
                                idImagen = imagenesDefecto[2];
                              }

                              if(!subirPrimeraFoto && tipoEventoSeleccionado == "Baby-Shower"){
                                idImagen = imagenesDefecto[3];
                              }

                              if(!subirPrimeraFoto && tipoEventoSeleccionado == "Peda"){
                                idImagen = imagenesDefecto[4];
                              }

                              Timestamp f1 = Timestamp.fromMillisecondsSinceEpoch(selectedDate!.millisecondsSinceEpoch);
                              Timestamp f2 = Timestamp.fromMillisecondsSinceEpoch(selectedDate2!.millisecondsSinceEpoch);

                              if (f2.compareTo(f1) < 0) {
                                _mostrarSnackBar("La fecha final no puede ser anterior a la fecha inicial");
                                return;
                              }


                              var datos = {
                                'admin': widget.datos['id'],
                                'agreDeFecha': permitirAgregarFotos,
                                'descipcion': descripcionController.text,
                                'estado': true,
                                'fechaF': f2,
                                'fechaI': f1,
                                'imagen': idImagen,
                                'tipoEvento': tipoEventoSeleccionado,
                                'invitados': [],
                              };
                              DB.agregarEvento(datos);

                              permitirAgregarFotos = false;
                              descripcionController.clear();
                              fechaInicial.clear();
                              fechaFinal.clear();
                              idImagen = "";

                              setState(() {
                                _index = 0;
                              });
                            } else {
                              _mostrarSnackBar("Por favor, complete todos los campos");
                            }
                          },
                          child: Text('Crear'),
                        ),

                        if (subirPrimeraFoto)
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
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  bool _validarCampos() {
    return descripcionController.text.isNotEmpty &&
        fechaInicial.text.isNotEmpty &&
        fechaFinal.text.isNotEmpty &&
        tipoEventoSeleccionado.isNotEmpty;
  }

  void _mostrarSnackBar(String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
  Future<bool> buscarEvento(String idEventoBuscado) async {

    Map<String, dynamic>? datosEvento = await DB.buscarEventoPorId(idEventoBuscado);

    if (datosEvento != null) {
      setState(() {
        evento = datosEvento['tipoEvento'];
        nombre = datosEvento['nombreAdmin'];
        descripcion = datosEvento['descipcion'];
      });
      return true;
    } else {
      return false;
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