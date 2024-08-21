CREATE DATABASE tiendaonline;

USE tiendaonline;

CREATE TABLE Pais (
    id_Pais INT PRIMARY KEY AUTO_INCREMENT,
    nombre_Pais VARCHAR(200) NOT NULL
);


CREATE TABLE Departamento (
    id_Departamento INT PRIMARY KEY AUTO_INCREMENT,
    nombre_Departamento VARCHAR(200) NOT NULL,
    id_Pais INT NOT NULL,
    FOREIGN KEY (id_Pais) REFERENCES Pais(id_Pais)
);

CREATE TABLE Municipio (
    id_Municipio INT PRIMARY KEY AUTO_INCREMENT,
    nombre_Municipio VARCHAR(200) NOT NULL,
    id_Departamento INT NOT NULL,
    FOREIGN KEY (id_Departamento) REFERENCES Departamento(id_Departamento)
);

CREATE TABLE Cliente (
    id_Cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre1 VARCHAR(100) NOT NULL,
    nombre2 VARCHAR(100),
    apellido1 VARCHAR(100) NOT NULL,
    apellido2 VARCHAR(100),
    email VARCHAR(100) NOT NULL
);


CREATE TABLE Tipo (
    id_Tipo INT PRIMARY KEY AUTO_INCREMENT,
    nombre_Tipo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE Producto (
    UPC INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tamaño VARCHAR(50) NOT NULL,
    embalaje VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    id_Tipo INT NOT NULL,
    FOREIGN KEY (id_Tipo) REFERENCES Tipo(id_Tipo)
);



CREATE TABLE Proveedor (
    id_Proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    id_Producto INT NOT NULL,
    FOREIGN KEY (id_Producto) REFERENCES Producto(UPC)
);




CREATE TABLE Tienda (
    id_Tienda INT PRIMARY KEY AUTO_INCREMENT,
    nombre_Tienda VARCHAR(200) NOT NULL,
    id_Municipio INT NOT NULL,
    FOREIGN KEY (id_Municipio) REFERENCES Municipio(id_Municipio)
);


CREATE TABLE Compra (
    id_Compra INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    id_Cliente INT NOT NULL,
    id_Tienda INT NOT NULL,
    FOREIGN KEY (id_Cliente) REFERENCES Cliente(id_Cliente),
    FOREIGN KEY (id_Tienda) REFERENCES Tienda(id_Tienda)
);

CREATE TABLE Factura (
    id_Factura INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    ISV DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) GENERATED ALWAYS AS (subtotal + ISV) STORED,
    id_Compra INT NOT NULL,
    id_Tienda INT NOT NULL,
    id_Cliente INT NOT NULL,
    FOREIGN KEY (id_Compra) REFERENCES Compra(id_Compra),
    FOREIGN KEY (id_Tienda) REFERENCES Tienda(id_Tienda),
    FOREIGN KEY (id_Cliente) REFERENCES Cliente(id_Cliente)
);

CREATE TABLE Producto_Tienda (
    id_Producto_Tienda INT PRIMARY KEY AUTO_INCREMENT,
    UPC_Producto INT NOT NULL,
    id_Tienda INT NOT NULL,
    cantidad INT NOT NULL,
    FOREIGN KEY (UPC_Producto) REFERENCES Producto(UPC),
    FOREIGN KEY (id_Tienda) REFERENCES Tienda(id_Tienda)
);

CREATE TABLE Detalle_Factura (
    id_Detalle_Factura INT PRIMARY KEY AUTO_INCREMENT,
    cantidad INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    id_Factura INT NOT NULL,
    UPC_Producto INT NOT NULL,
    FOREIGN KEY (id_Factura) REFERENCES Factura(id_Factura),
    FOREIGN KEY (UPC_Producto) REFERENCES Producto(UPC)
);


