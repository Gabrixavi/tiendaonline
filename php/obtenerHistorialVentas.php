<?php
include 'conexion.php';

// Recuperar el ID de la tienda del parámetro GET
$idTienda = isset($_GET['idTienda']) ? intval($_GET['idTienda']) : 0;

if ($idTienda <= 0) {
    echo json_encode(['error' => 'ID de tienda inválido']);
    exit;
}

// Llamar al procedimiento almacenado
$stmt = $conexion->prepare("CALL ObtenerHistorialVentasPorTienda(?)");
$stmt->bind_param("i", $idTienda);
$stmt->execute();

// Obtener los resultados
$result = $stmt->get_result();
$historial = [];

// Recorremos las filas del resultado
while ($row = $result->fetch_assoc()) {
    $historial[] = $row;
}

// Enviar los datos como JSON
echo json_encode($historial);

// Cerrar la declaración y la conexión
$stmt->close();
$conexion->close();
?>
