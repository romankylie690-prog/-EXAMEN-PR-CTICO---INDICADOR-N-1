import 'dart:convert';
import 'package:http/http.dart' as http; 
import '../models/producto.dart';

class InventarioService {
    
    final String _baseUrl = "http://localhost/API_INVENTARIO/api_inventario.php"; 


    Future<List<Producto>> listarProductos() async {
        try {
            final response = await http.get(Uri.parse(_baseUrl));

            if (response.statusCode == 200) {
              
                return productoListFromJson(response.body);
            } else {
                
                throw Exception('Error al cargar productos: ${response.statusCode}');
            }
        } catch (e) {
            
            throw Exception('Fallo en la conexión: $e');
        }
    }

    Future<Map<String, dynamic>> agregarProducto(Producto producto) async {
        try {
            final response = await http.post(
                Uri.parse(_baseUrl),
                headers: {"Content-Type": "application/json"},
                body: productoToJson(producto),
            );

            final Map<String, dynamic> responseData = json.decode(response.body);

            if (response.statusCode == 201) { 
                return {'success': true, 'message': responseData['message']};
            } else {
                return {'success': false, 'message': responseData['message'] ?? 'Error desconocido al crear.'};
            }
        } catch (e) {
            return {'success': false, 'message': 'Error de conexión al agregar: $e'};
        }
    }

    Future<Map<String, dynamic>> actualizarProducto(Producto producto) async {
        try {
            final response = await http.put(
                Uri.parse(_baseUrl),
                headers: {"Content-Type": "application/json"},
                body: productoToJson(producto),
            );

            final Map<String, dynamic> responseData = json.decode(response.body);

            if (response.statusCode == 200) {
                return {'success': true, 'message': responseData['message']};
            } else {
                return {'success': false, 'message': responseData['message'] ?? 'Error desconocido al actualizar.'};
            }
        } catch (e) {
            return {'success': false, 'message': 'Error de conexión al actualizar: $e'};
        }
    }

    Future<Map<String, dynamic>> eliminarProducto(int id) async {
        try {
            final response = await http.delete(Uri.parse('$_baseUrl?id=$id'));
            
            final Map<String, dynamic> responseData = json.decode(response.body);

            if (response.statusCode == 200) {
                return {'success': true, 'message': responseData['message']};
            } else {
                return {'success': false, 'message': responseData['message'] ?? 'Error desconocido al eliminar.'};
            }
        } catch (e) {
            return {'success': false, 'message': 'Error de conexión al eliminar: $e'};
        }
    }
}