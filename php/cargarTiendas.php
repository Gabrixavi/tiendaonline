<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Consultar todas las tiendas
$query = "SELECT id_Tienda, nombre_Tienda FROM Tienda";
$result = $conexion->query($query);

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$tiendas = [];
while ($row = $result->fetch_assoc()) {
    $tiendas[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($tiendas);

// Cerrar la conexión
$conexion->close();
?>
