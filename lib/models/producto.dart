
import 'dart:convert';

List<Producto> productoListFromJson(String str) => List<Producto>.from(json.decode(str).map((x) => Producto.fromJson(x)));

String productoToJson(Producto data) => json.encode(data.toJson());

class Producto {
    int id;
    String nombre;
    String descripcion;
    String codigoBarras;
    String categoria;
    double precio;
    int stock;
    String proveedor;
    DateTime fechaIngreso;
    bool activo;

    Producto({
        this.id = 0, 
        required this.nombre,
        required this.descripcion,
        required this.codigoBarras,
        required this.categoria,
        required this.precio,
        required this.stock,
        required this.proveedor,
        required this.fechaIngreso, 
        required this.activo,
    });

factory Producto.fromJson(Map<String, dynamic> json) {
  bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false; 
  }

  return Producto(
    id: int.tryParse(json['id'].toString()) ?? 0,
    nombre: json['nombre'] as String,
    descripcion: json['descripcion'] as String,
    codigoBarras: json['codigo_barras'] as String,
    categoria: json['categoria'] as String,
    precio: double.tryParse(json['precio'].toString()) ?? 0.0,
    stock: int.tryParse(json['stock'].toString()) ?? 0,
    proveedor: json['proveedor'] as String,
    activo: parseBool(json['activo']),
    
    
    fechaIngreso: DateTime.tryParse(json['fecha_ingreso'].toString()) ?? DateTime.now(),
  );
}

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "descripcion": descripcion,
        "codigo_barras": codigoBarras,
        "categoria": categoria,
        "precio": precio,
        "stock": stock,
        "proveedor": proveedor,
        "activo": activo ? 1 : 0, 
    };
}