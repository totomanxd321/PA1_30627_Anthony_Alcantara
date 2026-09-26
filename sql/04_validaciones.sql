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
