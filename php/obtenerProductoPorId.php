<?php
include 'conexion.php';

$id = $_GET['id'];

$sql = "SELECT * FROM Producto WHERE UPC = ?";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("i", $id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $producto = $result->fetch_assoc();
    echo json_encode($producto);
} else {
    echo json_encode([]);
}
?>
