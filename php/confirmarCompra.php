<?php
include 'conexion.php';

$clienteId = $_POST['clienteId'];
$tiendaId = $_POST['tiendaId'];
$productos = $_POST['productos'];

// Crear una nueva compra
$queryCompra = "INSERT INTO Compra (fecha, id_Cliente, id_Tienda) VALUES (NOW(), ?, ?)";
$stmtCompra = $conexion->prepare($queryCompra);
$stmtCompra->bind_param("ii", $clienteId, $tiendaId);

if ($stmtCompra->execute()) {
    $idCompra = $stmtCompra->insert_id; // Obtener el ID de la compra recién creada

    // Crear una nueva factura asociada a la compra
    $queryFactura = "INSERT INTO Factura (fecha, subtotal, ISV, total, id_Compra, id_Tienda, id_Cliente) VALUES (NOW(), 0, 0, 0, ?, ?, ?)";
    $stmtFactura = $conexion->prepare($queryFactura);
    $stmtFactura->bind_param("iii", $idCompra, $tiendaId, $clienteId);

    if ($stmtFactura->execute()) {
        $idFactura = $stmtFactura->insert_id; // Obtener el ID de la factura recién creada

        $subtotal = 0;

        // Insertar los detalles de la factura
        foreach ($productos as $producto) {
            $productoId = $producto['productoId'];
            $cantidad = $producto['cantidad'];
            $precio = $producto['precio'];

            $detalleQuery = "INSERT INTO Detalle_Factura (id_Factura, UPC_Producto, cantidad, precio) VALUES (?, ?, ?, ?)";
            $detalleStmt = $conexion->prepare($detalleQuery);
            $detalleStmt->bind_param("iiid", $idFactura, $productoId, $cantidad, $precio);
            $detalleStmt->execute();

            $subtotal += $cantidad * $precio;
        }

        // Calcular el ISV y el total
        $ISV = $subtotal * 0.15; // Suponiendo que el ISV es del 15%
        $total = $subtotal + $ISV;

        // Actualizar la factura con el subtotal, ISV y total calculados
        $updateQuery = "UPDATE Factura SET subtotal = ?, ISV = ?, total = ? WHERE id_Factura = ?";
        $updateStmt = $conexion->prepare($updateQuery);
        $updateStmt->bind_param("dddi", $subtotal, $ISV, $total, $idFactura);
        $updateStmt->execute();

        echo "Compra realizada con éxito.";
    } else {
        echo "Error al crear la factura: " . $stmtFactura->error;
    }
} else {
    echo "Error al crear la compra: " . $stmtCompra->error;
}

$conexion->close();
?>
