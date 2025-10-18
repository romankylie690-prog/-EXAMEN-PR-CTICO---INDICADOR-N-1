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
  final InventarioService _service = InventarioService();
  late bool _activo;

  // Controladores de texto
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _codigoBarrasController;
  late TextEditingController _categoriaController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _proveedorController;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los valores actuales del producto
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _descripcionController = TextEditingController(text: widget.producto.descripcion);
    _codigoBarrasController = TextEditingController(text: widget.producto.codigoBarras);
    _categoriaController = TextEditingController(text: widget.producto.categoria);
    _precioController = TextEditingController(text: widget.producto.precio.toString());
    _stockController = TextEditingController(text: widget.producto.stock.toString());
    _proveedorController = TextEditingController(text: widget.producto.proveedor);
    _activo = widget.producto.activo;
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

  // Función para actualizar el producto
  void _actualizarProducto() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedProducto = Producto(
        id: widget.producto.id,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        codigoBarras: _codigoBarrasController.text,
        categoria: _categoriaController.text,
        precio: double.tryParse(_precioController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        proveedor: _proveedorController.text,
        fechaIngreso: widget.producto.fechaIngreso, 
        activo: _activo,
      );

      final result = await _service.actualizarProducto(updatedProducto);

      if (mounted) {
        // Mostrar mensaje de éxito o error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          Navigator.of(context).pop(updatedProducto);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ Editar Producto'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // El ID no se edita, pero se puede mostrar
              Text('ID: ${widget.producto.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildTextField(_nombreController, 'Nombre del Producto'),
              _buildTextField(_descripcionController, 'Descripción', maxLines: 3),
              // Código de barras es clave, pero se permite editar
              _buildTextField(_codigoBarrasController, 'Código de Barras'), 
              _buildTextField(_categoriaController, 'Categoría'),
              _buildTextField(_proveedorController, 'Proveedor'),
              _buildTextField(
                _precioController,
                'Precio (\$)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (double.tryParse(value ?? '0') == null || double.parse(value!) <= 0) return 'Ingrese un precio válido (> 0)';
                  return null;
                },
              ),
              _buildTextField(
                _stockController,
                'Stock',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (int.tryParse(value ?? '') == null) return 'Debe ser un número entero';
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Producto Activo'),
                value: _activo,
                onChanged: (bool value) {
                  setState(() {
                    _activo = value;
                  });
                },
                secondary: Icon(_activo ? Icons.check_circle : Icons.remove_circle),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _actualizarProducto,
                icon: const Icon(Icons.update),
                label: const Text('ACTUALIZAR PRODUCTO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.orange,
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
          if (value == null || value.isEmpty) {
            return '$label es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}

class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;
  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  late Producto _productoActual;

  @override
  void initState() {
    super.initState();
    _productoActual = widget.producto;
  }

  // Navega a la pantalla de edición
  void _navegarAEdicion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProductoScreen(producto: _productoActual),
      ),
    );

    // Si la edición devuelve un producto, actualiza el estado (y la UI)
    if (result is Producto) {
      setState(() {
        _productoActual = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Detalle del Producto'),
        backgroundColor: Colors.indigo.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navegarAEdicion,
            tooltip: 'Editar Producto',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _productoActual.nombre,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const Divider(height: 20, thickness: 2),
                _buildInfoRow('ID', _productoActual.id.toString()),
                _buildInfoRow('Código de Barras', _productoActual.codigoBarras, icon: Icons.qr_code),
                _buildInfoRow('Categoría', _productoActual.categoria, icon: Icons.category),
                _buildInfoRow('Proveedor', _productoActual.proveedor, icon: Icons.local_shipping),
                const SizedBox(height: 15),
                _buildInfoRow('Precio', '\$${_productoActual.precio.toStringAsFixed(2)}', icon: Icons.monetization_on, color: Colors.green.shade700),
                _buildInfoRow('Stock', _productoActual.stock.toString(), icon: Icons.inventory_2, color: _productoActual.stock < 10 ? Colors.red : Colors.blue),
                _buildInfoRow('Estado', _productoActual.activo ? 'Activo' : 'Inactivo', icon: _productoActual.activo ? Icons.check_circle : Icons.cancel, color: _productoActual.activo ? Colors.green : Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Descripción:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  _productoActual.descripcion,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  'Fecha de Ingreso: ${_productoActual.fechaIngreso.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: color ?? Colors.indigo.shade300, size: 20),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: color ?? Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}