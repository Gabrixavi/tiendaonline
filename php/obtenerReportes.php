<?php
include 'conexion.php';

// Obtener el inventario de productos
$query = "SELECT p.nombre, pt.cantidad
          FROM Producto_Tienda pt
          JOIN Producto p ON pt.UPC_Producto = p.UPC";
$result = $conexion->query($query);

$inventario = [];
while ($row = $result->fetch_assoc()) {
    $inventario[] = $row;
}

echo json_encode($inventario);
?>
