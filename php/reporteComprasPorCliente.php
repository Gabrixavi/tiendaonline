<?php
include 'conexion.php';

$idCliente = $_GET['idCliente'];

// Consulta para obtener las compras del cliente
$queryCompras = "
    SELECT c.id_Compra, c.fecha, SUM(df.cantidad * df.precio) AS total
    FROM Compra c
    LEFT JOIN Factura f ON c.id_Compra = f.id_Compra
    LEFT JOIN Detalle_Factura df ON f.id_Factura = df.id_Factura
    WHERE c.id_Cliente = ?
    GROUP BY c.id_Compra, c.fecha
";
$stmtCompras = $conexion->prepare($queryCompras);
$stmtCompras->bind_param("i", $idCliente);
$stmtCompras->execute();
$resultCompras = $stmtCompras->get_result();

$compras = [];
while ($row = $resultCompras->fetch_assoc()) {
    $compras[] = $row;
}

$stmtCompras->close();

// Consulta para obtener los detalles de cada compra
$queryDetalles = "
    SELECT df.id_Factura, p.nombre AS nombre_Producto, df.cantidad, df.precio
    FROM Detalle_Factura df
    JOIN Producto p ON df.UPC_Producto = p.UPC
    WHERE df.id_Factura IN (
        SELECT f.id_Factura
        FROM Factura f
        JOIN Compra c ON f.id_Compra = c.id_Compra
        WHERE c.id_Cliente = ?
    )
";
$stmtDetalles = $conexion->prepare($queryDetalles);
$stmtDetalles->bind_param("i", $idCliente);
$stmtDetalles->execute();
$resultDetalles = $stmtDetalles->get_result();

$detalles = [];
while ($row = $resultDetalles->fetch_assoc()) {
    $detalles[] = $row;
}

$stmtDetalles->close();
$conexion->close();

// Devolver los datos en un formato que el frontend pueda usar
echo json_encode([
    'compras' => $compras,
    'detalles' => $detalles
]);
?>
