
<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Llamar al procedimiento almacenado para obtener las tiendas con más ventas en el año
$query = "CALL ObtenerTiendasConMasVentas()";
$result = $conexion->query($query);

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$tiendasMasVentas = [];
while ($row = $result->fetch_assoc()) {
    $tiendasMasVentas[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($tiendasMasVentas);

// Cerrar la conexión
$conexion->close();
?>
