<?php
include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $UPC = $_POST['producto-id'];
    $nombre = $_POST['producto-nombre'];
    $tamaño = $_POST['producto-tamaño'];
    $embalaje = $_POST['producto-embalaje'];
    $marca = $_POST['producto-marca'];
    $id_Tipo = $_POST['producto-tipo'];

    if (empty($UPC)) {
        // Crear nuevo producto
        $sql = "INSERT INTO Producto (UPC, nombre, tamaño, embalaje, marca, id_Tipo) VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("issssi", $UPC, $nombre, $tamaño, $embalaje, $marca, $id_Tipo);
        if ($stmt->execute()) {
            echo "Producto creado con éxito";
        } else {
            echo "Error al crear producto: " . $conexion->error;
        }
    } else {
        // Modificar producto existente
        $sql = "UPDATE Producto SET nombre=?, tamaño=?, embalaje=?, marca=?, id_Tipo=? WHERE UPC=?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("sssiii", $nombre, $tamaño, $embalaje, $marca, $id_Tipo, $UPC);
        if ($stmt->execute()) {
            echo "Producto modificado con éxito";
        } else {
            echo "Error al modificar producto: " . $conexion->error;
        }
    }
}
?>
