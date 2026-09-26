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
