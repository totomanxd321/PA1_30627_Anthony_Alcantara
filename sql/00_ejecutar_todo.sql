/* =========================================================
   PA1 - Programación Avanzada de Base de Datos (30627)
   Proyecto: TechStore Perú
   Integrante: Anthony Fernando Alcántara Valencia
   Script 01: Base de datos y modelo físico
   Motor: Microsoft SQL Server
   ========================================================= */

USE master;
GO

IF DB_ID('PA1_TechStore') IS NOT NULL
BEGIN
    ALTER DATABASE PA1_TechStore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PA1_TechStore;
END;
GO

CREATE DATABASE PA1_TechStore;
GO

USE PA1_TechStore;
GO

CREATE TABLE Cliente (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    Documento VARCHAR(12) NOT NULL,
    Nombres VARCHAR(60) NOT NULL,
    Apellidos VARCHAR(60) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    FechaRegistro DATE NOT NULL CONSTRAINT DF_Cliente_FechaRegistro DEFAULT (CAST(GETDATE() AS DATE)),
    Estado CHAR(1) NOT NULL CONSTRAINT DF_Cliente_Estado DEFAULT ('A'),

    CONSTRAINT UQ_Cliente_Documento UNIQUE (Documento),
    CONSTRAINT UQ_Cliente_Email UNIQUE (Email),
    CONSTRAINT CK_Cliente_Estado CHECK (Estado IN ('A','I'))
);
GO

