<?php
include 'conexion.php';

// Crear Factura
if ($_POST['action'] == 'create') {
    $query = "INSERT INTO Factura (idFactura, idCliente, fecha, total) VALUES (?, ?, ?, ?)";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param("iisi", $_POST['idFactura'], $_POST['idCliente'], $_POST['fecha'], $_POST['total']);
    $stmt->execute();
    echo "Factura creada";
}

// Modificar Factura
if ($_POST['action'] == 'update') {
    $query = "UPDATE Factura SET idCliente = ?, fecha = ?, total = ? WHERE idFactura = ?";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param("issi", $_POST['idCliente'], $_POST['fecha'], $_POST['total'], $_POST['idFactura']);
    $stmt->execute();
    echo "Factura modificada";
}

// Eliminar Factura
if ($_POST['action'] == 'delete') {
    $query = "DELETE FROM Factura WHERE idFactura = ?";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param("i", $_POST['idFactura']);
    $stmt->execute();
    echo "Factura eliminada";
}
?>
