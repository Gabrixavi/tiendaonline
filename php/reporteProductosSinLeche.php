
<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Llamar al procedimiento almacenado para obtener los productos más comprados sin contar la leche
$query = "CALL ObtenerPrincipalesTiposProductosSinLeche()";
$result = $conexion->query($query);

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$productosSinLeche = [];
while ($row = $result->fetch_assoc()) {
    $productosSinLeche[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($productosSinLeche);

// Cerrar la conexión
$conexion->close();
?>