CREATE TABLE Bitacora (
    id_Bitacora INT PRIMARY KEY AUTO_INCREMENT,
    tabla_afectada VARCHAR(100) NOT NULL,
    operacion VARCHAR(50) NOT NULL,
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE Producto ADD COLUMN precio DECIMAL(10, 2) NOT NULL DEFAULT 0.00;
























--PROCESOS ALMACENADOS EXTRAS

DELIMITER $$

CREATE PROCEDURE GestionarProducto(
    IN p_accion VARCHAR(10),
    IN p_UPC INT,
    IN p_nombre VARCHAR(100),
    IN p_tamaño VARCHAR(50),
    IN p_embalaje VARCHAR(50),
    IN p_marca VARCHAR(50),
    IN p_id_Tipo INT
)
BEGIN
    IF p_accion = 'create' THEN
        INSERT INTO Producto (UPC, nombre, tamaño, embalaje, marca, id_Tipo)
        VALUES (p_UPC, p_nombre, p_tamaño, p_embalaje, p_marca, p_id_Tipo);
    ELSEIF p_accion = 'update' THEN
        UPDATE Producto
        SET nombre = p_nombre, tamaño = p_tamaño, embalaje = p_embalaje, marca = p_marca, id_Tipo = p_id_Tipo
        WHERE UPC = p_UPC;
    ELSEIF p_accion = 'delete' THEN
        DELETE FROM Producto WHERE UPC = p_UPC;
    END IF;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE ObtenerTodosLosProductos()
BEGIN
    SELECT * FROM Producto;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE GestionarCliente(
    IN p_accion VARCHAR(10),
    IN p_id_Cliente INT,
    IN p_nombre1 VARCHAR(100),
    IN p_nombre2 VARCHAR(100),
    IN p_apellido1 VARCHAR(100),
    IN p_apellido2 VARCHAR(100),
    IN p_email VARCHAR(100)
)
BEGIN
    IF p_accion = 'create' THEN
        INSERT INTO Cliente (nombre1, nombre2, apellido1, apellido2, email)
        VALUES (p_nombre1, p_nombre2, p_apellido1, p_apellido2, p_email);
    ELSEIF p_accion = 'update' THEN
        UPDATE Cliente
        SET nombre1 = p_nombre1, nombre2 = p_nombre2, apellido1 = p_apellido1, apellido2 = p_apellido2, email = p_email
        WHERE id_Cliente = p_id_Cliente;
    ELSEIF p_accion = 'delete' THEN
        DELETE FROM Cliente WHERE id_Cliente = p_id_Cliente;
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ObtenerTodosLosClientes()
BEGIN
    SELECT * FROM Cliente;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE GestionarInventario(
    IN p_accion VARCHAR(10),
    IN p_UPC_Producto INT,
    IN p_id_Tienda INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_exists INT;

    IF p_accion = 'create' THEN
        -- Verificar si el producto ya existe en la tienda
        SELECT COUNT(*) INTO v_exists
        FROM Producto_Tienda
        WHERE UPC_Producto = p_UPC_Producto AND id_Tienda = p_id_Tienda;

        IF v_exists > 0 THEN
            -- Si el producto ya existe en la tienda, sumar la cantidad
            UPDATE Producto_Tienda
            SET cantidad = cantidad + p_cantidad
            WHERE UPC_Producto = p_UPC_Producto AND id_Tienda = p_id_Tienda;
        ELSE
            -- Si no existe, insertar un nuevo registro
            INSERT INTO Producto_Tienda (UPC_Producto, id_Tienda, cantidad)
            VALUES (p_UPC_Producto, p_id_Tienda, p_cantidad);
        END IF;

    ELSEIF p_accion = 'update' THEN
        -- Actualizar la cantidad del producto en la tienda
        UPDATE Producto_Tienda
        SET cantidad = p_cantidad
        WHERE UPC_Producto = p_UPC_Producto AND id_Tienda = p_id_Tienda;

    ELSEIF p_accion = 'delete' THEN
        -- Eliminar el producto de la tienda
        DELETE FROM Producto_Tienda 
        WHERE UPC_Producto = p_UPC_Producto AND id_Tienda = p_id_Tienda;

    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ObtenerTodoElInventario()
BEGIN
    SELECT * FROM Producto_Tienda;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ObtenerInventarioPorTienda(
    IN p_id_Tienda INT
)
BEGIN
    SELECT pt.UPC_Producto, p.nombre AS nombre_Producto, pt.cantidad 
    FROM Producto_Tienda pt
    JOIN Producto p ON pt.UPC_Producto = p.UPC
    WHERE pt.id_Tienda = p_id_Tienda;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE GestionarFactura(
    IN p_accion VARCHAR(10),
    IN p_id_Factura INT,
    IN p_fecha DATE,
    IN p_id_Cliente INT,
    IN p_subtotal DECIMAL(10,2),
    IN p_ISV DECIMAL(10,2),
    IN p_total DECIMAL(10,2)
)
BEGIN
    IF p_accion = 'create' THEN
        INSERT INTO Factura (fecha, id_Cliente, subtotal, ISV, total)
        VALUES (p_fecha, p_id_Cliente, p_subtotal, p_ISV, p_total);
    ELSEIF p_accion = 'update' THEN
        UPDATE Factura
        SET fecha = p_fecha, id_Cliente = p_id_Cliente, subtotal = p_subtotal, ISV = p_ISV, total = p_total
        WHERE id_Factura = p_id_Factura;
    ELSEIF p_accion = 'delete' THEN
        DELETE FROM Factura WHERE id_Factura = p_id_Factura;
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE GestionarDetalleFactura(
    IN p_accion VARCHAR(10),
    IN p_id_Factura INT,
    IN p_UPC_Producto INT,
    IN p_cantidad INT,
    IN p_precio DECIMAL(10,2)
)
BEGIN
    IF p_accion = 'create' THEN
        INSERT INTO Detalle_Factura (id_Factura, UPC_Producto, cantidad, precio)
        VALUES (p_id_Factura, p_UPC_Producto, p_cantidad, p_precio);
    ELSEIF p_accion = 'delete' THEN
        DELETE FROM Detalle_Factura WHERE id_Factura = p_id_Factura AND UPC_Producto = p_UPC_Producto;
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ObtenerTodasLasFacturas()
BEGIN
    SELECT f.id_Factura, f.fecha, c.nombre1 AS nombre_Cliente, f.total 
    FROM Factura f
    JOIN Cliente c ON f.id_Cliente = c.id_Cliente;
END $$

DELIMITER ;


DELIMITER //

CREATE PROCEDURE CrearDetalleCompra(
    IN p_compraId INT,
    IN p_productoId INT,
    IN p_cantidad INT,
    IN p_precio DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Detalle_Compra (id_Compra, UPC_Producto, cantidad, precio)
    VALUES (p_compraId, p_productoId, p_cantidad, p_precio);
END;

DELIMITER ;


DELIMITER //

CREATE PROCEDURE ObtenerProductosParaCompra()
BEGIN
    SELECT UPC, nombre, precio 
    FROM Producto;
END //

DELIMITER ;





















DELIMITER $$

-- Procedimientos para la entidad Cliente
CREATE PROCEDURE CrearCliente(
    IN p_nombre1 VARCHAR(100),
    IN p_nombre2 VARCHAR(100),
    IN p_apellido1 VARCHAR(100),
    IN p_apellido2 VARCHAR(100),
    IN p_email VARCHAR(100)
)
BEGIN
    INSERT INTO Cliente (nombre1, nombre2, apellido1, apellido2, email)
    VALUES (p_nombre1, p_nombre2, p_apellido1, p_apellido2, p_email);
END $$

CREATE PROCEDURE ModificarCliente(
    IN p_id_Cliente INT,
    IN p_nombre1 VARCHAR(100),
    IN p_nombre2 VARCHAR(100),
    IN p_apellido1 VARCHAR(100),
    IN p_apellido2 VARCHAR(100),
    IN p_email VARCHAR(100)
)
BEGIN
    UPDATE Cliente
    SET nombre1 = p_nombre1, nombre2 = p_nombre2, apellido1 = p_apellido1, apellido2 = p_apellido2, email = p_email
    WHERE id_Cliente = p_id_Cliente;
END $$

CREATE PROCEDURE EliminarCliente(
    IN p_id_Cliente INT
)
BEGIN
    DELETE FROM Cliente WHERE id_Cliente = p_id_Cliente;
END $$

-- Procedimientos para la entidad Pais
CREATE PROCEDURE CrearPais(
    IN p_nombre_Pais VARCHAR(200)
)
BEGIN
    INSERT INTO Pais (nombre_Pais)
    VALUES (p_nombre_Pais);
END $$

CREATE PROCEDURE ModificarPais(
    IN p_id_Pais INT,
    IN p_nombre_Pais VARCHAR(200)
)
BEGIN
    UPDATE Pais
    SET nombre_Pais = p_nombre_Pais
    WHERE id_Pais = p_id_Pais;
END $$

CREATE PROCEDURE EliminarPais(
    IN p_id_Pais INT
)
BEGIN
    DELETE FROM Pais WHERE id_Pais = p_id_Pais;
END $$

-- Procedimientos para la entidad Departamento
CREATE PROCEDURE CrearDepartamento(
    IN p_nombre_Departamento VARCHAR(200),
    IN p_id_Pais INT
)
BEGIN
    INSERT INTO Departamento (nombre_Departamento, id_Pais)
    VALUES (p_nombre_Departamento, p_id_Pais);
END $$

CREATE PROCEDURE ModificarDepartamento(
    IN p_id_Departamento INT,
    IN p_nombre_Departamento VARCHAR(200),
    IN p_id_Pais INT
)
BEGIN
    UPDATE Departamento
    SET nombre_Departamento = p_nombre_Departamento, id_Pais = p_id_Pais
    WHERE id_Departamento = p_id_Departamento;
END $$

CREATE PROCEDURE EliminarDepartamento(
    IN p_id_Departamento INT
)
BEGIN
    DELETE FROM Departamento WHERE id_Departamento = p_id_Departamento;
END $$

-- Procedimientos para la entidad Municipio
CREATE PROCEDURE CrearMunicipio(
    IN p_nombre_Municipio VARCHAR(200),
    IN p_id_Departamento INT
)
BEGIN
    INSERT INTO Municipio (nombre_Municipio, id_Departamento)
    VALUES (p_nombre_Municipio, p_id_Departamento);
END $$

CREATE PROCEDURE ModificarMunicipio(
    IN p_id_Municipio INT,
    IN p_nombre_Municipio VARCHAR(200),
    IN p_id_Departamento INT
)
BEGIN
    UPDATE Municipio
    SET nombre_Municipio = p_nombre_Municipio, id_Departamento = p_id_Departamento
    WHERE id_Municipio = p_id_Municipio;
END $$

CREATE PROCEDURE EliminarMunicipio(
    IN p_id_Municipio INT
)
BEGIN
    DELETE FROM Municipio WHERE id_Municipio = p_id_Municipio;
END $$

-- Procedimientos para la entidad Tienda
CREATE PROCEDURE CrearTienda(
    IN p_nombre_Tienda VARCHAR(200),
    IN p_id_Municipio INT
)
BEGIN
    INSERT INTO Tienda (nombre_Tienda, id_Municipio)
    VALUES (p_nombre_Tienda, p_id_Municipio);
END $$

CREATE PROCEDURE ModificarTienda(
    IN p_id_Tienda INT,
    IN p_nombre_Tienda VARCHAR(200),
    IN p_id_Municipio INT
)
BEGIN
    UPDATE Tienda
    SET nombre_Tienda = p_nombre_Tienda, id_Municipio = p_id_Municipio
    WHERE id_Tienda = p_id_Tienda;
END $$

CREATE PROCEDURE EliminarTienda(
    IN p_id_Tienda INT
)
BEGIN
    DELETE FROM Tienda WHERE id_Tienda = p_id_Tienda;
END $$

-- Procedimientos para la entidad Tipo
CREATE PROCEDURE CrearTipo(
    IN p_nombre_Tipo VARCHAR(100),
    IN p_descripcion VARCHAR(255)
)
BEGIN
    INSERT INTO Tipo (nombre_Tipo, descripcion)
    VALUES (p_nombre_Tipo, p_descripcion);
END $$

CREATE PROCEDURE ModificarTipo(
    IN p_id_Tipo INT,
    IN p_nombre_Tipo VARCHAR(100),
    IN p_descripcion VARCHAR(255)
)
BEGIN
    UPDATE Tipo
    SET nombre_Tipo = p_nombre_Tipo, descripcion = p_descripcion
    WHERE id_Tipo = p_id_Tipo;
END $$

CREATE PROCEDURE EliminarTipo(
    IN p_id_Tipo INT
)
BEGIN
    DELETE FROM Tipo WHERE id_Tipo = p_id_Tipo;
END $$

-- Procedimientos para la entidad Producto
CREATE PROCEDURE CrearProducto(
    IN p_UPC INT,
    IN p_nombre VARCHAR(100),
    IN p_tamaño VARCHAR(50),
    IN p_embalaje VARCHAR(50),
    IN p_marca VARCHAR(50),
    IN p_id_Tipo INT
)
BEGIN
    INSERT INTO Producto (UPC, nombre, tamaño, embalaje, marca, id_Tipo)
    VALUES (p_UPC, p_nombre, p_tamaño, p_embalaje, p_marca, p_id_Tipo);
END $$

CREATE PROCEDURE ModificarProducto(
    IN p_UPC INT,
    IN p_nombre VARCHAR(100),
    IN p_tamaño VARCHAR(50),
    IN p_embalaje VARCHAR(50),
    IN p_marca VARCHAR(50),
    IN p_id_Tipo INT
)
BEGIN
    UPDATE Producto
    SET nombre = p_nombre, tamaño = p_tamaño, embalaje = p_embalaje, marca = p_marca, id_Tipo = p_id_Tipo
    WHERE UPC = p_UPC;
END $$

CREATE PROCEDURE EliminarProducto(
    IN p_UPC INT
)
BEGIN
    DELETE FROM Producto WHERE UPC = p_UPC;
END $$

-- Procedimientos para la entidad Proveedor
CREATE PROCEDURE CrearProveedor(
    IN p_nombre VARCHAR(100),
    IN p_id_Producto INT
)
BEGIN
    INSERT INTO Proveedor (nombre, id_Producto)
    VALUES (p_nombre, p_id_Producto);
END $$

CREATE PROCEDURE ModificarProveedor(
    IN p_id_Proveedor INT,
    IN p_nombre VARCHAR(100),
    IN p_id_Producto INT
)
BEGIN
    UPDATE Proveedor
    SET nombre = p_nombre, id_Producto = p_id_Producto
    WHERE id_Proveedor = p_id_Proveedor;
END $$

CREATE PROCEDURE EliminarProveedor(
    IN p_id_Proveedor INT
)
BEGIN
    DELETE FROM Proveedor WHERE id_Proveedor = p_id_Proveedor;
END $$

-- Procedimientos para la entidad Compra

CREATE PROCEDURE CrearCompra(
    IN p_clienteId INT,
    IN p_tiendaId INT,
    OUT p_idCompra INT
)
BEGIN
    INSERT INTO Compra (id_Cliente, id_Tienda, fecha)
    VALUES (p_clienteId, p_tiendaId, NOW());

    SET p_idCompra = LAST_INSERT_ID();
END $$

CREATE PROCEDURE ModificarCompra(
    IN p_id_Compra INT,
    IN p_fecha DATE,
    IN p_id_Cliente INT
)
BEGIN
    UPDATE Compra
    SET fecha = p_fecha, id_Cliente = p_id_Cliente
    WHERE id_Compra = p_id_Compra;
END $$

CREATE PROCEDURE EliminarCompra(
    IN p_id_Compra INT
)
BEGIN
    DELETE FROM Compra WHERE id_Compra = p_id_Compra;
END $$

DELIMITER ;



DELIMITER //

-- Procedimientos para la entidad Factura
CREATE PROCEDURE CrearFactura(
    IN p_fecha DATE,
    IN p_subtotal DECIMAL(10, 2),
    IN p_ISV DECIMAL(10, 2),
    IN p_id_Compra INT,
    IN p_id_Tienda INT
)
BEGIN
    INSERT INTO Factura (fecha, subtotal, ISV, id_Compra, id_Tienda)
    VALUES (p_fecha, p_subtotal, p_ISV, p_id_Compra, p_id_Tienda);
END //

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ModificarFactura(
    IN p_id_Factura INT,
    IN p_fecha DATE,
    IN p_subtotal DECIMAL(10, 2),
    IN p_ISV DECIMAL(10, 2),
    IN p_id_Compra INT,
    IN p_id_Tienda INT
)
BEGIN
    UPDATE Factura
    SET fecha = p_fecha, subtotal = p_subtotal, ISV = p_ISV, id_Compra = p_id_Compra, id_Tienda = p_id_Tienda
    WHERE id_Factura = p_id_Factura;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE EliminarFactura(
    IN p_id_Factura INT
)
BEGIN
    DELETE FROM Factura WHERE id_Factura = p_id_Factura;
END $$

DELIMITER ;


-- Procedimientos para la entidad Detalle_Factura
DELIMITER $$

CREATE PROCEDURE CrearDetalleFactura(
    IN p_cantidad INT,
    IN p_precio DECIMAL(10, 2),
    IN p_id_Factura INT,
    IN p_UPC_Producto INT
)
BEGIN
    INSERT INTO Detalle_Factura (cantidad, precio, id_Factura, UPC_Producto)
    VALUES (p_cantidad, p_precio, p_id_Factura, p_UPC_Producto);
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ModificarDetalleFactura(
    IN p_id_Detalle_Factura INT,
    IN p_cantidad INT,
    IN p_precio DECIMAL(10, 2),
    IN p_id_Factura INT,
    IN p_UPC_Producto INT
)
BEGIN
    UPDATE Detalle_Factura
    SET cantidad = p_cantidad, precio = p_precio, id_Factura = p_id_Factura, UPC_Producto = p_UPC_Producto
    WHERE id_Detalle_Factura = p_id_Detalle_Factura;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE EliminarDetalleFactura(
    IN p_id_Detalle_Factura INT
)
BEGIN
    DELETE FROM Detalle_Factura WHERE id_Detalle_Factura = p_id_Detalle_Factura;
END $$

DELIMITER ;































DELIMITER $$

-- Triggers para la entidad Cliente
CREATE TRIGGER after_cliente_insert
AFTER INSERT ON Cliente
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Cliente', 'INSERT', NOW());
END $$

CREATE TRIGGER after_cliente_update
AFTER UPDATE ON Cliente
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Cliente', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_cliente_delete
AFTER DELETE ON Cliente
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Cliente', 'DELETE', NOW());
END $$

-- Triggers para la entidad Pais
CREATE TRIGGER after_pais_insert
AFTER INSERT ON Pais
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Pais', 'INSERT', NOW());
END $$

CREATE TRIGGER after_pais_update
AFTER UPDATE ON Pais
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Pais', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_pais_delete
AFTER DELETE ON Pais
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Pais', 'DELETE', NOW());
END $$

-- Triggers para la entidad Departamento
CREATE TRIGGER after_departamento_insert
AFTER INSERT ON Departamento
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Departamento', 'INSERT', NOW());
END $$

CREATE TRIGGER after_departamento_update
AFTER UPDATE ON Departamento
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Departamento', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_departamento_delete
AFTER DELETE ON Departamento
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Departamento', 'DELETE', NOW());
END $$

-- Triggers para la entidad Municipio
CREATE TRIGGER after_municipio_insert
AFTER INSERT ON Municipio
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Municipio', 'INSERT', NOW());
END $$

CREATE TRIGGER after_municipio_update
AFTER UPDATE ON Municipio
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Municipio', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_municipio_delete
AFTER DELETE ON Municipio
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Municipio', 'DELETE', NOW());
END $$

-- Triggers para la entidad Tienda
CREATE TRIGGER after_tienda_insert
AFTER INSERT ON Tienda
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Tienda', 'INSERT', NOW());
END $$

CREATE TRIGGER after_tienda_update
AFTER UPDATE ON Tienda
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Tienda', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_tienda_delete
AFTER DELETE ON Tienda
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Tienda', 'DELETE', NOW());
END $$

-- Triggers para la entidad Tipo
CREATE TRIGGER after_tipo_insert
AFTER INSERT ON Tipo
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Tipo', 'INSERT', NOW());
END $$

CREATE TRIGGER after_tipo_update
AFTER UPDATE ON Tipo
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Tipo', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_tipo_delete
AFTER DELETE ON Tipo
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Tipo', 'DELETE', NOW());
END $$

-- Triggers para la entidad Producto
CREATE TRIGGER after_producto_insert
AFTER INSERT ON Producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Producto', 'INSERT', NOW());
END $$

CREATE TRIGGER after_producto_update
AFTER UPDATE ON Producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Producto', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_producto_delete
AFTER DELETE ON Producto
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Producto', 'DELETE', NOW());
END $$

-- Triggers para la entidad Proveedor
CREATE TRIGGER after_proveedor_insert
AFTER INSERT ON Proveedor
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Proveedor', 'INSERT', NOW());
END $$

CREATE TRIGGER after_proveedor_update
AFTER UPDATE ON Proveedor
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Proveedor', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_proveedor_delete
AFTER DELETE ON Proveedor
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Proveedor', 'DELETE', NOW());
END $$

-- Triggers para la entidad Compra
CREATE TRIGGER after_compra_insert
AFTER INSERT ON Compra
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Compra', 'INSERT', NOW());
END $$

CREATE TRIGGER after_compra_update
AFTER UPDATE ON Compra
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Compra', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_compra_delete
AFTER DELETE ON Compra
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Compra', 'DELETE', NOW());
END $$

-- Triggers para la entidad Factura
CREATE TRIGGER after_factura_insert
AFTER INSERT ON Factura
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Factura', 'INSERT', NOW());
END $$

CREATE TRIGGER after_factura_update
AFTER UPDATE ON Factura
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Factura', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_factura_delete
AFTER DELETE ON Factura
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Factura', 'DELETE', NOW());
END $$

-- Triggers para la entidad Detalle_Factura
CREATE TRIGGER after_detalle_factura_insert
AFTER INSERT ON Detalle_Factura
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Detalle_Factura', 'INSERT', NOW());
END $$

CREATE TRIGGER after_detalle_factura_update
AFTER UPDATE ON Detalle_Factura
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Detalle_Factura', 'UPDATE', NOW());
END $$

CREATE TRIGGER after_detalle_factura_delete
AFTER DELETE ON Detalle_Factura
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (tabla_afectada, operacion, fecha_operacion)
    VALUES ('Detalle_Factura', 'DELETE', NOW());
END $$

DELIMITER ;

































CREATE VIEW InventarioProductos AS
SELECT 
    t.nombre_Tienda AS Tienda,
    p.nombre AS Producto,
    pt.cantidad AS Cantidad
FROM 
    Producto_Tienda pt
JOIN 
    Producto p ON pt.UPC_Producto = p.UPC
JOIN 
    Tienda t ON pt.id_Tienda = t.id_Tienda;



CREATE VIEW ComprasPorCliente AS
SELECT 
    c.nombre1 AS Nombre_Cliente,
    c.apellido1 AS Apellido_Cliente,
    f.fecha AS Fecha_Compra,
    f.total AS Total
FROM 
    Factura f
JOIN 
    Cliente c ON f.id_Cliente = c.id_Cliente;


CREATE VIEW HistorialVentasPorTienda AS
SELECT 
    t.nombre_Tienda AS Tienda,
    f.fecha AS Fecha_Venta,
    p.nombre AS Producto,
    df.cantidad AS Cantidad,
    df.precio AS Precio,
    (df.cantidad * df.precio) AS Total
FROM 
    Factura f
JOIN 
    Tienda t ON f.id_Tienda = t.id_Tienda
JOIN 
    Detalle_Factura df ON f.id_Factura = df.id_Factura
JOIN 
    Producto p ON df.UPC_Producto = p.UPC;


CREATE VIEW ProductosMasVendidosPorTienda AS
SELECT 
    t.nombre_Tienda AS Tienda,
    p.nombre AS Producto,
    SUM(df.cantidad) AS Total_Vendido
FROM 
    Detalle_Factura df
JOIN 
    Factura f ON df.id_Factura = f.id_Factura
JOIN 
    Tienda t ON f.id_Tienda = t.id_Tienda
JOIN 
    Producto p ON df.UPC_Producto = p.UPC
GROUP BY 
    t.id_Tienda, p.UPC
ORDER BY 
    Total_Vendido DESC
LIMIT 20;



CREATE VIEW ProductosMasVendidosPorPais AS
SELECT 
    pa.nombre_Pais AS Pais,
    p.nombre AS Producto,
    SUM(df.cantidad) AS Total_Vendido
FROM 
    Detalle_Factura df
JOIN 
    Factura f ON df.id_Factura = f.id_Factura
JOIN 
    Tienda t ON f.id_Tienda = t.id_Tienda
JOIN 
    Municipio m ON t.id_Municipio = m.id_Municipio
JOIN 
    Departamento d ON m.id_Departamento = d.id_Departamento
JOIN 
    Pais pa ON d.id_Pais = pa.id_Pais
JOIN 
    Producto p ON df.UPC_Producto = p.UPC
GROUP BY 
    pa.id_Pais, p.UPC
ORDER BY 
    Total_Vendido DESC
LIMIT 20;



CREATE VIEW TiendasConMasVentas AS
SELECT 
    t.nombre_Tienda AS Tienda,
    SUM(f.total) AS Total_Ventas
FROM 
    Factura f
JOIN 
    Tienda t ON f.id_Tienda = t.id_Tienda
WHERE 
    YEAR(f.fecha) = YEAR(CURDATE())
GROUP BY 
    t.id_Tienda
ORDER BY 
    Total_Ventas DESC
LIMIT 5;


CREATE VIEW TiendasCocaColaVsPepsi AS
SELECT 
    t.nombre_Tienda AS Tienda,
    SUM(CASE WHEN p.marca = 'Coca-Cola' THEN df.cantidad ELSE 0 END) AS CocaCola_Vendido,
    SUM(CASE WHEN p.marca = 'Pepsi' THEN df.cantidad ELSE 0 END) AS Pepsi_Vendido
FROM 
    Detalle_Factura df
JOIN 
    Factura f ON df.id_Factura = f.id_Factura
JOIN 
    Tienda t ON f.id_Tienda = t.id_Tienda
JOIN 
    Producto p ON df.UPC_Producto = p.UPC
GROUP BY 
    t.id_Tienda
HAVING 
    CocaCola_Vendido > Pepsi_Vendido;


CREATE VIEW PrincipalesTiposProductosSinLeche AS
SELECT 
    tp.nombre_Tipo AS Tipo_Producto,
    SUM(df.cantidad) AS Total_Vendido
FROM 
    Detalle_Factura df
JOIN 
    Producto p ON df.UPC_Producto = p.UPC
JOIN 
    Tipo tp ON p.id_Tipo = tp.id_Tipo
WHERE 
    p.nombre != 'Leche'
GROUP BY 
    tp.id_Tipo
ORDER BY 
    Total_Vendido DESC
LIMIT 3;




DELIMITER $$

CREATE PROCEDURE ObtenerInventarioProductos()
BEGIN
    SELECT * FROM InventarioProductos;
END $$

DELIMITER ;


DELIMITER //

CREATE PROCEDURE ObtenerComprasPorCliente(IN p_idCliente INT)
BEGIN
    SELECT c.id_Compra, c.fecha, SUM(df.cantidad * df.precio) AS total
    FROM Compra c
    LEFT JOIN Factura f ON c.id_Compra = f.id_Compra
    LEFT JOIN Detalle_Factura df ON f.id_Factura = df.id_Factura
    WHERE c.id_Cliente = p_idCliente
    GROUP BY c.id_Compra, c.fecha;
END //

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE ObtenerProductosMasVendidosPorTienda()
BEGIN
    SELECT * FROM ProductosMasVendidosPorTienda;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ObtenerProductosMasVendidosPorPais()
BEGIN
    SELECT * FROM ProductosMasVendidosPorPais;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ObtenerTiendasConMasVentas()
BEGIN
    SELECT * FROM TiendasConMasVentas;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ObtenerTiendasCocaColaVsPepsi()
BEGIN
    SELECT * FROM TiendasCocaColaVsPepsi;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE ObtenerPrincipalesTiposProductosSinLeche()
BEGIN
    SELECT * FROM PrincipalesTiposProductosSinLeche;
END $$

DELIMITER ;

