<?php
include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $accion = $_POST['accion'];
    $id_Factura = isset($_POST['id_Factura']) ? $_POST['id_Factura'] : '';
    $UPC_Producto = isset($_POST['UPC_Producto']) ? $_POST['UPC_Producto'] : '';
    $cantidad = isset($_POST['cantidad']) ? $_POST['cantidad'] : '';
    $precio = isset($_POST['precio']) ? $_POST['precio'] : '';

    // Verificar que los campos requeridos están presentes
    if (($accion !== 'delete' && (empty($id_Factura) || empty($UPC_Producto))) || ($accion === 'delete' && empty($id_Factura))) {
        echo 'Todos los campos son requeridos para ' . $accion;
        exit;
    }

    // Preparar y ejecutar la consulta usando el procedimiento almacenado
    $stmt = $conexion->prepare("CALL GestionarDetalleFactura(?, ?, ?, ?, ?)");
    if (!$stmt) {
        echo 'Error en la preparación de la consulta: ' . $conexion->error;
        exit;
    }

    // Vincular parámetros y ejecutar la consulta
    $stmt->bind_param("siiid", $accion, $id_Factura, $UPC_Producto, $cantidad, $precio);
    if ($stmt->execute()) {
        echo ucfirst($accion) . ' detalle de factura realizado con éxito.';
    } else {
        echo 'Error al realizar la operación: ' . $stmt->error;
    }

    // Cerrar la declaración y la conexión
    $stmt->close();
    $conexion->close();
}
?>
