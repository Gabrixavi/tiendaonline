<?php
include 'conexion.php';

// Obtener el ID del cliente desde la solicitud GET
$id_Cliente = isset($_GET['id_Cliente']) ? $_GET['id_Cliente'] : '';

// Verificar que el ID del cliente es válido
if (empty($id_Cliente)) {
    echo json_encode([]);
    exit;
}

// Preparar y ejecutar la consulta
$sql = "SELECT * FROM Compras WHERE id_Cliente = ?";
$stmt = $conexion->prepare($sql);
if (!$stmt) {
    echo json_encode([]);
    exit;
}

$stmt->bind_param("i", $id_Cliente);
$stmt->execute();
$result = $stmt->get_result();

$compras = [];
while ($row = $result->fetch_assoc()) {
    $compras[] = $row;
}

// Devolver los resultados como JSON
echo json_encode($compras);

// Cerrar la declaración y la conexión
$stmt->close();
$conexion->close();
?>
