<?php
include 'conexion.php';

// Verificar si se ha enviado el ID de la tienda
if (isset($_GET['id_Tienda'])) {
    $id_Tienda = intval($_GET['id_Tienda']);

    // Preparar y ejecutar la consulta
    $query = "SELECT p.nombre, pt.cantidad
              FROM Producto_Tienda pt
              JOIN Producto p ON pt.UPC_Producto = p.UPC
              WHERE pt.id_Tienda = ?";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param('i', $id_Tienda);
    $stmt->execute();
    $result = $stmt->get_result();

    // Obtener los datos
    $productos = [];
    while ($row = $result->fetch_assoc()) {
        $productos[] = $row;
    }

    // Enviar los datos en formato JSON
    echo json_encode($productos);
}
?>
