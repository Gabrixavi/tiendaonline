<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Llamar al procedimiento almacenado para obtener los productos
$query = "CALL ObtenerProductosParaCompra()";
$result = $conexion->query($query);

if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$productos = [];
while ($row = $result->fetch_assoc()) {
    $productos[] = [
        'UPC' => $row['UPC'],
        'nombre' => $row['nombre'],
        'precio' => $row['precio']
    ];
}

echo json_encode($productos);

$conexion->close();
?>
