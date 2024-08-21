<?php
include 'conexion.php';

// Crear Producto
if ($_POST['action'] == 'create') {
    $query = "INSERT INTO Producto (UPC, nombre, tamaño, embalaje, marca, id_Tipo) VALUES (?, ?, ?, ?, ?, ?)";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param("issssi", $_POST['UPC'], $_POST['nombre'], $_POST['tamaño'], $_POST['embalaje'], $_POST['marca'], $_POST['id_Tipo']);
    $stmt->execute();
    echo "Producto creado";
}

// Modificar Producto
if ($_POST['action'] == 'update') {
    $query = "UPDATE Producto SET nombre = ?, tamaño = ?, embalaje = ?, marca = ?, id_Tipo = ? WHERE UPC = ?";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param("ssssi", $_POST['nombre'], $_POST['tamaño'], $_POST['embalaje'], $_POST['marca'], $_POST['id_Tipo'], $_POST['UPC']);
    $stmt->execute();
    echo "Producto modificado";
}

// Eliminar Producto
if ($_POST['action'] == 'delete') {
    $query = "DELETE FROM Producto WHERE UPC = ?";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param("i", $_POST['UPC']);
    $stmt->execute();
    echo "Producto eliminado";
}
?>
