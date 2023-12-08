import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

var carpetaRemota = FirebaseStorage.instance;

var baseRemota = FirebaseFirestore.instance;

class DB{
  static Future insertar(Map<String,dynamic> user) async{
    return await baseRemota.collection("user").add(user);
  }

  static Future agregarEvento(Map<String,dynamic> datos) async{
    return await baseRemota.collection("evento").add(datos);
  }

  static Future<List<Map<String, dynamic>>> MisEventos(String id) async {
    List<Map<String, dynamic>> temp = [];
    var query = await baseRemota.collection("evento").where('admin', isEqualTo: id).get();

    query.docs.forEach((element) {
      Map<String, dynamic> datos = element.data();
      datos.addAll({'id': element.id});
      temp.add(datos);
    });

    return temp;
  }

  static Future<List<Map<String, dynamic>>> invitaciones(String id) async {
    List<Map<String, dynamic>> temp = [];

    var fechaActual = DateTime.now();

    var query = await baseRemota.collection("evento")
        .where('invitados', arrayContains: id)
        .where('estado', isEqualTo: true)
        .get();

    List<Future<void>> futures = [];

    for (var document in query.docs) {
      Map<String, dynamic> datos = document.data();
      datos.addAll({'id': document.id});

      // Verificar si 'agreDeFecha' es falso y si la fecha de fin no ha pasado
      bool agreDeFecha = datos['agreDeFecha'] ?? false;
      if (!agreDeFecha) {
        DateTime fechaFin = (datos['fechaF'] as Timestamp).toDate();
        if (fechaFin.isBefore(fechaActual)) {
          continue; // Saltar este evento si la fecha de fin ya ha pasado
        }
      }

      futures.add(
          baseRemota.collection("user").doc(datos['admin']).get().then((adminSnapshot) {
            var adminData = adminSnapshot.data();
            if (adminData != null) {
              datos.addAll({'nombreAdmin': adminData['nombre']});
            }
          })
      );

      temp.add(datos);
    }

    await Future.wait(futures);
    return temp;
  }


  static Future<Map<String,dynamic>> buscarUidLogin(String uid) async{
    try {
      CollectionReference collection = baseRemota.collection('user');
      var query = await collection.where('uidUser', isEqualTo: uid).get();
      if (query.docs.isNotEmpty) {
        var doc = query.docs.first;
        Map<String, dynamic> datos = doc.data() as Map<String, dynamic>;
        datos.addAll({
          'id':doc.id
        });
        return datos;
      } else {
        print("No se encontraron datos para el UID: $uid");
        return {};
      }
    } catch (e) {
      print("Error al buscar datos por UID: $e");
      return {};
    }
  }


  static Future<Map<String, dynamic>?> buscarEventoPorId(String idEvento) async {
    try {
      var evento = await baseRemota.collection("evento").doc(idEvento).get();
      if (evento.exists) {
        Map<String, dynamic> datosEvento = evento.data() as Map<String, dynamic>;
        var admin= await baseRemota.collection("user").doc(datosEvento['admin']).get();
        if (admin.exists) {
          Map<String, dynamic> datosAdmin = admin.data() as Map<String, dynamic>;

          datosEvento.addAll({'nombreAdmin': datosAdmin['nombre']});
        }

        print(datosEvento);

        return datosEvento;
      } else {
        return null;
      }
    } catch (e) {
      print("Error al buscar el evento: $e");
      return null;
    }
  }


  static Future<void> agregarInvitado(String idEvento, String idInvitado) async {
    try {
      var evento = baseRemota.collection("evento").doc(idEvento);

      var eventoSnapshot = await evento.get();
      var datosEvento = eventoSnapshot.data() as Map<String, dynamic>?;

      if (datosEvento != null) {
        var invitadosActuales = List<String>.from(datosEvento['invitados']);
        invitadosActuales.add(idInvitado);

        await evento.update({
          'invitados': invitadosActuales,
        });

        print("Invitado agregado con éxito.");
      } else {
        print("No se encontraron datos para el evento con ID: $idEvento");
      }
    } catch (e) {
      print("Error al agregar invitado: $e");
    }
  }



  static Future<String?> subirArchivo(String path, String nombreImagen) async {
    var file = File(path);
    var referenciaRemota = carpetaRemota.ref("caratula/$nombreImagen");
    try {
      await referenciaRemota.putFile(file);
      var url = await referenciaRemota.getDownloadURL();
      return url;
    } catch (error) {
      print("Error al subir el archivo: $error");
      return null;
    }
  }

/*
  static Future<String?> subirArchivo(String path, String id, String nombreImagen) async {
    var file = File(path);
    var referenciaRemota = carpetaRemota.ref("$id/$nombreImagen");
    try {
      await referenciaRemota.putFile(file);
      var url = await referenciaRemota.getDownloadURL();
      return url;
    } catch (error) {
      print("Error al subir el archivo: $error");
      return null;
    }
  }*/

  static Future<String> buscarAdminEvento(String id) async{
    var query = await baseRemota.collection("user").where(FieldPath.documentId, isEqualTo: id).get();
    if (query.docs.isNotEmpty) {
      var datos = query.docs.first.data();
      return datos["nombre"];
    } else {
      return "Usuario no encontrado";
    }
  }

  static Future<ListResult> mostrarAlbum(String idEvento) async{
    return await carpetaRemota.ref(idEvento).listAll();
  }

  static Future<String> obtenerURLimagen(String nombre, String idEvento) async{
    return await carpetaRemota.ref("$idEvento/$nombre").getDownloadURL();
  }

  static Future<String?> subirImagenAlbum(String path, String nombreImagen, String idEvento) async {
    var file = File(path);
    var referenciaRemota = carpetaRemota.ref("$idEvento/$nombreImagen");
    try {
      await referenciaRemota.putFile(file);
      var url = await referenciaRemota.getDownloadURL();
      return url;
    } catch (error) {
      print("Error al subir el archivo: $error");
      return null;
    }
  }

  static Future<void> eliminarImagenAlbum(String nombre, String idEvento) async{
    var referenciaRemota = carpetaRemota.ref("$idEvento/$nombre");
    try {
      await referenciaRemota.delete();
    } catch (error) {
      print("Error al eliminar el archivo: $error");
    }
  }

  static Future<String> obtenerNombre(String url) async{
    var referenciaRemota = carpetaRemota.refFromURL(url);
    return referenciaRemota.name;
  }

  static Future<int> actualizarEstadoDocumento(String idEvento, bool nuevoEstado) async {


    try {
      DocumentSnapshot documento = await baseRemota.collection("evento").doc(idEvento).get();

      if (documento.exists) {
        await baseRemota.collection("evento").doc(idEvento).update({
          'estado': nuevoEstado,
        });
        return 0; // Éxito
      } else {
        return 1; // Error: No se encontró el documento
      }
    } catch (e) {
      return 1; // Error general
    }
  }

}