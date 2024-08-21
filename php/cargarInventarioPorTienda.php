<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Recuperar el ID de la tienda desde la solicitud
$id_Tienda = isset($_GET['id_Tienda']) ? $_GET['id_Tienda'] : '';

// Verificar que se haya proporcionado un ID de tienda
if (empty($id_Tienda)) {
    echo json_encode(['error' => 'ID de tienda requerido.']);
    exit();
}

// Llamar al procedimiento almacenado para obtener el inventario de la tienda seleccionada
$stmt = $conexion->prepare("CALL ObtenerInventarioPorTienda(?)");
$stmt->bind_param("i", $id_Tienda);
$stmt->execute();
$result = $stmt->get_result();

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$inventario = [];
while ($row = $result->fetch_assoc()) {
    $inventario[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($inventario);

// Cerrar la conexión
$stmt->close();
$conexion->close();
?>
