<?php
include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $accion = $_POST['accion'];
    $UPC_Producto = isset($_POST['UPC_Producto']) ? $_POST['UPC_Producto'] : '';
    $id_Tienda = isset($_POST['id_Tienda']) ? $_POST['id_Tienda'] : '';
    $cantidad = isset($_POST['cantidad']) ? $_POST['cantidad'] : '';

    // Verificar que los campos requeridos están presentes
    if (empty($UPC_Producto) || empty($id_Tienda) || ($accion !== 'delete' && empty($cantidad))) {
        echo 'Todos los campos son requeridos para ' . $accion;
        exit;
    }

    // Preparar y ejecutar la consulta usando el procedimiento almacenado unificado
    $stmt = $conexion->prepare("CALL GestionarInventario(?, ?, ?, ?)");
    if (!$stmt) {
        echo 'Error en la preparación de la consulta: ' . $conexion->error;
        exit;
    }

    // Vincular parámetros y ejecutar la consulta
    $stmt->bind_param("siii", $accion, $UPC_Producto, $id_Tienda, $cantidad);
    if ($stmt->execute()) {
        echo ucfirst($accion) . ' inventario realizado con éxito.';
    } else {
        echo 'Error al realizar la operación: ' . $stmt->error;
    }

    // Cerrar la declaración y la conexión
    $stmt->close();
    $conexion->close();
}
?>
