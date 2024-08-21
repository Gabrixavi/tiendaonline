
<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Llamar al procedimiento almacenado para obtener el historial de ventas por tienda
$query = "CALL ObtenerHistorialVentasPorTienda()";
$result = $conexion->query($query);

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$historialVentas = [];
while ($row = $result->fetch_assoc()) {
    $historialVentas[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($historialVentas);

// Cerrar la conexión
$conexion->close();
?>
