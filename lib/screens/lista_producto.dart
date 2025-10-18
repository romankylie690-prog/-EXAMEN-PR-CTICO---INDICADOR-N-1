import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';
import 'agregar_producto.dart';
import 'detalle_producto.dart'; 

class ListaProductosScreen extends StatefulWidget {
    const ListaProductosScreen({super.key});

    @override
    State<ListaProductosScreen> createState() => _ListaProductosScreenState();
}

class _ListaProductosScreenState extends State<ListaProductosScreen> {
    late Future<List<Producto>> _productosFuture;
    final InventarioService _service = InventarioService();

    @override
    void initState() {
        super.initState();
        _productosFuture = _service.listarProductos();
    }

    // Recarga la lista de productos
    void _recargarProductos() {
        setState(() {
            _productosFuture = _service.listarProductos();
        });
    }

    // Función para manejar la eliminación
    void _eliminarProducto(int id) async {
        // Confirmación de usuario (ejemplo simple)
        final bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Confirmar Eliminación'),
                content: const Text('¿Está seguro de que desea eliminar este producto?'),
                actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                ],
            ),
        ) ?? false;

        if (confirm) {
            final result = await _service.eliminarProducto(id);
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                );
                if (result['success']) {
                    _recargarProductos(); 
                }
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Inventario de Tienda 📦'),
                backgroundColor: Colors.indigo,
                actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _recargarProductos,
                    ),
                ],
            ),
            body: FutureBuilder<List<Producto>>(
                future: _productosFuture,
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Error: ${snapshot.error}. Revise su conexión a la API.'),
                            ),
                        );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No hay productos en el inventario.'));
                    }

                    // Datos de Indicadores (ejemplo simple: Stock bajo < 10)
                    final productos = snapshot.data!;
                    final stockBajoCount = productos.where((p) => p.stock < 10).length;

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(' Indicadores: ${productos.length} Productos Totales | $stockBajoCount con Stock Bajo (<10) ⚠️', 
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                                child: ListView.builder(
                                    itemCount: productos.length,
                                    itemBuilder: (context, index) {
                                        final producto = productos[index];
                                        return Card(
                                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            elevation: 3,
                                            child: ListTile(
                                                leading: CircleAvatar(
                                                    backgroundColor: producto.stock < 10 ? Colors.redAccent : Colors.green,
                                                    child: Text(producto.stock.toString(), style: const TextStyle(color: Colors.white)),
                                                ),
                                                title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                subtitle: Text('Cat: ${producto.categoria} | Stock: ${producto.stock}'),
                                                trailing: Text('\$${producto.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.blue)),
                                                onTap: () async {
                                                    // Navegar a Detalle
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => DetalleProductoScreen(producto: producto),
                                                        ),
                                                    );
                                                    _recargarProductos(); // Recargar al volver (por si hubo edición/eliminación)
                                                },
                                                onLongPress: () => _eliminarProducto(producto.id), // Eliminar con Long Press
                                            ),
                                        );
                                    },
                                ),
                            ),
                        ],
                    );
                },
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                    // Navegar a Agregar Producto
                    await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AgregarProductoScreen()),
                    );
                    _recargarProductos(); // Recargar la lista al volver
                },
                child: const Icon(Icons.add),
            ),
        );
    }
}