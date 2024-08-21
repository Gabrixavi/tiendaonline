<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Llamar al procedimiento almacenado para obtener todas las facturas
$query = "CALL ObtenerTodasLasFacturas()";
$result = $conexion->query($query);

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$facturas = [];
while ($row = $result->fetch_assoc()) {
    $facturas[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($facturas);

// Cerrar la conexión
$conexion->close();
?>
