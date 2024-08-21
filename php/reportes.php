<?php
include 'conexion.php';

header('Content-Type: application/json');

// Reporte de Inventario de Productos
if ($_GET['action'] == 'inventarioProductos') {
    $query = "SELECT * FROM Producto_Tienda";
    $result = $conexion->query($query);
    
    $inventario = array();
    while ($row = $result->fetch_assoc()) {
        $inventario[] = $row;
    }
    
    echo json_encode($inventario);
}

// Reporte de Compras por Cliente
if ($_GET['action'] == 'comprasPorCliente') {
    $query = "SELECT idCliente, COUNT(idFactura) as cantidad_compras FROM Factura GROUP BY idCliente";
    $result = $conexion->query($query);
    
    $compras = array();
    while ($row = $result->fetch_assoc()) {
        $compras[] = $row;
    }
    
    echo json_encode($compras);
}

// Reporte de Historial de Ventas por Tienda
if ($_GET['action'] == 'historialVentasTienda') {
    $query = "SELECT id_Tienda, SUM(total) as total_ventas FROM Factura GROUP BY id_Tienda";
    $result = $conexion->query($query);
    
    $ventas = array();
    while ($row = $result->fetch_assoc()) {
        $ventas[] = $row;
    }
    
    echo json_encode($ventas);
}

// Reporte de Los 20 Productos Más Vendidos en Cada Tienda
if ($_GET['action'] == 'productosMasVendidosTienda') {
    $query = "SELECT id_Tienda, UPC_Producto, COUNT(*) as cantidad_vendida FROM Detalle_Factura GROUP BY id_Tienda, UPC_Producto ORDER BY cantidad_vendida DESC LIMIT 20";
    $result = $conexion->query($query);
    
    $productos = array();
    while ($row = $result->fetch_assoc()) {
        $productos[] = $row;
    }
    
    echo json_encode($productos);
}

// Reporte de Los 20 Productos Más Vendidos en Cada País
if ($_GET['action'] == 'productosMasVendidosPais') {
    $query = "SELECT p.id_Pais, d.UPC_Producto, COUNT(*) as cantidad_vendida
              FROM Detalle_Factura d
              JOIN Factura f ON d.idFactura = f.idFactura
              JOIN Tienda t ON f.id_Tienda = t.id_Tienda
              JOIN Pais p ON t.id_Pais = p.id_Pais
              GROUP BY p.id_Pais, d.UPC_Producto
              ORDER BY cantidad_vendida DESC LIMIT 20";
    $result = $conexion->query($query);
    
    $productos = array();
    while ($row = $result->fetch_assoc()) {
        $productos[] = $row;
    }
    
    echo json_encode($productos);
}

// Reporte de Las 5 Tiendas con Más Ventas en lo que va del Año
if ($_GET['action'] == 'tiendasMasVentasAnio') {
    $query = "SELECT id_Tienda, SUM(total) as total_ventas
              FROM Factura
              WHERE YEAR(fecha) = YEAR(CURDATE())
              GROUP BY id_Tienda
              ORDER BY total_ventas DESC LIMIT 5";
    $result = $conexion->query($query);
    
    $tiendas = array();
    while ($row = $result->fetch_assoc()) {
        $tiendas[] = $row;
    }
    
    echo json_encode($tiendas);
}

// Reporte de Las Tiendas que Venden Coca-Cola Más que Pepsi
if ($_GET['action'] == 'tiendasCocaColaVsPepsi') {
    $query = "SELECT t.id_Tienda, SUM(CASE WHEN p.marca = 'Coca-Cola' THEN 1 ELSE 0 END) as cantidad_coca_cola,
              SUM(CASE WHEN p.marca = 'Pepsi' THEN 1 ELSE 0 END) as cantidad_pepsi
              FROM Producto_Tienda pt
              JOIN Producto p ON pt.UPC_Producto = p.UPC
              JOIN Tienda t ON pt.id_Tienda = t.id_Tienda
              GROUP BY t.id_Tienda
              HAVING cantidad_coca_cola > cantidad_pepsi";
    $result = $conexion->query($query);
    
    $tiendas = array();
    while ($row = $result->fetch_assoc()) {
        $tiendas[] = $row;
    }
    
    echo json_encode($tiendas);
}

// Reporte de Los 3 Principales Tipos de Productos que los Clientes Compran Además de la Leche
if ($_GET['action'] == 'tiposProductosNoLeche') {
    $query = "SELECT pt.id_Tipo, COUNT(*) as cantidad
              FROM Detalle_Factura df
              JOIN Producto p ON df.UPC_Producto = p.UPC
              JOIN Producto_Tienda pt ON p.UPC = pt.UPC_Producto
              WHERE p.nombre != 'Leche'
              GROUP BY pt.id_Tipo
              ORDER BY cantidad DESC LIMIT 3";
    $result = $conexion->query($query);
    
    $tipos = array();
    while ($row = $result->fetch_assoc()) {
        $tipos[] = $row;
    }
    
    echo json_encode($tipos);
}
?>
