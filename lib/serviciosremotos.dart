import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
//import 'package:firebase_storage/firebase_storage.dart';

//var carpetaRemota = FirebaseStorage.instance;

var baseRemota = FirebaseFirestore.instance;

class DB{
  static Future insertar(Map<String,dynamic> user) async{
    return await baseRemota.collection("user").add(user);
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

    var query = await baseRemota.collection("evento").where('invitados', arrayContains: id).get();

    List<Future<void>> futures = [];

    for (var document in query.docs) {
      Map<String, dynamic> datos = document.data();
      datos.addAll({'id': document.id});
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
      CollectionReference collection = FirebaseFirestore.instance.collection('user');
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
      var snapshot = await FirebaseFirestore.instance.collection("evento").doc(idEvento).get();
      if (snapshot.exists) {
        Map<String, dynamic> datosEvento = snapshot.data() as Map<String, dynamic>;
        var adminSnapshot = await FirebaseFirestore.instance.collection("user").doc(datosEvento['admin']).get();
        if (adminSnapshot.exists) {
          Map<String, dynamic> datosAdmin = adminSnapshot.data() as Map<String, dynamic>;

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
}