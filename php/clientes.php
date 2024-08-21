<?php
include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $accion = $_POST['accion'];
    $id_Cliente = isset($_POST['id_Cliente']) ? $_POST['id_Cliente'] : '';
    $nombre1 = isset($_POST['nombre1']) ? $_POST['nombre1'] : '';
    $nombre2 = isset($_POST['nombre2']) ? $_POST['nombre2'] : '';
    $apellido1 = isset($_POST['apellido1']) ? $_POST['apellido1'] : '';
    $apellido2 = isset($_POST['apellido2']) ? $_POST['apellido2'] : '';
    $email = isset($_POST['email']) ? $_POST['email'] : '';

    // Verificar que los campos requeridos están presentes
    if (($accion !== 'delete' && (empty($nombre1) || empty($apellido1) || empty($email))) || ($accion === 'delete' && empty($id_Cliente))) {
        echo 'Todos los campos son requeridos para ' . $accion;
        exit;
    }

    // Preparar y ejecutar la consulta usando el procedimiento almacenado unificado
    $stmt = $conexion->prepare("CALL GestionarCliente(?, ?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        echo 'Error en la preparación de la consulta: ' . $conexion->error;
        exit;
    }

    // Vincular parámetros y ejecutar la consulta
    $stmt->bind_param("sisssss", $accion, $id_Cliente, $nombre1, $nombre2, $apellido1, $apellido2, $email);
    if ($stmt->execute()) {
        echo ucfirst($accion) . ' cliente realizado con éxito.';
    } else {
        echo 'Error al realizar la operación: ' . $stmt->error;
    }

    // Cerrar la declaración y la conexión
    $stmt->close();
    $conexion->close();
}
?>
