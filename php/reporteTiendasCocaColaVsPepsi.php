<?php
include 'conexion.php';

// Configurar el encabezado para que la respuesta sea en formato JSON
header('Content-Type: application/json');

// Llamar al procedimiento almacenado para obtener las tiendas donde se vende más Coca-Cola que Pepsi
$query = "
SELECT 
    t.nombre_Tienda AS Tienda,
    SUM(CASE WHEN p.marca = 'Coca-Cola' THEN pt.cantidad ELSE 0 END) AS CocaCola_En_Inventario,
    SUM(CASE WHEN p.marca = 'Pepsi' THEN pt.cantidad ELSE 0 END) AS Pepsi_En_Inventario
FROM 
    Producto_Tienda pt
JOIN 
    Tienda t ON pt.id_Tienda = t.id_Tienda
JOIN 
    Producto p ON pt.UPC_Producto = p.UPC
GROUP BY 
    t.nombre_Tienda
HAVING 
    CocaCola_En_Inventario > Pepsi_En_Inventario;
";

$result = $conexion->query($query);

// Verificar si la consulta se ejecutó correctamente
if ($result === false) {
    echo json_encode(['error' => $conexion->error]);
    exit();
}

// Crear un array para almacenar los resultados
$tiendasCocaColaVsPepsi = [];
while ($row = $result->fetch_assoc()) {
    $tiendasCocaColaVsPepsi[] = $row;
}

// Convertir el array a JSON y enviarlo como respuesta
echo json_encode($tiendasCocaColaVsPepsi);

// Cerrar la conexión
$conexion->close();
?>
