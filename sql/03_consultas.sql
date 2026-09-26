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
