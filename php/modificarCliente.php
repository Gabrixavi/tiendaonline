<?php
include 'conexion.php';

// Depuración: Mostrar los datos recibidos
echo '<pre>';
print_r($_POST);
echo '</pre>';

// Recuperar los datos del formulario
$id_Cliente = isset($_POST['id_Cliente']) ? intval($_POST['id_Cliente']) : 0;
$nombre1 = isset($_POST['nombre1']) ? $_POST['nombre1'] : '';
$nombre2 = isset($_POST['nombre2']) ? $_POST['nombre2'] : '';
$apellido1 = isset($_POST['apellido1']) ? $_POST['apellido1'] : '';
$apellido2 = isset($_POST['apellido2']) ? $_POST['apellido2'] : '';
$email = isset($_POST['email']) ? $_POST['email'] : '';

// Verificar que todos los campos requeridos están presentes
if ($id_Cliente <= 0 || empty($nombre1) || empty($apellido1) || empty($email)) {
    echo 'Todos los campos son requeridos.';
    exit;
}

// Preparar y ejecutar la consulta usando un procedimiento almacenado
$stmt = $conexion->prepare("CALL ModificarCliente(?, ?, ?, ?, ?, ?)");
if (!$stmt) {
    echo 'Error en la preparación de la consulta: ' . $conexion->error;
    exit;
}

// Vincular parámetros y ejecutar la consulta
$stmt->bind_param("isssss", $id_Cliente, $nombre1, $nombre2, $apellido1, $apellido2, $email);
if ($stmt->execute()) {
    echo 'Cliente modificado exitosamente.';
} else {
    echo 'Error al modificar el cliente: ' . $stmt->error;
}

// Cerrar la declaración y la conexión
$stmt->close();
$conexion->close();
?>
