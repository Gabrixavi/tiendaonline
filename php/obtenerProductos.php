<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Crear una consulta para obtener todos los productos
$query = "SELECT id_Producto, nombre, cantidad FROM Producto";

// Ejecutar la consulta
$result = $conexion->query($query);

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$productos = [];

// Obtener cada fila de la consulta y agregarla al array
while ($row = $result->fetch_assoc()) {
    $productos[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($productos);

// Cerrar la conexión
$conexion->close();
?>
