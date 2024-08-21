<?php
include 'conexion.php';

// Depuración: Mostrar los datos recibidos
echo '<pre>';
print_r($_POST);
echo '</pre>';

// Recuperar los datos del formulario
$id_Tienda = isset($_POST['id_Tienda_Update']) ? $_POST['id_Tienda_Update'] : '';
$UPC = isset($_POST['UPC']) ? $_POST['UPC'] : '';
$nuevaCantidad = isset($_POST['nuevaCantidad']) ? $_POST['nuevaCantidad'] : '';

// Verificar que todos los campos requeridos están presentes y válidos
if (empty($id_Tienda) || empty($UPC) || empty($nuevaCantidad)) {
    echo 'Todos los campos son requeridos.';
    exit;
}

// Validar que la nueva cantidad es un número positivo
if (!is_numeric($nuevaCantidad) || $nuevaCantidad <= 0) {
    echo 'La cantidad debe ser un número positivo.';
    exit;
}

// Preparar y ejecutar la consulta usando un procedimiento almacenado
$stmt = $conexion->prepare("CALL ActualizarCantidad(?, ?, ?)");
if (!$stmt) {
    echo 'Error en la preparación de la consulta: ' . $conexion->error;
    exit;
}

// Vincular parámetros y ejecutar la consulta
$stmt->bind_param("iii", $UPC, $id_Tienda, $nuevaCantidad);
if ($stmt->execute()) {
    echo 'Cantidad actualizada exitosamente.';
} else {
    echo 'Error al actualizar la cantidad: ' . $stmt->error;
}

// Cerrar la declaración y la conexión
$stmt->close();
$conexion->close();
?>
