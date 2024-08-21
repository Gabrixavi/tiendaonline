<?php
include 'conexion.php';

$idCliente = $_GET['idCliente'];

// Preparar la llamada al procedimiento almacenado con un parámetro
$stmtCompras = $conexion->prepare("CALL ObtenerComprasPorCliente(?)");
$stmtCompras->bind_param("i", $idCliente);
$stmtCompras->execute();
$resultCompras = $stmtCompras->get_result();

$compras = [];
while ($row = $resultCompras->fetch_assoc()) {
    $compras[] = $row;
}

$stmtCompras->close();
$conexion->close();

// Devolver los datos en formato JSON
echo json_encode($compras);
?>