CREATE TABLE Categoria (
    IdCategoria INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(60) NOT NULL,
    Descripcion VARCHAR(150) NULL,

    CONSTRAINT UQ_Categoria_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE Producto (
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,
    IdCategoria INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL CONSTRAINT DF_Producto_Stock DEFAULT (0),
    FechaAlta DATE NOT NULL CONSTRAINT DF_Producto_FechaAlta DEFAULT (CAST(GETDATE() AS DATE)),
    Estado CHAR(1) NOT NULL CONSTRAINT DF_Producto_Estado DEFAULT ('A'),

    CONSTRAINT UQ_Producto_Nombre UNIQUE (Nombre),
    CONSTRAINT CK_Producto_Precio CHECK (Precio > 0),
    CONSTRAINT CK_Producto_Stock CHECK (Stock >= 0),
    CONSTRAINT CK_Producto_Estado CHECK (Estado IN ('A','I')),
    CONSTRAINT FK_Producto_Categoria
        FOREIGN KEY (IdCategoria) REFERENCES Categoria(IdCategoria)
);
GO

CREATE TABLE Venta (
    IdVenta INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT NOT NULL,
    FechaVenta DATETIME NOT NULL CONSTRAINT DF_Venta_Fecha DEFAULT (GETDATE()),
    MetodoPago VARCHAR(20) NOT NULL,
    Estado CHAR(1) NOT NULL CONSTRAINT DF_Venta_Estado DEFAULT ('R'),

    CONSTRAINT CK_Venta_MetodoPago CHECK (MetodoPago IN ('EFECTIVO','TARJETA','YAPE','PLIN')),
    CONSTRAINT CK_Venta_Estado CHECK (Estado IN ('R','A')),
    CONSTRAINT FK_Venta_Cliente
        FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
);
GO

CREATE TABLE DetalleVenta (
    IdDetalle INT IDENTITY(1,1) PRIMARY KEY,
    IdVenta INT NOT NULL,
    IdProducto INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    Descuento DECIMAL(5,2) NOT NULL CONSTRAINT DF_Detalle_Descuento DEFAULT (0),

    CONSTRAINT CK_Detalle_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_Detalle_Precio CHECK (PrecioUnitario > 0),
    CONSTRAINT CK_Detalle_Descuento CHECK (Descuento BETWEEN 0 AND 100),
    CONSTRAINT FK_Detalle_Venta
        FOREIGN KEY (IdVenta) REFERENCES Venta(IdVenta),
    CONSTRAINT FK_Detalle_Producto
        FOREIGN KEY (IdProducto) REFERENCES Producto(IdProducto)
);
GO


/* =========================================================
   Script 02: Datos de prueba
   ========================================================= */

USE PA1_TechStore;
GO

INSERT INTO Categoria (Nombre, Descripcion) VALUES
('Laptops', 'Computadoras portátiles'),
('Accesorios', 'Periféricos y accesorios'),
('Monitores', 'Monitores para oficina y gaming'),
('Almacenamiento', 'Unidades SSD y almacenamiento externo');
GO

INSERT INTO Cliente (Documento, Nombres, Apellidos, Email, Ciudad, FechaRegistro, Estado) VALUES
('74851236', 'Ana', 'Torres Ruiz', 'ana.torres@gmail.com', 'Lima', '2026-08-20', 'A'),
('71554411', 'Luis', 'Mendoza Paz', 'luis.mendoza@gmail.com', 'Ica', '2026-08-23', 'A'),
('70661220', 'Carla', 'Ramos Soto', 'carla.ramos@gmail.com', 'Lima', '2026-09-01', 'A'),
('77993315', 'Miguel', 'Salazar Vega', 'miguel.salazar@gmail.com', 'Arequipa', '2026-09-03', 'A'),
('76321458', 'Lucía', 'Paredes León', 'lucia.paredes@gmail.com', 'Ica', '2026-09-10', 'A'),
('78884521', 'Pedro', 'Campos Gil', 'pedro.campos@gmail.com', 'Lima', '2026-09-15', 'I');
GO

INSERT INTO Producto (IdCategoria, Nombre, Precio, Stock, FechaAlta, Estado) VALUES
(1, 'Laptop NovaBook 14', 2499.90, 8, '2026-08-15', 'A'),
(1, 'Laptop ProWork 15', 3299.00, 5, '2026-08-16', 'A'),
(2, 'Mouse Inalámbrico AirClick', 79.90, 30, '2026-08-17', 'A'),
(2, 'Teclado Mecánico K87', 189.90, 18, '2026-08-18', 'A'),
(3, 'Monitor Vision 24', 699.00, 12, '2026-08-20', 'A'),
(3, 'Monitor Vision 27 QHD', 1199.00, 6, '2026-08-21', 'A'),
(4, 'SSD 1TB TurboDisk', 349.90, 20, '2026-08-22', 'A'),
(4, 'SSD Externo 2TB PocketDrive', 599.90, 10, '2026-08-23', 'A');
GO

INSERT INTO Venta (IdCliente, FechaVenta, MetodoPago, Estado) VALUES
(1, '2026-09-05T10:15:00', 'TARJETA', 'R'),
(2, '2026-09-06T12:40:00', 'YAPE', 'R'),
(3, '2026-09-07T16:05:00', 'EFECTIVO', 'R'),
(1, '2026-09-12T18:30:00', 'PLIN', 'R'),
(5, '2026-09-18T11:10:00', 'TARJETA', 'R'),
(4, '2026-09-20T15:20:00', 'YAPE', 'R');
GO

INSERT INTO DetalleVenta (IdVenta, IdProducto, Cantidad, PrecioUnitario, Descuento) VALUES
(1, 1, 1, 2499.90, 5),
(1, 3, 1, 79.90, 0),
(2, 7, 2, 349.90, 0),
(3, 5, 1, 699.00, 0),
(3, 4, 1, 189.90, 10),
(4, 6, 1, 1199.00, 0),
(4, 3, 2, 79.90, 0),
(5, 2, 1, 3299.00, 8),
(5, 8, 1, 599.90, 0),
(6, 5, 2, 699.00, 5);
GO


/* =========================================================
   Script 03: Consultas requeridas por la PA1
   ========================================================= */

USE PA1_TechStore;
GO

/* 1. SELECT + WHERE + LIKE
   Requerimiento: localizar clientes cuyo apellido contiene 'a'. */
SELECT IdCliente, Nombres, Apellidos, Ciudad
FROM Cliente
WHERE Apellidos LIKE '%a%'
ORDER BY Apellidos;
GO

/* 2. BETWEEN
   Requerimiento: productos con precio entre S/ 100 y S/ 1,000. */
SELECT IdProducto, Nombre, Precio
FROM Producto
WHERE Precio BETWEEN 100 AND 1000
ORDER BY Precio;
GO

/* 3. IN
   Requerimiento: clientes ubicados en Lima o Ica. */
SELECT IdCliente, Nombres, Apellidos, Ciudad
FROM Cliente
WHERE Ciudad IN ('Lima', 'Ica')
ORDER BY Ciudad, Apellidos;
GO

/* 4. Funciones de cadena
   Requerimiento: presentar nombre completo y correo normalizado. */
SELECT
    IdCliente,
    UPPER(CONCAT(Nombres, ' ', Apellidos)) AS Cliente,
    LOWER(Email) AS EmailNormalizado,
    LEN(CONCAT(Nombres, Apellidos)) AS LongitudNombre
FROM Cliente;
GO

/* 5. Funciones numéricas
   Requerimiento: mostrar precio, IGV referencial y precio con IGV. */
SELECT
    Nombre,
    Precio,
    ROUND(Precio * 0.18, 2) AS IGV,
    ROUND(Precio * 1.18, 2) AS PrecioConIGV
FROM Producto;
GO

/* 6. Funciones de fecha
   Requerimiento: identificar año, mes y días transcurridos desde el alta. */
SELECT
    Nombre,
    FechaAlta,
    YEAR(FechaAlta) AS AnioAlta,
    MONTH(FechaAlta) AS MesAlta,
    DATEDIFF(DAY, FechaAlta, CAST(GETDATE() AS DATE)) AS DiasDesdeAlta
FROM Producto;
GO

/* 7. GROUP BY + funciones de agregación
   Requerimiento: cantidad de productos y precio promedio por categoría. */
SELECT
    c.Nombre AS Categoria,
    COUNT(*) AS CantidadProductos,
    ROUND(AVG(p.Precio), 2) AS PrecioPromedio,
    MIN(p.Precio) AS PrecioMinimo,
    MAX(p.Precio) AS PrecioMaximo
FROM Categoria c
INNER JOIN Producto p ON c.IdCategoria = p.IdCategoria
GROUP BY c.Nombre
ORDER BY c.Nombre;
GO

/* 8. HAVING
   Requerimiento: categorías cuyo precio promedio supera S/ 500. */
SELECT
    c.Nombre AS Categoria,
    COUNT(*) AS CantidadProductos,
    ROUND(AVG(p.Precio), 2) AS PrecioPromedio
FROM Categoria c
INNER JOIN Producto p ON c.IdCategoria = p.IdCategoria
GROUP BY c.Nombre
HAVING AVG(p.Precio) > 500
ORDER BY PrecioPromedio DESC;
GO

/* 9. INNER JOIN
   Requerimiento: detalle completo de ventas con cliente y producto. */
SELECT
    v.IdVenta,
    v.FechaVenta,
    CONCAT(cl.Nombres, ' ', cl.Apellidos) AS Cliente,
    p.Nombre AS Producto,
    d.Cantidad,
    d.PrecioUnitario,
    d.Descuento,
    ROUND(d.Cantidad * d.PrecioUnitario * (1 - d.Descuento / 100.0), 2) AS Subtotal
FROM Venta v
INNER JOIN Cliente cl ON v.IdCliente = cl.IdCliente
INNER JOIN DetalleVenta d ON v.IdVenta = d.IdVenta
INNER JOIN Producto p ON d.IdProducto = p.IdProducto
ORDER BY v.IdVenta, d.IdDetalle;
GO

/* 10. LEFT JOIN
   Requerimiento: listar todos los clientes, incluso los que no compraron. */
SELECT
    cl.IdCliente,
    CONCAT(cl.Nombres, ' ', cl.Apellidos) AS Cliente,
    COUNT(v.IdVenta) AS NumeroVentas
FROM Cliente cl
LEFT JOIN Venta v ON cl.IdCliente = v.IdCliente
GROUP BY cl.IdCliente, cl.Nombres, cl.Apellidos
ORDER BY NumeroVentas DESC, Cliente;
GO

/* 11. RIGHT JOIN
   Requerimiento: mostrar todas las categorías y sus productos. */
SELECT
    c.Nombre AS Categoria,
    p.Nombre AS Producto
FROM Producto p
RIGHT JOIN Categoria c ON p.IdCategoria = c.IdCategoria
ORDER BY c.Nombre, p.Nombre;
GO

/* 12. CASE
   Requerimiento: clasificar productos por nivel de precio. */
SELECT
    Nombre,
    Precio,
    CASE
        WHEN Precio < 200 THEN 'ECONOMICO'
        WHEN Precio < 1000 THEN 'MEDIO'
        ELSE 'PREMIUM'
    END AS SegmentoPrecio
FROM Producto
ORDER BY Precio;
GO

/* 13. UNION
   Requerimiento: consolidar nombres de clientes y productos
   en una sola salida de elementos registrados. */
SELECT
    CONCAT(Nombres, ' ', Apellidos) AS Elemento,
    'CLIENTE' AS Tipo
FROM Cliente
UNION
SELECT
    Nombre AS Elemento,
    'PRODUCTO' AS Tipo
FROM Producto;
GO

/* 14. Creación de tabla desde consulta mediante SELECT INTO
   Requerimiento: generar una tabla temporal de productos con bajo stock. */
IF OBJECT_ID('dbo.ProductosStockBajo', 'U') IS NOT NULL
    DROP TABLE dbo.ProductosStockBajo;

SELECT
    IdProducto,
    Nombre,
    Stock,
    Precio
INTO dbo.ProductosStockBajo
FROM Producto
WHERE Stock < 10;

SELECT * FROM dbo.ProductosStockBajo;
GO

/* 15. Subconsulta escalar
   Requerimiento: productos cuyo precio supera el precio promedio general. */
SELECT IdProducto, Nombre, Precio
FROM Producto
WHERE Precio > (SELECT AVG(Precio) FROM Producto)
ORDER BY Precio DESC;
GO

/* 16. Subconsulta con IN
   Requerimiento: clientes que realizaron al menos una venta. */
SELECT IdCliente, Nombres, Apellidos
FROM Cliente
WHERE IdCliente IN (
    SELECT DISTINCT IdCliente
    FROM Venta
)
ORDER BY Apellidos;
GO

/* 17. EXISTS
   Requerimiento: productos que aparecen en al menos un detalle de venta. */
SELECT
    p.IdProducto,
    p.Nombre,
    p.Precio
FROM Producto p
WHERE EXISTS (
    SELECT 1
    FROM DetalleVenta d
    WHERE d.IdProducto = p.IdProducto
)
ORDER BY p.Nombre;
GO

/* 18. EXISTS aplicado al cliente
   Requerimiento: clientes que sí tienen ventas registradas. */
SELECT
    cl.IdCliente,
    CONCAT(cl.Nombres, ' ', cl.Apellidos) AS Cliente
FROM Cliente cl
WHERE EXISTS (
    SELECT 1
    FROM Venta v
    WHERE v.IdCliente = cl.IdCliente
);
GO

/* Comparación técnica:
   - IN es legible cuando se compara un valor contra una lista devuelta por otra consulta.
   - EXISTS expresa directamente la necesidad de comprobar existencia.
   - Para este caso, EXISTS evita devolver columnas innecesarias y representa bien
     el requerimiento "existe al menos un registro relacionado".
*/


/* =========================================================
   Script 04: Validación de restricciones
   Las pruebas se controlan con TRY...CATCH para demostrar
   que SQL Server rechaza datos inválidos.
   ========================================================= */

USE PA1_TechStore;
GO

/* Prueba 1: precio negativo -> CHECK */
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO Producto (IdCategoria, Nombre, Precio, Stock)
    VALUES (1, 'Producto Invalido Precio', -10, 1);
    ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'OK - CHECK de precio rechazó el valor inválido: ' + ERROR_MESSAGE();
END CATCH;
GO

/* Prueba 2: stock negativo -> CHECK */
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO Producto (IdCategoria, Nombre, Precio, Stock)
    VALUES (1, 'Producto Invalido Stock', 100, -5);
    ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'OK - CHECK de stock rechazó el valor inválido: ' + ERROR_MESSAGE();
END CATCH;
GO

/* Prueba 3: documento duplicado -> UNIQUE */
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO Cliente (Documento, Nombres, Apellidos, Email, Ciudad)
    VALUES ('74851236', 'Prueba', 'Duplicado', 'prueba.duplicado@gmail.com', 'Lima');
    ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'OK - UNIQUE de documento rechazó el duplicado: ' + ERROR_MESSAGE();
END CATCH;
GO

/* Prueba 4: correo duplicado -> UNIQUE */
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO Cliente (Documento, Nombres, Apellidos, Email, Ciudad)
    VALUES ('70000001', 'Prueba', 'Correo', 'ana.torres@gmail.com', 'Lima');
    ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'OK - UNIQUE de correo rechazó el duplicado: ' + ERROR_MESSAGE();
END CATCH;
GO

/* Prueba 5: categoría inexistente -> FOREIGN KEY */
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO Producto (IdCategoria, Nombre, Precio, Stock)
    VALUES (999, 'Producto FK Invalido', 150, 5);
    ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'OK - FOREIGN KEY rechazó la categoría inexistente: ' + ERROR_MESSAGE();
END CATCH;
GO

/* Prueba 6: cantidad cero -> CHECK */
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO DetalleVenta (IdVenta, IdProducto, Cantidad, PrecioUnitario, Descuento)
    VALUES (1, 1, 0, 2499.90, 0);
    ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'OK - CHECK de cantidad rechazó el valor inválido: ' + ERROR_MESSAGE();
END CATCH;
GO

/* Prueba 7: descuento mayor a 100 -> CHECK */
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO DetalleVenta (IdVenta, IdProducto, Cantidad, PrecioUnitario, Descuento)
    VALUES (1, 1, 1, 2499.90, 120);
    ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'OK - CHECK de descuento rechazó el valor inválido: ' + ERROR_MESSAGE();
END CATCH;
GO

/* Prueba 8: método de pago no permitido -> CHECK */
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO Venta (IdCliente, MetodoPago)
    VALUES (1, 'BITCOIN');
    ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'OK - CHECK de método de pago rechazó el valor inválido: ' + ERROR_MESSAGE();
END CATCH;
GO


/* Consulte también 05_detach_attach.sql para separación y adjunción. */
