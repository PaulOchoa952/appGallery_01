import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:video2u3/buscar_evento.dart';
import 'package:video2u3/login.dart';
import 'package:video2u3/regisgtrar.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFFEC5EA4, // Valor para un tono morado claro, puedes ajustar según tus preferencias
          <int, Color>{
            50: Color(0xFFF3E5F5),
            100: Color(0xFFE1BEE7),
            200: Color(0xFFEC5EA4),
            300: Color(0xFFBA68C8),
            400: Color(0xFFB444C4),
            500: Color(0xFF9C27B0),
            600: Color(0xFF8E24AA),
            700: Color(0xFF7B1FA2),
            800: Color(0xFF6A1B9A),
            900: Color(0xFF4A148C),
          },
        ),
      ),
      home: Login(),
    );
  }
}