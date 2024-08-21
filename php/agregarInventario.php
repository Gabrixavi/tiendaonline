<?php
include 'conexion.php';

// Depuración: Mostrar los datos recibidos
echo '<pre>';
print_r($_POST);
echo '</pre>';

// Recuperar los datos del formulario
$UPC = isset($_POST['UPC_Add']) ? $_POST['UPC_Add'] : '';
$id_Tienda = isset($_POST['id_Tienda_Add']) ? $_POST['id_Tienda_Add'] : '';
$cantidad = isset($_POST['cantidad_Add']) ? $_POST['cantidad_Add'] : '';

// Verificar que todos los campos requeridos están presentes y válidos
if (empty($UPC) || empty($id_Tienda) || empty($cantidad)) {
    echo 'Todos los campos son requeridos.';
    exit;
}

// Validar que la cantidad es un número positivo
if (!is_numeric($cantidad) || $cantidad <= 0) {
    echo 'La cantidad debe ser un número positivo.';
    exit;
}

// Preparar y ejecutar la consulta usando un procedimiento almacenado
$stmt = $conexion->prepare("CALL AgregarInventario(?, ?, ?)");
if (!$stmt) {
    echo 'Error en la preparación de la consulta: ' . $conexion->error;
    exit;
}

// Vincular parámetros y ejecutar la consulta
$stmt->bind_param("iii", $UPC, $id_Tienda, $cantidad);
if ($stmt->execute()) {
    echo 'Inventario agregado exitosamente.';
} else {
    echo 'Error al agregar el inventario: ' . $stmt->error;
}

// Cerrar la declaración y la conexión
$stmt->close();
$conexion->close();
?>
