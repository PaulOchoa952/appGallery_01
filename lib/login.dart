
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _forKey = GlobalKey<FormState>();
  TextEditingController _emailCont = TextEditingController();
  TextEditingController _contrasenaCont = TextEditingController();

  String email = "";
  String contrasena = "";

  void _handleLogin() async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: contrasena
      );
      print("Seaccedio con el usario: ${userCredential.user!.email}");
    }catch(e){
      print("Error al intentar loggearse: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text("Login"),
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
                          _handleLogin();
                        }
                      },
                      child: Text("Acceder"))
                ],
              )
          ),
        ),
      ),

    );
  }
}