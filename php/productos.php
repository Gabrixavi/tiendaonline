<?php
include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $accion = $_POST['accion'];
    $UPC = isset($_POST['UPC']) ? $_POST['UPC'] : '';
    $nombre = isset($_POST['nombre']) ? $_POST['nombre'] : '';
    $tamaño = isset($_POST['tamaño']) ? $_POST['tamaño'] : '';
    $embalaje = isset($_POST['embalaje']) ? $_POST['embalaje'] : '';
    $marca = isset($_POST['marca']) ? $_POST['marca'] : '';
    $id_Tipo = isset($_POST['id_Tipo']) ? $_POST['id_Tipo'] : 0;

    // Verificar que los campos requeridos están presentes
    if (($accion !== 'delete' && (empty($UPC) || empty($nombre) || empty($tamaño) || empty($embalaje) || empty($marca) || empty($id_Tipo))) || ($accion === 'delete' && empty($UPC))) {
        echo 'Todos los campos son requeridos para ' . $accion;
        exit;
    }

    // Preparar y ejecutar la consulta usando el procedimiento almacenado unificado
    $stmt = $conexion->prepare("CALL GestionarProducto(?, ?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        echo 'Error en la preparación de la consulta: ' . $conexion->error;
        exit;
    }

    // Vincular parámetros y ejecutar la consulta
    $stmt->bind_param("sissssi", $accion, $UPC, $nombre, $tamaño, $embalaje, $marca, $id_Tipo);
    if ($stmt->execute()) {
        echo ucfirst($accion) . ' producto realizado con éxito.';
    } else {
        echo 'Error al realizar la operación: ' . $stmt->error;
    }

    // Cerrar la declaración y la conexión
    $stmt->close();
    $conexion->close();
}
?>
