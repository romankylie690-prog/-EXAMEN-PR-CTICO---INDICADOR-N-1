import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;
  
  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = InventarioService();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _codigoBarrasController;
  late TextEditingController _categoriaController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _proveedorController;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos del producto existente
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _descripcionController = TextEditingController(text: widget.producto.descripcion);
    _codigoBarrasController = TextEditingController(text: widget.producto.codigoBarras);
    _categoriaController = TextEditingController(text: widget.producto.categoria);
    _precioController = TextEditingController(text: widget.producto.precio.toString());
    _stockController = TextEditingController(text: widget.producto.stock.toString());
    _proveedorController = TextEditingController(text: widget.producto.proveedor);
    _activo = widget.producto.activo;
  }

  // Función para manejar la lógica de actualización
  Future<void> _actualizarProducto() async {
  if (_formKey.currentState!.validate()) {
    final productoActualizado = Producto(
      id: widget.producto.id, // ID es crucial para el UPDATE
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      codigoBarras: _codigoBarrasController.text.trim(),
      categoria: _categoriaController.text.trim(),
      precio: double.tryParse(_precioController.text.trim()) ?? 0.0,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      proveedor: _proveedorController.text.trim(),
      activo: _activo, 
      
      fechaIngreso: widget.producto.fechaIngreso, // Usar la fecha original
    );

      try {
        await _service.actualizarProducto(productoActualizado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto actualizado exitosamente!')),
          );
          Navigator.of(context).pop(true); // Regresar y recargar
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoBarrasController.dispose();
    _categoriaController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.producto.nombre}'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Toggle Activo/Inactivo
              SwitchListTile(
                title: const Text('Producto Activo'),
                value: _activo,
                onChanged: (bool value) {
                  setState(() {
                    _activo = value;
                  });
                },
                secondary: Icon(_activo ? Icons.check_circle_outline : Icons.cancel_outlined, color: _activo ? Colors.green : Colors.red),
              ),

              // Inputs prellenados
              TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (value) => value!.isEmpty ? 'Obligatorio' : null),
              TextFormField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3, validator: (value) => value!.isEmpty ? 'Obligatorio' : null),
              TextFormField(controller: _codigoBarrasController, decoration: const InputDecoration(labelText: 'Código de Barras'), validator: (value) => value!.isEmpty ? 'Obligatorio' : null),
              TextFormField(controller: _categoriaController, decoration: const InputDecoration(labelText: 'Categoría'), validator: (value) => value!.isEmpty ? 'Obligatorio' : null),
              TextFormField(
                controller: _precioController, 
                decoration: const InputDecoration(labelText: 'Precio (\$)'), 
                keyboardType: TextInputType.number,
                validator: (value) => (double.tryParse(value!) ?? 0) <= 0 ? 'Precio > 0' : null,
              ),
              TextFormField(
                controller: _stockController, 
                decoration: const InputDecoration(labelText: 'Stock'), 
                keyboardType: TextInputType.number,
                validator: (value) => (int.tryParse(value!) ?? 0) < 0 ? 'Stock >= 0' : null,
              ),
              TextFormField(controller: _proveedorController, decoration: const InputDecoration(labelText: 'Proveedor'), validator: (value) => value!.isEmpty ? 'Obligatorio' : null),
              
              const SizedBox(height: 30),

              // Botón Actualizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _actualizarProducto,
                  icon: const Icon(Icons.update),
                  label: const Text('Actualizar Producto', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}