<?php
// Configuración de la Base de Datos
define('DB_HOST', 'localhost'); // Cambiar si es necesario
define('DB_USER', 'root');      // Usuario de MySQL
define('DB_PASS', '');          // Contraseña de MySQL
define('DB_NAME', 'inventario_tienda'); // Nombre de la BD

// Clase de Conexión
class Conexion {
    private $connect;

    public function __construct() {
        try {
            // Se utiliza mysqli para la conexión
            $this->connect = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

            // Verificar la conexión
            if ($this->connect->connect_error) {
                // Manejo de error de conexión
                http_response_code(500); // Internal Server Error
                die(json_encode(array("error" => "Error de conexión a la base de datos: " . $this->connect->connect_error)));
            }
            
            // Establecer el juego de caracteres a UTF8
            $this->connect->set_charset("utf8");

        } catch (Exception $e) {
            http_response_code(500);
            die(json_encode(array("error" => "Excepción de conexión: " . $e->getMessage())));
        }
    }

    public function obtenerConexion() {
        return $this->connect;
    }

    public function cerrarConexion() {
        $this->connect->close();
    }
}
?>