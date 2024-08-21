<?php

$host = "localhost";
$usuario = "root"; 
$contraseña = ""; 
$baseDeDatos = "tiendaonline"; 

// Crear la conexión
$conexion = new mysqli($host, $usuario, $contraseña, $baseDeDatos);

// Verificar la conexión
if ($conexion->connect_error) {
    // En un entorno de producción, considera registrar el error en lugar de mostrarlo
    die("Conexión fallida: " . $conexion->connect_error);
}

// Configurar el juego de caracteres
$conexion->set_charset("utf8");

// Opcional: incluir aquí otras configuraciones necesarias

// No cerrar la conexión aquí si se va a usar en otros archivos

?>
