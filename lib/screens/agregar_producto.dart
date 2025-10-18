import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final InventarioService _service = InventarioService();

  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _codigoBarrasController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();

  void _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newProducto = Producto(
        id: 0, 
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        codigoBarras: _codigoBarrasController.text,
        categoria: _categoriaController.text,
        precio: double.tryParse(_precioController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        proveedor: _proveedorController.text,
        fechaIngreso: DateTime.now(),
        activo: true, 
      );

      final result = await _service.agregarProducto(newProducto);

      if (mounted) {
      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          
          Navigator.of(context).pop(true);
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
        title: const Text(' Agregar Nuevo Producto'),
        backgroundColor: const Color.fromARGB(159, 235, 66, 176),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(_nombreController, 'Nombre del Producto', isRequired: true),
              _buildTextField(_descripcionController, 'Descripción', isRequired: true, maxLines: 3),
              _buildTextField(_codigoBarrasController, 'Código de Barras', isRequired: true),
              _buildTextField(_categoriaController, 'Categoría', isRequired: true),
              _buildTextField(_proveedorController, 'Proveedor', isRequired: true),
              _buildTextField(
                _precioController,
                'Precio (\$)',
                isRequired: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El precio es requerido';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Ingrese un precio válido (> 0)';
                  return null;
                },
              ),
              _buildTextField(
                _stockController,
                'Stock Inicial',
                isRequired: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El stock es requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número entero';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _guardarProducto,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR PRODUCTO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}