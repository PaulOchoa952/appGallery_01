import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class loging extends StatefulWidget {
  const loging({super.key});

  @override
  State<loging> createState() => _logingState();
}

class _logingState extends State<loging> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _forKey = GlobalKey<FormState>();
  TextEditingController _emailCont = TextEditingController();
  TextEditingController _contrasenaCont = TextEditingController();

  String email = "";
  String contrasena = "";

  void _handleSingUp() async{
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: contrasena
      );
      print("Usuario registrado: ${userCredential.user!.email}");
    }catch(e){
      print("Error al interntar registrar al usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text("Regristrar Usuario"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Form(
              key: _forKey,
              child: Column(
                mainAxisAlignment:  MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailCont,
                    keyboardType:  TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email"
                    ),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese un correo";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  SizedBox( height:20),
                  TextFormField(
                    controller: _contrasenaCont,
                    keyboardType:  TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Contraseña"
                    ),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese la contraseña";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        contrasena = value;
                      });
                    },
                  ),
                  SizedBox( height:20),
                  ElevatedButton(
                      onPressed: (){
                        if(_forKey.currentState!.validate()){
                          _handleSingUp();
                        }
                      },
                      child: Text("Registrar"))
                ],
              )
          ),
        ),
      ),

    );
  }
}