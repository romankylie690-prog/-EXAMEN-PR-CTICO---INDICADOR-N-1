<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *"); 
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once 'conexion.php'; // Incluye la clase de conexión

$conexionObj = new Conexion();
$db = $conexionObj->obtenerConexion();

// Obtener el método de la solicitud HTTP
$method = $_SERVER['REQUEST_METHOD'];

// Obtener datos del cuerpo de la solicitud
$data = json_decode(file_get_contents("php://input"));

// Función para enviar respuesta JSON
function sendResponse($status, $data) {
    http_response_code($status);
    echo json_encode($data);
    exit();
}

// =======================
//   VALIDACIÓN COMÚN
// =======================
function validarProducto($producto, $db, $isUpdate = false) {
    // 1. Campos obligatorios
    if (empty($producto->nombre) || empty($producto->descripcion) || empty($producto->codigo_barras) || empty($producto->categoria) || empty($producto->precio) || empty($producto->stock) || empty($producto->proveedor)) {
        sendResponse(400, array("message" => "Error: Todos los campos obligatorios deben ser llenados."));
    }

    // 2. Precio > 0
    if (!is_numeric($producto->precio) || $producto->precio <= 0) {
        sendResponse(400, array("message" => "Error: El precio debe ser un valor numérico positivo."));
    }

    // 3. Código de barras único
    $query = "SELECT id FROM productos WHERE codigo_barras = ?";
    if ($isUpdate && isset($producto->id)) {
        // Excluir el ID actual del producto en la verificación de unicidad
        $query .= " AND id != ?";
    }
    
    $stmt = $db->prepare($query);
    
    if ($isUpdate && isset($producto->id)) {
        $stmt->bind_param("si", $producto->codigo_barras, $producto->id);
    } else {
        $stmt->bind_param("s", $producto->codigo_barras);
    }
    
    $stmt->execute();
    $stmt->store_result();
    
    if ($stmt->num_rows > 0) {
        sendResponse(409, array("message" => "Error: El código de barras ya existe en el inventario."));
    }
    $stmt->close();
}


// =======================
//   MANEJO DE MÉTODOS
// =======================

switch ($method) {
    case 'GET': // READ
        $id = isset($_GET['id']) ? (int)$_GET['id'] : null;

        if ($id) {
            // Buscar por ID
            $stmt = $db->prepare("SELECT * FROM productos WHERE id = ? LIMIT 1");
            $stmt->bind_param("i", $id);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result->num_rows === 1) {
                $producto = $result->fetch_assoc();
                sendResponse(200, $producto);
            } else {
                sendResponse(404, array("message" => "Producto no encontrado."));
            }
        } else {
            // Listar todos los productos
            $result = $db->query("SELECT * FROM productos ORDER BY id DESC");
            $productos = array();

            while ($row = $result->fetch_assoc()) {
                $productos[] = $row;
            }
            sendResponse(200, $productos);
        }
        break;

    case 'POST': // CREATE
        if (empty($data)) {
            sendResponse(400, array("message" => "Error: Datos de producto no proporcionados."));
        }
        
        validarProducto($data, $db); // Aplica todas las validaciones

        $stmt = $db->prepare("INSERT INTO productos (nombre, descripcion, codigo_barras, categoria, precio, stock, proveedor) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssssdis", $data->nombre, $data->descripcion, $data->codigo_barras, $data->categoria, $data->precio, $data->stock, $data->proveedor);

        if ($stmt->execute()) {
            $data->id = $db->insert_id; // Devolver el ID generado
            sendResponse(201, array("message" => "Producto agregado exitosamente.", "producto" => $data));
        } else {
            sendResponse(500, array("message" => "Error al agregar producto: " . $stmt->error));
        }
        $stmt->close();
        break;

    case 'PUT': // UPDATE
        if (empty($data) || empty($data->id)) {
            sendResponse(400, array("message" => "Error: ID y/o datos del producto son requeridos para actualizar."));
        }
        
        validarProducto($data, $db, true); // Aplica validaciones, incluyendo la exclusión del ID actual

        $stmt = $db->prepare("UPDATE productos SET nombre = ?, descripcion = ?, codigo_barras = ?, categoria = ?, precio = ?, stock = ?, proveedor = ?, activo = ? WHERE id = ?");
        $stmt->bind_param("ssssdisii", $data->nombre, $data->descripcion, $data->codigo_barras, $data->categoria, $data->precio, $data->stock, $data->proveedor, $data->activo, $data->id);

        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                sendResponse(200, array("message" => "Producto actualizado exitosamente.", "producto" => $data));
            } else {
                // Puede ser que el producto no exista o no se haya cambiado nada
                sendResponse(200, array("message" => "Actualización exitosa (0 filas modificadas, producto podría ser el mismo)."));
            }
        } else {
            sendResponse(500, array("message" => "Error al actualizar producto: " . $stmt->error));
        }
        $stmt->close();
        break;

    case 'DELETE': // DELETE
        $id = isset($_GET['id']) ? (int)$_GET['id'] : null;

        if (!$id) {
            sendResponse(400, array("message" => "Error: ID del producto es requerido para eliminar."));
        }

        // Se usa un DELETE físico, según el requerimiento. (Se podría usar UPDATE activo=FALSE para un borrado lógico)
        $stmt = $db->prepare("DELETE FROM productos WHERE id = ?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                sendResponse(200, array("message" => "Producto con ID $id eliminado exitosamente."));
            } else {
                sendResponse(404, array("message" => "Producto con ID $id no encontrado para eliminar."));
            }
        } else {
            sendResponse(500, array("message" => "Error al eliminar producto: " . $stmt->error));
        }
        $stmt->close();
        break;
        
    case 'OPTIONS':
        // Manejo de peticiones OPTIONS para CORS (preflight requests)
        sendResponse(204, null); // No Content
        break;

    default:
        // Método no permitido
        sendResponse(405, array("message" => "Método no permitido."));
        break;
}

$conexionObj->cerrarConexion(); // Cierra la conexión al finalizar
?>