<?php
include 'conexion.php';

$idTienda = intval($_GET['id']);
$query = "SELECT * FROM Producto WHERE id_Tienda = $idTienda";
$result = mysqli_query($conexion, $query);

$productos = [];
while ($row = mysqli_fetch_assoc($result)) {
    $productos[] = $row;
}

echo json_encode($productos);
?>
