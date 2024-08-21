<?php
// Incluir el archivo de conexión a la base de datos
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Crear una consulta para obtener todas las tiendas
$query = "SELECT id_Tienda, nombre_Tienda FROM Tienda";

// Ejecutar la consulta
$result = $conexion->query($query);

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$tiendas = [];

// Obtener cada fila de la consulta y agregarla al array
while ($row = $result->fetch_assoc()) {
    $tiendas[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($tiendas);

// Cerrar la conexión
$conexion->close();
?>
