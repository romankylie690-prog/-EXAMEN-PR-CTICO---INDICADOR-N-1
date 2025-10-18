
import 'package:flutter/material.dart';
import 'package:biblioteca/screens/lista_producto.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // *** AQUÍ ESTÁ LA CLAVE ***
      home: const ListaProductosScreen(), 
    );
  }
}
